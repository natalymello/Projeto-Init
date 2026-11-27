import SwiftUI

struct RoadmapView: View {
    let trail: NotionTrail
    @ObservedObject var store: TrailsStore
    @State private var savedStatuses: [String: String] = [:]
    @State private var showingTrailQuiz = false

    private var currentTrail: NotionTrail {
        store.trails.first { $0.key == trail.key } ?? trail
    }
    private var nodes: [NotionNode] {
        var seen = Set<String>()
        return currentTrail.nodes.sorted {
            (Int(trimmed($0.order)) ?? Int.max) < (Int(trimmed($1.order)) ?? Int.max)
        }.filter { !$0.localID.isEmpty && seen.insert($0.localID).inserted }
    }

    private var canTakeQuiz: Bool {
        !nodes.isEmpty && nodes.allSatisfy { status(for: $0) == .done }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let error = store.errorMessage {
                Text(error).font(.caption).foregroundStyle(Color("Azul-marinho-init")).padding(.horizontal)
            }
            if nodes.isEmpty {
                ContentUnavailableView("Esta trilha não possui conteúdos", systemImage: "map")
            } else {
                GeometryReader { geometry in
                    canvas(container: geometry.size)
                }
            }
        }
        .background(Color("Branco-Init").ignoresSafeArea())
        .navigationTitle(currentTrail.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { loadStatuses() }
        .onChange(of: currentTrail.key) { loadStatuses() }
        .onChange(of: nodes.map(\.localID)) { loadStatuses() }
        .sheet(isPresented: $showingTrailQuiz) {
            TrailQuizView(trailKey: currentTrail.key, trailName: currentTrail.name)
        }
        .preferredColorScheme(.light)
    }

    private func storageKey(_ node: NotionNode) -> String {
        "roadmap.mvp.\(trimmed(currentTrail.key))/\(node.localID)"
    }
    private func loadStatuses() {
        savedStatuses = Dictionary(nodes.map { ($0.localID, UserDefaults.standard.string(forKey: storageKey($0)) ?? "") }, uniquingKeysWith: { first, _ in first })
    }
    private func status(for node: NotionNode) -> NodeStatus {
        let saved = savedStatuses[node.localID] ?? ""
        return NodeStatus(saved.isEmpty ? node.status : saved)
    }

    private func canvas(container: CGSize) -> some View {
        let layout = TrailLayout.compute(for: nodes, container: container)
        let edges = TrailLayout.edges(for: nodes, layout: layout)
        return ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    for edge in edges {
                        let path = TrailLayout.edgePath(start: edge.start, end: edge.end)
                        context.stroke(path, with: .color(RoadmapTheme.line), style: StrokeStyle(lineWidth: edge.lateral ? 4 : 5, lineCap: .round, lineJoin: .round))
                    }
                }
                .frame(width: layout.canvas.width, height: layout.canvas.height)
                ForEach(nodes) { node in
                    NavigationLink {
                        TrailNodeDetailView(node: node, trailKey: currentTrail.key, trailNodes: nodes)
                    } label: {
                        RoadmapNodeView(node: node, status: status(for: node))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(node.name), \(status(for: node).label)")
                    .position(layout.positions[node.localID] ?? .zero)
                }
                TrailEndPill(isLocked: !canTakeQuiz) { showingTrailQuiz = true }
                    .position(layout.positions[TrailLayout.endKey] ?? .zero)
            }
            .frame(width: layout.canvas.width, height: layout.canvas.height)
        }
        .defaultScrollAnchor(.top)
        .scrollBounceBehavior(.basedOnSize)
        .id(currentTrail.key)
    }

}
