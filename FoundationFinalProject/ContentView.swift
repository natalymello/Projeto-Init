import SwiftUI

// Cada aba abre uma funcionalidade do mesmo aplicativo.
struct ContentView: View {
    var body: some View {
        TabView {
            QuizView()
                .tabItem { Label("Quiz", systemImage: "list.clipboard") }
            GlossarioView()
                .tabItem { Label("Glossário", systemImage: "book") }
        }
        .tint(.quizBlue)
    }
}

#Preview {
    ContentView()
}
