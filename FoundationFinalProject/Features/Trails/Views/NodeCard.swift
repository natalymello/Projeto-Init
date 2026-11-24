import SwiftUI

struct NodeCard: View {
    let node: NotionNode
    let trailKey: String
    let trailNodes: [NotionNode]
    let cardWidth: CGFloat
    @AppStorage private var savedStatus: String

    init(node: NotionNode, trailKey: String, trailNodes: [NotionNode], cardWidth: CGFloat) {
        self.node = node
        self.trailKey = trailKey
        self.trailNodes = trailNodes
        self.cardWidth = cardWidth
        _savedStatus = AppStorage(wrappedValue: "", "roadmap.mvp.\(trimmed(trailKey))/\(node.localID)")
    }

    private var status: NodeStatus { NodeStatus(savedStatus.isEmpty ? node.status : savedStatus) }

    var body: some View {
        NavigationLink {
            TrailNodeDetailView(node: node, trailKey: trailKey, trailNodes: trailNodes)
        } label: {
            Text(node.name)
                .font(.system(size: node.side ? 11 : 14, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 8)
                .frame(width: cardWidth, height: node.side ? 34 : 44)
                .foregroundStyle(node.side ? TrailStyle.blue : Color("Branco-Init"))
                .background(node.side ? TrailStyle.side : TrailStyle.blue, in: RoundedRectangle(cornerRadius: node.side ? 12 : 16))
                .shadow(color: Color("Azul-marinho-init").opacity(0.13), radius: 1, y: 2)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: status.symbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(status.color)
                        .padding(2)
                        .background(TrailStyle.background, in: Circle())
                        .offset(x: 4, y: -8)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(node.name), \(status.label)")
    }
}
