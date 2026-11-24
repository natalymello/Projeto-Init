import Foundation
import Combine

// Carrega as perguntas e avisa a tela quando o estado muda.
@MainActor
final class QuizViewModel: ObservableObject {
    @Published private(set) var questions: [QuizQuestion] = []
    private var isLoading = false
    @Published private(set) var errorMessage: String?

    func load() async {
        guard questions.isEmpty, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let environment = ProcessInfo.processInfo.environment
        let token = (environment["BEARER_TOKEN"] ?? environment["NOTION_TOKEN"] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let source = (environment["NOTION_DATA_SOURCE_ID"] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            guard !token.isEmpty, !source.isEmpty else {
                throw QuizLoadError.invalid("Configure BEARER_TOKEN e NOTION_DATA_SOURCE_ID no esquema do Xcode.")
            }
            questions = try await NotionQuizService.fetch(token: token, source: source)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

enum QuizLoadError: LocalizedError {
    case invalid(String)
    var errorDescription: String? {
        switch self {
        case .invalid(let message): return message
        }
    }
}

// Converte a resposta do Notion nos modelos usados pela tela.
@MainActor
enum NotionQuizService {
    private static let weights = [1: 6, 2: 9, 3: 11, 4: 12, 5: 13]

    static func fetch(token: String, source: String) async throws -> [QuizQuestion] {
        guard UUID(uuidString: source) != nil ||
                (source.count == 32 && source.allSatisfy({ $0.isHexDigit })),
              let url = URL(string: "https://api.notion.com/v1/data_sources/\(source)/query") else {
            throw QuizLoadError.invalid("Use apenas o ID da fonte quiz, sem a URL do Notion.")
        }
        var questions: [QuizQuestion] = []
        var cursor: String?
        var visitedCursors = Set<String>()

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
            guard let http = response as? HTTPURLResponse else {
                throw QuizLoadError.invalid("Resposta de rede inválida.")
            }
            guard (200..<300).contains(http.statusCode) else {
                throw QuizLoadError.invalid("Erro HTTP \(http.statusCode). Confira o token, o ID da fonte e o acesso da integração.")
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let records = json["results"] as? [[String: Any]] else {
                throw QuizLoadError.invalid("Resposta do Notion em formato inesperado.")
            }
            for record in records {
                questions.append(try makeQuestion(from: record))
            }
            // Continua a consulta se o Notion dividir os resultados em páginas.
            if json["has_more"] as? Bool == true {
                guard let next = json["next_cursor"] as? String,
                      visitedCursors.insert(next).inserted else {
                    throw QuizLoadError.invalid("Paginação inválida na resposta do Notion.")
                }
                cursor = next
            } else {
                cursor = nil
            }
        } while cursor != nil

        questions.sort { $0.id < $1.id }
        guard questions.map({ $0.id }) == [1, 2, 3, 4, 5] else {
            throw QuizLoadError.invalid("A fonte deve ter exatamente cinco perguntas, numeradas de 1 a 5 no início do título.")
        }
        return questions
    }

    private static func makeQuestion(from record: [String: Any]) throws -> QuizQuestion {
        guard let properties = record["properties"] as? [String: Any] else {
            throw QuizLoadError.invalid("Registro sem propriedades.")
        }
        let fullTitle = text("Pergunta", in: properties)
        let numberText = fullTitle.prefix { $0.isNumber }
        guard let number = Int(String(numberText)), let weight = weights[number] else {
            throw QuizLoadError.invalid("Cada título deve começar com um número de 1 a 5.")
        }
        let title = String(fullTitle.dropFirst(numberText.count))
            .trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: ".-)")))
        guard !title.isEmpty else {
            throw QuizLoadError.invalid("A pergunta \(number) está sem título.")
        }
        // A pergunta 2 troca a posição de DevOps e Cibersegurança.
        let areas: [QuizArea] = number == 2
            ? [.backend, .uiux, .frontend, .devops, .cybersecurity]
            : [.backend, .uiux, .frontend, .cybersecurity, .devops]
        let options = try ["A", "B", "C", "D", "E"].enumerated().map { index, letter in
            let column = "alternativa_\(letter)"
            let answer = removeLetterPrefix(text(column, in: properties), letter: letter)
            guard !answer.isEmpty else {
                throw QuizLoadError.invalid("Preencha \(column) da pergunta \(number).")
            }
            return QuizOption(letter: letter, text: answer, area: areas[index])
        }
        return QuizQuestion(id: number, title: title, weight: weight, options: options)
    }

    // Title e Rich text chegam como listas de fragmentos de texto.
    private static func text(_ name: String, in properties: [String: Any]) -> String {
        guard let property = properties[name] as? [String: Any],
              let type = property["type"] as? String,
              let fragments = property[type] as? [[String: Any]] else { return "" }
        return fragments.compactMap { $0["plain_text"] as? String }.joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func removeLetterPrefix(_ text: String, letter: String) -> String {
        for prefix in ["\(letter))", "\(letter).", "\(letter) -"] {
            if text.hasPrefix(prefix) {
                return String(text.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return text
    }
}
