import Foundation

// Representa um registro da fonte glossario no Notion.
struct Termo: Identifiable {
    let id: String
    let nome: String
    let significado: String
    let tags: [String]
    let destaque: Bool

    var area: String { tags.joined(separator: ", ") }
}
