import SwiftUI

struct InitRootView: View {
    @AppStorage("quiz.recommendedArea") private var savedRecommendation = ""

    var body: some View {
        TabView {
            TrailsView(recommendedArea: QuizArea(rawValue: savedRecommendation))
                .tabItem { Label("Trilhas", systemImage: "signpost.right.and.left") }
            GlossarioView()
                .tabItem { Label("Glossário", systemImage: "text.book.closed") }
        }
        .tint(Color("Azul-Init"))
        .preferredColorScheme(.light)
    }
}

#Preview { InitRootView() }
