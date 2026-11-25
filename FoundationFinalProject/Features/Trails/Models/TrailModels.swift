import SwiftUI
import Notion

// A revisão do swift-notion usada no Init reconhece NotionTitle na geração do decoder.

@NotionPage
// para cada nó
struct NotionNode: Identifiable {//struct define um tipo de dado
    @NotionTitle("Titulo") var name: String// notacao; @Notionblablabla(campodonotion) var nomeaqui:String
    @NotionProperty("ID_trilha") var nodeID: String
    @NotionProperty("Ordem") var order: String
    @NotionProperty("Conteudo") var detail: String
    @NotionProperty("Exemplo") var exemple: String
    @NotionProperty("Status") var status: String
    @NotionProperty("Tipo") var kind: String
    @NotionProperty("Depende") var dependsOn: String
    @NotionProperty("Lane") var lane: String
    @NotionProperty("Slot") var slot: String
}

@NotionPage
//para cada trilha
struct NotionTrail: Identifiable {
    @NotionTitle("Nome_trilha") var name: String
    @NotionProperty("Key") var key: String
    @NotionProperty("icone") var icon: String
    @NotionProperty("Ordem") var order: String
    @NotionRelationProperty("Nos") var nodes: [NotionNode]
}
//remove espaco e quebra de linha
func trimmed(_ text: String) -> String {
    text.trimmingCharacters(in: .whitespacesAndNewlines)
}
//transforma dados em regras de apresentação
extension NotionNode {//extension adiciona funcionalidades a um tipo existente
    var localID: String { trimmed(nodeID) }
    var side: Bool { trimmed(kind).lowercased() == "side" }
    //transforma texto simples em um array
    var dependencies: [String] { dependsOn.split(separator: ",").map { trimmed(String($0)) }.filter { !$0.isEmpty } }
}
//define os status possiveis
enum NodeStatus: String, CaseIterable {
    case todo, current, done, blocked
    init(_ text: String) {
        switch trimmed(text).lowercased() {
        case "done", "concluído", "concluido": self = .done
        case "current", "em andamento": self = .current
        case "blocked", "bloqueado": self = .blocked
        default: self = .todo
        }
    }
    var label: String {
        switch self {
        case .todo: return "Não iniciado"
        case .current: return "Em andamento"
        case .done: return "Concluído"
        case .blocked: return "Bloqueado"
        }
    }
    var symbol: String {
        switch self {
        case .todo: return "circle"
        case .current: return "record.circle"
        case .done: return "checkmark.circle.fill"
        case .blocked: return "minus.circle.fill"
        }
    }
    var color: Color {
        switch self {
        case .todo: return Color("StatusPending")
        case .current: return Color("StatusCurrent")
        case .done:    return Color("StatusDone")
        case .blocked: return Color("StatusBlocked")
        }
    }
}
