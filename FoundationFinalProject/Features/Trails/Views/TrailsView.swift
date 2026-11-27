import SwiftUI

struct TrailsView: View {
    var recommendedArea: QuizArea? = nil
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var mostrandoQuiz = false
    @StateObject private var store = TrailsStore()
    
    private var featured: NotionTrail? {
        guard let area = recommendedArea else { return nil }
        return store.trails.first {
            TrailStyle.symbol(name: $0.name) == TrailStyle.symbol(name: area.rawValue)
        }
    }
    
    private var remaining: [NotionTrail] {
        let ordem = ["terminal", "macwindow.and.cursorarrow", "lock.shield", "paintbrush.pointed", "infinity"]
        return store.trails.filter { $0.id != featured?.id }.sorted { a, b in
            let primeiro = ordem.firstIndex(of: TrailStyle.symbol(name: a.name)) ?? ordem.count
            let segundo = ordem.firstIndex(of: TrailStyle.symbol(name: b.name)) ?? ordem.count
            return primeiro < segundo
        }
    }
    
    var body: some View {
        let trails = remaining
        let columnSpacing: CGFloat = 16
        let centeredTrailID = recommendedArea == nil && !trails.count.isMultiple(of: 2)
        ? trails.last?.id
        : nil
        let direction: CGFloat = layoutDirection == .leftToRight ? 1 : -1
        
        NavigationStack {
            ScrollView {                    if recommendedArea == nil {
                // Botão para descobrir a trilha ideal
                Button {
                    mostrandoQuiz = true
                } label: {
                    Label(
                        "Descubra sua trilha ideal",
                        systemImage: "list.clipboard"
                    )
                    .font(.title3.bold())
                    .frame(maxWidth: 350)
                    .padding(.vertical, 25)
                    .foregroundStyle(Color("Branco-Init"))
                    .background(TrailStyle.gradient, in: Capsule())
                }
                .buttonStyle(.plain)}
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
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: columnSpacing), GridItem(.flexible())], spacing: 20) {
                        ForEach(trails) { trail in
                            card(trail)
                                .visualEffect { content, geometry in
                                    content.offset(x: trail.id == centeredTrailID
                                                   ? direction * (geometry.size.width + columnSpacing) / 2
                                                   : 0)
                                }
                        }
                    }
                    
                    
                    if recommendedArea != nil{
                        // Botão menor para refazer o quiz
                        Button {
                            mostrandoQuiz = true
                        } label: {
                            Label(
                                "Refazer quiz",
                                systemImage: "arrow.clockwise"
                            )
                            .font(.title3)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                            .foregroundStyle(Color("Branco-Init"))
                            .background(TrailStyle.gradient, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                    }
                }
                .frame(maxWidth: 390)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .background(TrailStyle.background.ignoresSafeArea())
            .navigationTitle("Trilhas")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await store.load() }
            .task { if store.trails.isEmpty { await store.load() } }
        }
        .sheet(isPresented: $mostrandoQuiz) {
            NavigationStack {
                QuizView { _ in mostrandoQuiz = false }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Fechar") { mostrandoQuiz = false }
                        }
                    }
            }
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
