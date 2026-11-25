import SwiftUI

enum TrailStyle {
    static let background = Color("Branco-Init")
    static let blue = Color("Azul-Init")
    static let gradient = LinearGradient(colors: [blue, Color("Azul-marinho-init")], startPoint: .topLeading, endPoint: .bottomTrailing)

    static func symbol(name: String, fallback: String = "map") -> String {
        let value = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        if value.contains("front") { return "macwindow.and.cursorarrow" }
        if value.contains("back") { return "terminal" }
        if value.contains("design") || value.contains("ui/ux") { return "paintbrush.pointed" }
        if value.contains("segur") || value.contains("cyber") || value.contains("ciber") { return "lock.shield" }
        if value.contains("devops") { return "infinity" }
        return trimmed(fallback).isEmpty ? "map" : fallback
    }
}

struct TrailMapBackButton: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color("Branco-Init"))
                .frame(width: 44, height: 44)
                .background(RoadmapTheme.backBtn, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Voltar")
    }
}

struct TrailSelectionCard: View {
    let name: String
    let symbol: String
    var featured = false

    var body: some View {
        RoundedRectangle(cornerRadius: featured ? 28 : 20)
            .fill(LinearGradient(
                colors: featured
                    ? [TrailStyle.blue, Color("Azul-marinho-init")]
                    : [Color("Azul-marinho-init"), Color("Azul-Init")],
                startPoint: .top, endPoint: .bottom
            ))
            .aspectRatio(featured ? 2.13 : 1.27, contentMode: .fit)
            .shadow(color: Color("Azul-marinho-init").opacity(featured ? 0 : 0.2), radius: 2, y: 3)
            .overlay {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Image(systemName: symbol)
                            .font(.system(size: featured ? 45 : 42, weight: .medium))
                            .accessibilityHidden(true)
                        Spacer(minLength: 4)
                        if featured {
                            Label {
                                Text("trilha ideal")
                            } icon: {
                                Image(systemName: "star.fill").foregroundStyle(Color("RecommendationStar"))
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(TrailStyle.blue)
                            .padding(.horizontal, 9).padding(.vertical, 6)
                            .background(TrailStyle.background, in: Capsule())
                        }
                    }
                    Spacer(minLength: 0)
                    HStack(alignment: .bottom) {
                        Text(name)
                            .font(.system(size: featured ? 37 : 23, weight: featured ? .bold : .medium))
                            .lineLimit(2)
                            .minimumScaleFactor(0.65)
                            .multilineTextAlignment(.leading)
                        if featured {
                            Spacer(minLength: 4)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(TrailStyle.blue)
                                .frame(width: 24, height: 24)
                                .background(Color("Branco-Init"), in: Circle())
                                .accessibilityHidden(true)
                        }
                    }
                }
                .foregroundStyle(Color("Branco-Init"))
                .padding(featured ? 19 : 14)
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        TrailSelectionCard(name: "Back-end", symbol: "terminal", featured: true)
        HStack {
            TrailSelectionCard(name: "Front-end", symbol: "macwindow.and.cursorarrow")
            TrailSelectionCard(name: "Design UI/UX", symbol: "paintbrush.pointed")
        }
    }.padding(24).background(TrailStyle.background)
}
