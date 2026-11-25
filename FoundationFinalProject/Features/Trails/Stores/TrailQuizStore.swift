import Foundation
import Combine

@MainActor
final class TrailQuizStore: ObservableObject {
    @Published private(set) var questions: [TrailQuizQuestion] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isUsingSampleData = false

    func loadSampleData() {
        questions = TrailQuizSampleData.questions
        errorMessage = nil
        isUsingSampleData = true
    }

    func load(for trailKey: String) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let environment = ProcessInfo.processInfo.environment
        if environment["TRAIL_QUIZ_DEMO"] == "true" {
            loadSampleData()
            return
        }

        isUsingSampleData = false
        let token = (environment["BEARER_TOKEN"] ?? environment["NOTION_TOKEN"] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let source = (environment["NOTION_TRAIL_QUIZ_DATA_SOURCE_ID"] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            guard !token.isEmpty, !source.isEmpty else {
                throw TrailQuizError.message(
                    "Configure BEARER_TOKEN e NOTION_TRAIL_QUIZ_DATA_SOURCE_ID no Scheme do Xcode."
                )
            }
            questions = try await TrailQuizService.fetch(
                token: token,
                source: source,
                trailKey: trailKey
            )
            if questions.isEmpty {
                throw TrailQuizError.message("Ainda não há perguntas cadastradas para esta trilha.")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private enum TrailQuizError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let text): return text
        }
    }
}

private enum TrailQuizService {
    static func fetch(token: String, source: String, trailKey: String) async throws -> [TrailQuizQuestion] {
        guard let url = URL(string: "https://api.notion.com/v1/data_sources/\(source)/query") else {
            throw TrailQuizError.message("O ID da fonte do questionário está inválido.")
        }

        var questions: [TrailQuizQuestion] = []
        var cursor: String?

        repeat {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("2025-09-03", forHTTPHeaderField: "Notion-Version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            var body: [String: Any] = ["page_size": 100]
            if let cursor { body["start_cursor"] = cursor }
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else {
                throw TrailQuizError.message(
                    "Não foi possível consultar o questionário. Confira o token, o ID da fonte e o acesso da integração."
                )
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let records = json["results"] as? [[String: Any]] else {
                throw TrailQuizError.message("O Notion retornou os dados em um formato inesperado.")
            }

            for record in records {
                guard let properties = record["properties"] as? [String: Any],
                      text("Key_trilha", in: properties) == trailKey,
                      let question = makeQuestion(record: record, properties: properties) else {
                    continue
                }
                questions.append(question)
            }

            if json["has_more"] as? Bool == true {
                guard let nextCursor = json["next_cursor"] as? String else {
                    throw TrailQuizError.message("O Notion não enviou a próxima página do questionário.")
                }
                cursor = nextCursor
            } else {
                cursor = nil
            }
        } while cursor != nil

        return questions.sorted { $0.order < $1.order }
    }

    private static func makeQuestion(
        record: [String: Any],
        properties: [String: Any]
    ) -> TrailQuizQuestion? {
        let prompt = text("Pergunta", in: properties)
        let correctAnswer = text("Resposta_correta", in: properties)
        let options = ["A", "B", "C", "D"].map {
            text("Alternativa_\($0)", in: properties)
        }
        guard !prompt.isEmpty,
              !correctAnswer.isEmpty,
              options.allSatisfy({ !$0.isEmpty }),
              let id = record["id"] as? String else {
            return nil
        }

        let order = number("Ordem", in: properties) ?? 0
        let points = number("Pontos", in: properties) ?? 1
        let explanation = text("Explicacao", in: properties)
        return TrailQuizQuestion(
            id: id,
            order: order,
            prompt: prompt,
            options: options,
            correctAnswer: correctAnswer.uppercased(),
            points: points,
            explanation: explanation
        )
    }

    private static func text(_ name: String, in properties: [String: Any]) -> String {
        guard let property = properties[name] as? [String: Any],
              let type = property["type"] as? String else { return "" }

        if type == "select" {
            return (property["select"] as? [String: Any])?["name"] as? String ?? ""
        }
        guard let fragments = property[type] as? [[String: Any]] else { return "" }
        return fragments.compactMap { $0["plain_text"] as? String }.joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func number(_ name: String, in properties: [String: Any]) -> Int? {
        guard let property = properties[name] as? [String: Any],
              let value = property["number"] as? NSNumber else { return nil }
        return value.intValue
    }
}
