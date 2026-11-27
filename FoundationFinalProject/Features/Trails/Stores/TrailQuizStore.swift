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
                    "Configure BEARER_TOKEN e NOTION_TRAIL_QUIZ_DATA_SOURCE_ID (ID da tabela questionario) no Scheme do Xcode."
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

        let questionnaires = try await query(url: url, token: token)
        let wantedKey = trailGroupKey(trailKey)
        guard let questionnaire = questionnaires.first(where: { record in
            guard let properties = record["properties"] as? [String: Any] else { return false }
            return trailGroupKey(text(["Name", "name"], in: properties)) == wantedKey
        }),
        let properties = questionnaire["properties"] as? [String: Any],
        let questionIDs = relationIDs("pergunta", in: properties), !questionIDs.isEmpty else {
            throw TrailQuizError.message(
                "Não encontrei perguntas para a trilha '\(trailKey)'. Confira o nome do grupo e a relação 'pergunta' na tabela questionario."
            )
        }

        var questions: [TrailQuizQuestion] = []
        for (index, id) in questionIDs.enumerated() {
            let record = try await fetchPage(id: id, token: token)
            guard let properties = record["properties"] as? [String: Any] else { continue }
            if let question = try makeQuestion(
                record: record,
                properties: properties,
                fallbackOrder: index + 1
            ) {
                questions.append(question)
            }
        }
        return questions.sorted { $0.order < $1.order }
    }

    private static func query(url: URL, token: String) async throws -> [[String: Any]] {
        var records: [[String: Any]] = []
        var cursor: String?
        repeat {
            var request = makeRequest(url: url, token: token, method: "POST")
            var body: [String: Any] = ["page_size": 100]
            if let cursor { body["start_cursor"] = cursor }
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let json = try await send(request)
            guard let page = json["results"] as? [[String: Any]] else {
                throw TrailQuizError.message("O Notion retornou os dados do questionário em formato inesperado.")
            }
            records += page
            if json["has_more"] as? Bool == true {
                guard let next = json["next_cursor"] as? String else {
                    throw TrailQuizError.message("O Notion não enviou a próxima página do questionário.")
                }
                cursor = next
            } else {
                cursor = nil
            }
        } while cursor != nil
        return records
    }

    private static func fetchPage(id: String, token: String) async throws -> [String: Any] {
        guard let url = URL(string: "https://api.notion.com/v1/pages/\(id)") else {
            throw TrailQuizError.message("O Notion enviou o ID inválido de uma pergunta.")
        }
        return try await send(makeRequest(url: url, token: token, method: "GET"))
    }

    private static func makeRequest(url: URL, token: String, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2025-09-03", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private static func send(_ request: URLRequest) async throws -> [String: Any] {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw TrailQuizError.message("Resposta de rede inválida ao buscar o questionário.")
        }
        guard (200..<300).contains(response.statusCode) else {
            throw TrailQuizError.message(
                "Erro HTTP \(response.statusCode) ao consultar o Notion. Confira o token, a fonte e o acesso da integração."
            )
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TrailQuizError.message("O Notion retornou os dados em um formato inesperado.")
        }
        return json
    }

    private static func relationIDs(_ name: String, in properties: [String: Any]) -> [String]? {
        guard let property = properties[name] as? [String: Any],
              let relations = property["relation"] as? [[String: Any]] else { return nil }
        return relations.compactMap { $0["id"] as? String }
    }

    private static func removingOptionLabel(from option: String, letter: String) -> String {
        let value = option.trimmingCharacters(in: .whitespacesAndNewlines)
        for prefix in ["\(letter))", "\(letter)."] where value.uppercased().hasPrefix(prefix) {
            return String(value.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return value
    }

    private static func trailGroupKey(_ value: String) -> String {
        let normalized = value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR"))
            .filter { $0.isLetter || $0.isNumber }
            .replacingOccurrences(of: "perguntas", with: "")
        if normalized == "back" { return "backend" }
        if normalized == "front" { return "frontend" }
        if normalized.contains("backend") { return "backend" }
        if normalized.contains("frontend") { return "frontend" }
        if normalized.contains("devops") { return "devops" }
        if normalized.contains("ciber") || normalized.contains("cyber") { return "ciberseguranca" }
        if normalized.contains("design") || normalized.contains("uiux") { return "design" }
        return normalized
    }

    private static func makeQuestion(
        record: [String: Any],
        properties: [String: Any],
        fallbackOrder: Int
    ) throws -> TrailQuizQuestion? {
        let prompt = text(["pergunta", "Pergunta"], in: properties)
        let options = ["A", "B", "C", "D"].map { letter in
            let option = text(["\(letter)_alternativa", "alternativa_\(letter)", "Alternativa_\(letter)"], in: properties)
            return removingOptionLabel(from: option, letter: letter)
        }
        guard !prompt.isEmpty, options.allSatisfy({ !$0.isEmpty }), let id = record["id"] as? String else {
            return nil
        }

        let correctAnswer = text(
            ["resposta_correta", "Resposta_correta", "Resposta correta", "Gabarito"],
            in: properties
        )
        guard ["A", "B", "C", "D"].contains(correctAnswer.uppercased()) else {
            throw TrailQuizError.message(
                "Adicione à tabela a coluna Resposta_correta (texto ou seleção) e informe A, B, C ou D para cada pergunta."
            )
        }

        let order = number(["Ordem", "ordem"], in: properties) ?? fallbackOrder
        let points = number(["Pontos", "pontos"], in: properties) ?? 1
        let explanation = text(["Explicacao", "Explicação", "explicacao"], in: properties)
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

    private static func text(_ names: [String], in properties: [String: Any]) -> String {
        guard let property = names.lazy.compactMap({ properties[$0] as? [String: Any] }).first,
              let type = property["type"] as? String else { return "" }

        if type == "select" {
            return (property["select"] as? [String: Any])?["name"] as? String ?? ""
        }
        guard let fragments = property[type] as? [[String: Any]] else { return "" }
        return fragments.compactMap { $0["plain_text"] as? String }.joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func number(_ names: [String], in properties: [String: Any]) -> Int? {
        guard let property = names.lazy.compactMap({ properties[$0] as? [String: Any] }).first,
              let value = property["number"] as? NSNumber else { return nil }
        return value.intValue
    }
}
