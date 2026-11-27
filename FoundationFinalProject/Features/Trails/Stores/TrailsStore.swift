import SwiftUI
import Combine
import Notion

/// Centraliza o carregamento; as telas não precisam conhecer o cliente Notion.
@MainActor
final class TrailsStore: ObservableObject {
    // Informe o valor do campo "Key" no Notion para destacar uma trilha.
    // Deixe vazio para manter apenas a ordenação pelo campo "Ordem".
    let firstTrailKey = ""

    @Published private(set) var trails: [NotionTrail] = []
    @Published private(set) var loading = false
    @Published private(set) var errorMessage: String?

    func load() async {
        guard !loading else { return }
        loading = true
        errorMessage = nil
        defer { loading = false }
        guard let token = ProcessInfo.processInfo.environment["BEARER_TOKEN"]?
            .trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty else {
            errorMessage = "Configure a variável BEARER_TOKEN no Scheme do Xcode."
            return
        }
        guard let dataSourceID = ProcessInfo.processInfo
            .environment["NOTION_TRAILS_DATA_SOURCE_ID"]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !dataSourceID.isEmpty else {
            errorMessage = "Configure NOTION_TRAILS_DATA_SOURCE_ID no Scheme do Xcode."
            return
        }
        do {
            let client = NotionClient(bearerToken: token)
            let result: [NotionTrail] = try await client.fetchPages(dataSourceID: dataSourceID)
            var orderedTrails = result.sorted {
                (Int(trimmed($0.order)) ?? 0) < (Int(trimmed($1.order)) ?? 0)
            }
            let preferredKey = trimmed(firstTrailKey)
            if !preferredKey.isEmpty,
               let index = orderedTrails.firstIndex(where: { trimmed($0.key) == preferredKey }) {
                // Troca as duas posições; as outras trilhas permanecem no lugar.
                orderedTrails.swapAt(0, index)
            }
            trails = orderedTrails
        } catch is CancellationError {
            // A saída da tela pode cancelar o carregamento.
        } catch {
            errorMessage = "Não foi possível carregar as trilhas: \(error.localizedDescription)"
        }
    }
}
