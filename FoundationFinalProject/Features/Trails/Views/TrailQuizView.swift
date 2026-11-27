import SwiftUI

struct TrailQuizView: View {
    let trailKey: String
    let trailName: String

    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = TrailQuizStore()
    @State private var questionIndex = 0
    @State private var selectedOption: String?
    @State private var userAnswers: [String: String] = [:]
    @State private var finished = false

    private var score: Int {
        store.questions.reduce(0) { total, question in
            total + (userAnswers[question.id] == question.correctAnswer ? question.points : 0)
        }
    }

    private var question: TrailQuizQuestion? {
        guard store.questions.indices.contains(questionIndex) else { return nil }
        return store.questions[questionIndex]
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoading {
                    ProgressView("Carregando questionário…")
                } else if let error = store.errorMessage {
                    VStack(spacing: 16) {
                        Text(error).multilineTextAlignment(.center)
                        Button("Tentar novamente") {
                            Task { await store.load(for: trailKey) }
                        }
                        Button("Usar perguntas fictícias") {
                            store.loadSampleData()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if finished {
                    resultScreen
                } else if let question {
                    questionScreen(question)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 42))
                            .foregroundStyle(Color("Azul-Init"))
                        Text("Nenhuma pergunta carregada")
                            .font(.headline)
                            .foregroundStyle(Color("Azul-marinho-init"))
                        Text("Para testar com perguntas fictícias, ative TRAIL_QUIZ_DEMO=true nas variáveis de ambiente do Scheme do Xcode.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color("Azul-marinho-init"))
                        Button("Tentar novamente") {
                            Task { await store.load(for: trailKey) }
                        }
                        .buttonStyle(.borderedProminent)
                        Button("Usar perguntas fictícias") {
                            store.loadSampleData()
                        }
                    }
                    .padding(24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Branco-Init").ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .task { await store.load(for: trailKey) }
        }
        .tint(Color("Azul-Init"))
        .preferredColorScheme(.light)
    }

    private func questionScreen(_ question: TrailQuizQuestion) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if store.isUsingSampleData {
                    Label("Modo de demonstração", systemImage: "testtube.2")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("Azul-marinho-init"))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Text(trailName)
                    .font(.title2.bold())
                    .foregroundStyle(Color("Azul-Init"))
                Text("Pergunta \(questionIndex + 1) de \(store.questions.count)")
                    .font(.subheadline)
                    .foregroundStyle(Color("Azul-marinho-init"))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(question.prompt)
                    .font(.headline)
                    .foregroundStyle(Color("Azul-Init"))

                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    let letter = ["A", "B", "C", "D"][index]
                    optionButton(letter: letter, text: option, question: question)
                }
            }
            .padding(15)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        goBack()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(Color("Branco-Init"))
                        .frame(width: 58, height: 58)
                        .background(Color("Azul-Init"), in: Circle())
                }
                .accessibilityLabel("Pergunta anterior")
                .disabled(questionIndex == 0)
                .opacity(questionIndex == 0 ? 0.4 : 1)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        advance()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(Color("Branco-Init"))
                        .frame(width: 58, height: 58)
                        .background(Color("Azul-Init"), in: Circle())
                }
                .accessibilityLabel(questionIndex == store.questions.count - 1 ? "Ver resultado" : "Próxima pergunta")
                .disabled(selectedOption == nil)
                .opacity(selectedOption == nil ? 0.4 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(Color("Branco-Init"))
        }
    }

    private func optionButton(letter: String, text: String, question: TrailQuizQuestion) -> some View {
        let isSelected = selectedOption == letter
        return Button {
            selectedOption = letter
            userAnswers[question.id] = letter
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Text("\(letter))")
                Text(text).frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(Color("Branco-Init"))
            .padding(16)
            .background(isSelected ? Color("Azul-marinho-init") : Color("Azul-Init"),
                        in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var resultScreen: some View {
        let totalPoints = store.questions.reduce(0) { $0 + $1.points }
        let correctCount = store.questions.filter { userAnswers[$0.id] == $0.correctAnswer }.count
        let wrongCount = store.questions.count - correctCount

        return ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color("StatusDone"))
                    Text("Questionário concluído")
                        .font(.title2.bold())
                        .foregroundStyle(Color("Azul-Init"))
                    Text("Você fez \(score) de \(totalPoints) pontos")
                        .font(.headline)
                        .foregroundStyle(Color("Azul-marinho-init"))

                    HStack(spacing: 12) {
                        resultCount("Acertos", value: correctCount, color: Color("StatusDone"))
                        resultCount("Erros", value: wrongCount, color: Color("StatusBlocked"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color("AppClear"), in: RoundedRectangle(cornerRadius: 22))

                Text("Revisão das respostas")
                    .font(.title3.bold())
                    .foregroundStyle(Color("Azul-Init"))
                    .padding(.top, 4)

                ForEach(store.questions.indices, id: \.self) { index in
                    answerReview(store.questions[index], number: index + 1)
                }

            }
            .padding(20)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
    }

    private func resultCount(_ title: String, value: Int, color: Color) -> some View {
        HStack(spacing: 7) {
            Image(systemName: title == "Acertos" ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(color)
            Text("\(value) \(title.lowercased())")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("Azul-marinho-init"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color("Branco-Init"), in: Capsule())
    }

    private func answerReview(_ question: TrailQuizQuestion, number: Int) -> some View {
        let chosenAnswer = userAnswers[question.id] ?? ""
        let wasCorrect = chosenAnswer == question.correctAnswer

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pergunta \(number)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("Azul-Init"))
                Spacer()
                Label(wasCorrect ? "Acertou" : "Errou", systemImage: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(wasCorrect ? Color("StatusDone") : Color("StatusBlocked"))
            }
            Text(question.prompt)
                .font(.body.weight(.medium))
                .foregroundStyle(Color("Azul-marinho-init"))
            answerLine("Sua resposta", letter: chosenAnswer, question: question)
            if !wasCorrect {
                answerLine("Resposta correta", letter: question.correctAnswer, question: question)
            }
            if !question.explanation.isEmpty {
                Text(question.explanation)
                    .font(.subheadline)
                    .foregroundStyle(Color("Azul-marinho-init"))
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AppClear"), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(wasCorrect ? Color("StatusDone").opacity(0.4) : Color("StatusBlocked").opacity(0.4), lineWidth: 1)
        }
    }

    private func answerLine(_ title: String, letter: String, question: TrailQuizQuestion) -> some View {
        let text = optionText(letter, in: question)
        return VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("SecondaryText"))
            Text(letter.isEmpty ? "Não respondida" : "\(letter)) \(text)")
                .font(.subheadline)
                .foregroundStyle(Color("Azul-marinho-init"))
        }
    }

    private func optionText(_ letter: String, in question: TrailQuizQuestion) -> String {
        let letters = ["A", "B", "C", "D"]
        guard let index = letters.firstIndex(of: letter), question.options.indices.contains(index) else {
            return ""
        }
        return question.options[index]
    }

    private func advance() {
        guard let answer = selectedOption else { return }
        userAnswers[store.questions[questionIndex].id] = answer

        if questionIndex == store.questions.count - 1 {
            finished = true
        } else {
            questionIndex += 1
            selectedOption = userAnswers[store.questions[questionIndex].id]
        }
    }

    private func goBack() {
        guard questionIndex > 0 else { return }
        questionIndex -= 1
        selectedOption = userAnswers[store.questions[questionIndex].id]
    }
}
