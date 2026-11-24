import SwiftUI

struct TrailNodeDetailView: View {
    let node: NotionNode
    let trailKey: String
    let trailNodes: [NotionNode]
    @AppStorage private var savedStatus: String

    init(node: NotionNode, trailKey: String, trailNodes: [NotionNode]) {
        self.node = node
        self.trailKey = trailKey
        self.trailNodes = trailNodes
        _savedStatus = AppStorage(wrappedValue: "", "roadmap.mvp.\(trimmed(trailKey))/\(node.localID)")
    }

    private var status: NodeStatus { NodeStatus(savedStatus.isEmpty ? node.status : savedStatus) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(node.name)
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(TrailStyle.blue)
                    .fixedSize(horizontal: false, vertical: true)

                if !trimmed(node.detail).isEmpty { contentBox(node.detail) }
                if !trimmed(node.exemple).isEmpty {
                    section("Exemplo") { contentBox(node.exemple, background: Color("TrailSide").opacity(0.35)) }
                }
                section("Status") {
                    VStack(spacing: 0) {
                        ForEach(NodeStatus.allCases, id: \.rawValue) { option in
                            Button { savedStatus = option.rawValue } label: {
                                HStack(spacing: 9) {
                                    Image(systemName: option.symbol).foregroundStyle(option.color).frame(width: 18)
                                    Text(option.label)
                                    Spacer()
                                    if status == option {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(option.color)
                                    }
                                }
                                .font(.system(size: 14))
                                .foregroundStyle(Color("Azul-marinho-init"))
                                .padding(.horizontal, 14)
                                .frame(minHeight: 44)
                                .background(status == option ? option.color.opacity(0.1) : Color("AppClear"))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(status == option ? .isSelected : [])
                        }
                    }
                    .background(Color("Branco-Init"), in: RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color("RoadmapPendingBadge").opacity(0.5), lineWidth: 1)
                    }
                }
                if !node.dependencies.isEmpty {
                    section("Pré-requisitos") {
                        VStack(spacing: 8) {
                            ForEach(node.dependencies, id: \.self) { dependency in
                                if let prerequisite = trailNodes.first(where: { $0.localID == dependency }) {
                                    NavigationLink {
                                        TrailNodeDetailView(node: prerequisite, trailKey: trailKey, trailNodes: trailNodes)
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.turn.down.right")
                                            Text(prerequisite.name)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                        .font(.system(size: 14))
                                        .foregroundStyle(TrailStyle.blue)
                                        .padding(14)
                                        .background(Color("Branco-Init"), in: RoundedRectangle(cornerRadius: 14))
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Text(dependency).font(.subheadline).foregroundStyle(Color("Azul-marinho-init"))
                                }
                            }
                        }
                    }
                }
                
            }
            .padding(.horizontal, 24).padding(.vertical, 20)
            .padding(.top, 60) // Espaço inicial para o botão de voltar.
            .frame(maxWidth: 520, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background {
            Color("Branco-Init")
            .background(TrailStyle.background)
            .ignoresSafeArea()
        }
        .overlay(alignment: .topLeading) {
            TrailMapBackButton()
                .padding(.leading, 16)
                .padding(.top, 8)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private func contentBox(_ text: String, background: Color = Color("Branco-Init")) -> some View {
        Text(text)
            .font(.system(size: 15))
            .lineSpacing(5)
            .foregroundStyle(TrailStyle.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(background, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color("AppShadow").opacity(0.04), radius: 8, y: 3)
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color("RoadmapPendingBadge").opacity(0.5), lineWidth: 1)
            }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color("SecondaryText"))
            content()
        }
    }
}

