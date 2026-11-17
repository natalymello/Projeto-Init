import SwiftUI

struct TrailsView: View {
    var recommendedArea: QuizArea? = nil
    @StateObject private var store = TrailsStore()

    private var featured: NotionTrail? {
        guard let area = recommendedArea else { return nil }
        return store.trails.first {
            TrailStyle.symbol(name: $0.name) == TrailStyle.symbol(name: area.rawValue)
        }
    }

    private var remaining: [NotionTrail] {
        store.trails.filter { $0.id != featured?.id }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if store.loading { ProgressView("Carregando trilhas…").padding(.top, 50) }
                    if let error = store.errorMessage {
                        VStack(spacing: 16) {
                            Text(error).multilineTextAlignment(.center)
                            Button("Tentar novamente") { Task { await store.load() } }
                        }.padding()
                    }
                    if !store.loading && store.errorMessage == nil && store.trails.isEmpty {
                        ContentUnavailableView("Nenhuma trilha encontrada", systemImage: "map")
                    }
                    if let featured {
                        card(featured, featured: true)
                    }
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 20) {
                        ForEach(remaining) { trail in card(trail) }
                    }
                }
                .frame(maxWidth: 390)
                .padding(.horizontal, 24)
                .padding(.top, 55)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .background(TrailStyle.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .refreshable { await store.load() }
            .task { if store.trails.isEmpty { await store.load() } }
        }
        .tint(TrailStyle.blue)
        .preferredColorScheme(.light)
    }

    private func card(_ trail: NotionTrail, featured: Bool = false) -> some View {
        NavigationLink {
            RoadmapView(trail: trail, store: store)
        } label: {
            TrailSelectionCard(name: trail.name, symbol: TrailStyle.symbol(name: trail.name, fallback: trail.icon), featured: featured)
        }
        .buttonStyle(.plain)
    }
}

#Preview { TrailsView() }
