import Foundation

enum GlossarioErro: LocalizedError {
    case mensagem(String)
    var errorDescription: String? {
        switch self {
        case .mensagem(let texto): return texto
        }
    }
}

enum NotionGlossarioService {
    static func buscar(token: String, fonte: String) async throws -> (termos: [Termo], incompletos: Int) {
        guard UUID(uuidString: fonte) != nil ||
                (fonte.count == 32 && fonte.allSatisfy({ $0.isHexDigit })),
              let url = URL(string: "https://api.notion.com/v1/data_sources/\(fonte)/query") else {
            throw GlossarioErro.mensagem("Use o ID da fonte glossario, sem a URL do Notion.")
        }
        var termos: [Termo] = []
        var incompletos = 0
        var cursor: String?
        var cursores = Set<String>()
        repeat {
            try Task.checkCancellation()
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("2025-09-03", forHTTPHeaderField: "Notion-Version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            var corpo: [String: Any] = ["page_size": 100]
            if let cursor { corpo["start_cursor"] = cursor }
            request.httpBody = try JSONSerialization.data(withJSONObject: corpo)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw GlossarioErro.mensagem("Resposta de rede inválida.")
            }
            guard (200..<300).contains(http.statusCode) else {
                throw GlossarioErro.mensagem("Erro HTTP \(http.statusCode) no glossário. Confira o token, o ID e o acesso da integração à fonte glossario.")
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let registros = json["results"] as? [[String: Any]] else {
                throw GlossarioErro.mensagem("O Notion retornou um formato inesperado.")
            }
            for registro in registros {
                if let termo = try converter(registro) {
                    termos.append(termo)
                } else {
                    incompletos += 1
                }
            }
            if json["has_more"] as? Bool == true {
                guard let proximo = json["next_cursor"] as? String,
                      cursores.insert(proximo).inserted else {
                    throw GlossarioErro.mensagem("Paginação inválida na resposta do Notion.")
                }
                cursor = proximo
            } else {
                cursor = nil
            }
        } while cursor != nil
        return (termos, incompletos)
    }

    static func converter(_ registro: [String: Any]) throws -> Termo? {
        guard let id = registro["id"] as? String,
              let campos = registro["properties"] as? [String: Any] else {
            throw GlossarioErro.mensagem("Registro do glossário sem ID ou propriedades.")
        }
        // Os nomes correspondem às colunas da sua tabela do Notion.
        let nome = try texto("Palavra", campos: campos)
        let significado = try texto("Definição", campos: campos)
        guard !nome.isEmpty, !significado.isEmpty else {
            // Um rascunho vazio não deve bloquear os outros termos.
            return nil
        }
        let tags: [String]
        if let campo = campos["Tag"] as? [String: Any], campo["type"] as? String == "multi_select" {
            tags = (campo["multi_select"] as? [[String: Any]] ?? [])
                .compactMap { $0["name"] as? String }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        } else {
            let tag = try texto("Tag", campos: campos, opcional: true)
            tags = tag.isEmpty ? [] : [tag]
        }
        // Destaque é opcional; a tabela da captura não precisa ser modificada.
        let destaque = (campos["Destaque"] as? [String: Any])?["checkbox"] as? Bool ?? false
        return Termo(id: id, nome: nome, significado: significado, tags: tags, destaque: destaque)
    }

    private static func texto(_ nome: String, campos: [String: Any], opcional: Bool = false) throws -> String {
        guard let campo = campos[nome] as? [String: Any], let tipo = campo["type"] as? String else {
            if opcional { return "" }
            throw GlossarioErro.mensagem("A coluna \(nome) não foi encontrada no glossário.")
        }
        let texto: String
        switch tipo {
        case "title", "rich_text":
            texto = (campo[tipo] as? [[String: Any]] ?? [])
                .compactMap { $0["plain_text"] as? String }.joined()
        case "select":
            texto = (campo[tipo] as? [String: Any])?["name"] as? String ?? ""
        case "multi_select":
            texto = (campo[tipo] as? [[String: Any]] ?? [])
                .compactMap { $0["name"] as? String }.joined(separator: ", ")
        default:
            throw GlossarioErro.mensagem("A coluna \(nome) tem tipo incompatível. Use texto, seleção ou seleção múltipla.")
        }
        return texto.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
