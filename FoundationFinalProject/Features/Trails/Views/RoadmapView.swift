import SwiftUI

struct RoadmapView: View {
    let trail: NotionTrail
    @ObservedObject var store: TrailsStore
    @State private var orientation: RoadmapOrientation = .vertical
    @State private var edgeShape: EdgeShape = .straight
    @State private var dashed = false
    @State private var showArrows = false
    @State private var colorByStatus = false
    @State private var savedStatuses: [String: String] = [:]

    private var currentTrail: NotionTrail {
        store.trails.first { $0.key == trail.key } ?? trail
    }
    private var nodes: [NotionNode] {
        var seen = Set<String>()
        return currentTrail.nodes.sorted {
            (Int(trimmed($0.order)) ?? Int.max) < (Int(trimmed($1.order)) ?? Int.max)
        }.filter { !$0.localID.isEmpty && seen.insert($0.localID).inserted }
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
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
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { loadStatuses() }
        .onChange(of: currentTrail.key) { loadStatuses() }
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
        let layout = TrailLayout.compute(for: nodes, orientation: orientation, container: container)
        let edges = TrailLayout.edges(for: nodes, layout: layout, orientation: orientation, statusForNode: status)
        return ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    for edge in edges {
                        let path = TrailLayout.edgePath(start: edge.start, end: edge.end, orientation: orientation, shape: edgeShape)
                        let color = colorByStatus ? (edge.status?.color.opacity(0.85) ?? RoadmapTheme.line) : RoadmapTheme.line
                        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: edge.lateral ? 4 : 5, lineCap: .round, lineJoin: .round, dash: dashed ? [8, 6] : []))
                        if showArrows {
                            let angle = TrailLayout.arrowAngle(start: edge.start, end: edge.end, orientation: orientation, shape: edgeShape)
                            context.fill(TrailLayout.arrowHead(at: edge.end, angle: angle, size: 12), with: .color(color))
                        }
                    }
                }
                .frame(width: layout.canvas.width, height: layout.canvas.height)
                TrailHeaderCard(title: currentTrail.name, icon: TrailStyle.symbol(name: currentTrail.name, fallback: currentTrail.icon))
                    .position(layout.positions[TrailLayout.startKey] ?? .zero)
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
                TrailEndPill()
                    .position(layout.positions[TrailLayout.endKey] ?? .zero)
            }
            .frame(width: layout.canvas.width, height: layout.canvas.height)
        }
        .scrollBounceBehavior(.basedOnSize)
        .id("\(currentTrail.key)-\(orientation == .vertical)")
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            TrailMapBackButton()
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
    }

    
    @ViewBuilder private var legendItems: some View {
        ForEach(NodeStatus.allCases, id: \.rawValue) { status in
            HStack(spacing: 5) {
                Circle().fill(status.color).frame(width: 10, height: 10)
                Text(status.label).font(.caption).foregroundStyle(RoadmapTheme.sideText)
            }
        }
    }
}
