import SwiftUI

struct QuizView: View {
    @AppStorage("quiz.recommendedArea") private var savedRecommendation = ""
    let onContinueToTrails: (QuizArea) -> Void

    @StateObject private var viewModel = QuizViewModel()
    @State private var currentQuestion = 0
    // A chave é o número da pergunta e o valor é o índice da alternativa escolhida.
    @State private var userAnswers: [Int: Int] = [:]
    @State private var result: QuizResult?

    private var questions: [QuizQuestion] { viewModel.questions }

    private var activeQuestion: QuizQuestion { questions[currentQuestion] }

    // MARK: - Tela e navegação
    var body: some View {
        ZStack {
            Color("Branco-Init")
                .ignoresSafeArea()
            Group {
                if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text(error).multilineTextAlignment(.center)
                        Button("Tentar novamente") { Task { await viewModel.load() } }
                    }.padding()
                } else if questions.isEmpty {
                    ProgressView("Carregando perguntas…")
                } else if let result {
                    QuizResultView(result: result, onContinueToTrails: onContinueToTrails, restartQuiz: restartQuiz)
                        .transition(.opacity)
                } else {
                    quizScreen
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task { await viewModel.load() }
        .preferredColorScheme(.light)
    }

    private var quizScreen: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Text("Pergunta \(currentQuestion + 1) de \(questions.count)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("Azul-marinho-init"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 15)
                    Text(activeQuestion.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("Azul-Init"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                        .background(Color("Branco-Init"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(spacing: 10) {
                        ForEach(activeQuestion.options.indices, id: \.self) { index in
                            optionButton(index: index)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: 430)
        .frame(maxWidth: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            navigationButtons
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color("Branco-Init"))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "note.text")
                    .font(.system(size: 30, weight: .medium))
                Text("Quiz")
                    .font(.system(size: 28, weight: .bold))
            }
            .foregroundColor(Color("Azul-Init"))
            Text("Faça o quiz e descubra sua área ideal da tecnologia.")
                .font(.system(size: 14))
                .foregroundColor(Color("Azul-marinho-init"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private func optionButton(index: Int) -> some View {
        let option = activeQuestion.options[index]
        let isSelected = userAnswers[activeQuestion.id] == index
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                userAnswers[activeQuestion.id] = index
            }
        } label: {
            Text("\(option.letter)) \(option.text)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color("Branco-Init"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(isSelected ? Color("TrailSide") : Color("Azul-Init"))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color("Branco-Init") : Color.appClear,
                            lineWidth: 2
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color("Azul-marinho-init").opacity(0.15), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var navigationButtons: some View {
        HStack {
            if currentQuestion > 0 {
                Button(action: previousQuestion) { arrow("chevron.left") }
                    .accessibilityLabel("Pergunta anterior")
            }
            Spacer()
            Button(action: nextQuestion) { arrow("chevron.right") }
                .disabled(userAnswers[activeQuestion.id] == nil)
                .opacity(userAnswers[activeQuestion.id] == nil ? 0.45 : 1)
                .accessibilityLabel(
                    currentQuestion == questions.count - 1
                    ? "Ver resultado"
                    : "Próxima pergunta"
                )
        }
    }

    private func arrow(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(Color("Branco-Init"))
            .frame(width: 44, height: 44)
            .background(Color("Azul-Init"), in: Circle())
    }

    private func nextQuestion() {
        guard userAnswers[activeQuestion.id] != nil else {
            return
        }
        if currentQuestion < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentQuestion += 1
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                let completedQuiz = QuizResult(questions: questions, answers: userAnswers)
                savedRecommendation = completedQuiz.winningArea.rawValue
                result = completedQuiz
            }
        }
    }

    private func previousQuestion() {
        guard currentQuestion > 0 else {
            return
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            currentQuestion -= 1
        }
    }

    private func restartQuiz() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentQuestion = 0
            userAnswers.removeAll()
            result = nil
        }
    }
}

#Preview("iPhone 17") {
    InitRootView()
}
