import SwiftUI

/// Mantém o quiz e as trilhas acessíveis, mesmo sem concluir o quiz.
struct InitRootView: View {
    private enum Tab: Hashable { case quiz, trails }
    @State private var selectedTab: Tab = .quiz
    @AppStorage("quiz.recommendedArea") private var savedRecommendation = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(onContinueToTrails: { _ in
                selectedTab = .trails
            })
                .tabItem { Label("Quiz", systemImage: "list.clipboard") }
                .tag(Tab.quiz)

            TrailsView(recommendedArea: QuizArea(rawValue: savedRecommendation))
                .tabItem { Label("Trilhas", systemImage: "point.topleft.down.to.point.bottomright.curvepath") }
                .tag(Tab.trails)
        }
    }
}

#Preview { InitRootView() }
