import SwiftUI

enum RoadmapTheme {
    static let navy     = Color("Navy")   // nós principais
    static let sideFill = Color("TrailSide")   // nós laterais
    static let sideText = Color("Azul-marinho-init")
    static let line     = Color("TrailSide")   // linhas
    static let backBtn  = Color("Azul-Init")   // botões redondos
}

struct StatusBadge: View {
    let status: NodeStatus
    var body: some View {
        ZStack {
            Circle().fill(fill)
            Circle().strokeBorder(Color("Branco-Init"), lineWidth: 1.5)
            switch status {
            case .todo:
                Circle()
                    .strokeBorder(Color("StatusPending").opacity(0.7), lineWidth: 1)
                    .padding(5)
            case .current:
                Image(systemName: "play.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color("Branco-Init"))
            case .done:
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color("Branco-Init"))
            case .blocked:
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(Color("Branco-Init"))
            }
        }
        .frame(width: 20, height: 20)
    }
    private var fill: Color {
        switch status {
        case .todo:    return Color("RoadmapPendingBadge")
        case .current: return Color("StatusCurrent")
        case .done:    return Color("StatusDone")
        case .blocked: return Color("StatusBlocked")
        }
    }
}
struct RoadmapNodeView: View {
    let node: NotionNode
    let status: NodeStatus
    private var isSide: Bool { node.layoutKind == .side }
    private var size: CGSize { TrailLayout.size(of: node.layoutKind) }
    private var fontSize: CGFloat { node.layoutKind == .main ? 18 : 13 }
    var body: some View {
        Text(node.name)
            .font(.system(size: fontSize, weight: .medium))
            .foregroundStyle(isSide ? RoadmapTheme.sideText : Color("Branco-Init"))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8)
            .frame(width: size.width, height: size.height)
            .background(isSide ? RoadmapTheme.sideFill : RoadmapTheme.navy,
                        in: RoundedRectangle(cornerRadius: min(16, size.height / 2)))
            .shadow(color: Color("Azul-marinho-init").opacity(isSide ? 0 : 0.25), radius: 4, y: 3)
            .overlay(alignment: .topTrailing) {
                StatusBadge(status: status)
                    .offset(x: 6, y: -6)
            }
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: status)
    }
}
struct TrailHeaderCard: View {
    let title: String
    let icon: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
            Text(title)
                .font(.system(size: 26))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .foregroundStyle(Color("Branco-Init"))
        .padding(.horizontal, 12)
        .frame(width: TrailLayout.startSize.width, height: TrailLayout.startSize.height)
        .background(RoadmapTheme.navy, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color("Azul-marinho-init").opacity(0.25), radius: 4, y: 3)
    }
}
struct TrailEndPill: View {
    var body: some View {
        Text("Próximos Passos")
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(Color("Branco-Init"))
            .frame(width: TrailLayout.endSize.width, height: TrailLayout.endSize.height)
            .background(RoadmapTheme.navy, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color("Azul-marinho-init").opacity(0.25), radius: 4, y: 3)
    }
}
