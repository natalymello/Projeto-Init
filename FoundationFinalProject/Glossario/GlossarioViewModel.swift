import Foundation
import Combine

@MainActor
final class GlossarioViewModel: ObservableObject {
    @Published private(set) var termos: [Termo] = []
    @Published private(set) var carregando = false
    @Published private(set) var erro: String?
    @Published private(set) var incompletos = 0
    @Published var pesquisa = ""
    @Published var tagSelecionada: String?
    private var carregou = false

    var tags: [String] {
        Set(termos.flatMap(\.tags)).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    var termosFiltrados: [Termo] {
        let busca = pesquisa.trimmingCharacters(in: .whitespacesAndNewlines)
        return termos.filter {
            guard tagSelecionada.map($0.tags.contains) ?? true else { return false }
            return busca.isEmpty || $0.nome.localizedStandardContains(busca)
        }.sorted { $0.nome.localizedStandardCompare($1.nome) == .orderedAscending }
    }

    var destaques: [Termo] {
        Array(termosFiltrados.filter { $0.destaque }.prefix(4))
    }

    // Agrupa letras acentuadas na letra base: Á em A, por exemplo.
    var gruposAlfabeticos: [(letra: String, termos: [Termo])] {
        let grupos = Dictionary(grouping: termosFiltrados) { termo in
            let inicial = String(termo.nome.prefix(1))
                .folding(options: .diacriticInsensitive, locale: Locale(identifier: "pt_BR"))
                .uppercased()
            return inicial.range(of: "^[A-Z]$", options: .regularExpression) != nil ? inicial : "#"
        }
        return grupos.keys.sorted().map { (letra: $0, termos: grupos[$0] ?? []) }
    }

    func carregar(atualizar: Bool = false) async {
        guard !carregando, atualizar || !carregou else { return }
        carregando = true
        erro = nil
        defer { carregando = false }
        let ambiente = ProcessInfo.processInfo.environment
        let token = (ambiente["BEARER_TOKEN"] ?? ambiente["NOTION_TOKEN"] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let fonte = (ambiente["NOTION_GLOSSARIO_DATA_SOURCE_ID"] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            guard !token.isEmpty, !fonte.isEmpty else {
                throw GlossarioErro.mensagem("Configure BEARER_TOKEN e NOTION_GLOSSARIO_DATA_SOURCE_ID no esquema do Xcode.")
            }
            let resultado = try await NotionGlossarioService.buscar(token: token, fonte: fonte)
            termos = resultado.termos
            if let tagSelecionada, !tags.contains(tagSelecionada) {
                self.tagSelecionada = nil
            }
            incompletos = resultado.incompletos
            carregou = true
        } catch is CancellationError {
            // Permite tentar novamente se a tarefa for cancelada.
        } catch {
            erro = error.localizedDescription
        }
    }
}
