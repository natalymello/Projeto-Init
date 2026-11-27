import SwiftUI

struct InitRootView: View {
    private enum StartupScreen {
        case loading, onboarding, quiz, main
    }

    @State private var screen: StartupScreen = .loading
    @AppStorage("onboarding.completed.v2") private var onboardingCompleted = false
    @AppStorage("quiz.recommendedArea") private var savedRecommendation = ""

    var body: some View {
        Group {
            switch screen {
            case .loading:
                InitLoadingView()
                    .task {
                        do {
                            try await Task.sleep(for: .milliseconds(700))
                            screen = onboardingCompleted ? .main : .onboarding
                        } catch {
                            return
                        }
                    }
            case .onboarding:
                InitOnboardingView(
                    onSkip: {
                        onboardingCompleted = true
                        screen = .main
                    },
                    onContinue: {
                        screen = .quiz
                    }
                )
            case .quiz:
                QuizView { _ in
                    onboardingCompleted = true
                    screen = .main
                }
            case .main:
                mainTabs
            }
        }
        .tint(Color("Azul-Init"))
        .preferredColorScheme(.light)
    }

    private var mainTabs: some View {
        TabView {
            TrailsView(recommendedArea: QuizArea(rawValue: savedRecommendation))
                .tabItem { Label("Trilhas", systemImage: "signpost.right.and.left") }
            GlossarioView()
                .tabItem { Label("Glossário", systemImage: "text.book.closed") }
        }
    }
}

#Preview { InitRootView() }
