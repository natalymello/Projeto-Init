import SwiftUI

struct TrailQuizView: View {
    let trailKey: String
    let trailName: String

    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = TrailQuizStore()
    @State private var questionIndex = 0
    @State private var selectedOption: String?
    @State private var answered = false
    @State private var score = 0
    @State private var finished = false

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
                    optionButton(letter: letter, text: option)
                }

                if answered {
                    Text(selectedOption == question.correctAnswer ? "Correto! +\(question.points) pontos" : "A resposta certa era \(question.correctAnswer).")
                        .font(.headline)
                        .foregroundStyle(selectedOption == question.correctAnswer ? Color("StatusDone") : Color("StatusBlocked"))
                    if !question.explanation.isEmpty {
                        Text(question.explanation)
                            .foregroundStyle(Color("Azul-marinho-init"))
                    }
                    Button(questionIndex == store.questions.count - 1 ? "Ver resultado" : "Próxima pergunta") {
                        advance()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                } else {
                    Button("Responder") {
                        submit(question)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedOption == nil)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(15)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
    }

    private func optionButton(letter: String, text: String) -> some View {
        let isSelected = selectedOption == letter
        return Button {
            guard !answered else { return }
            selectedOption = letter
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
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 54))
                .foregroundStyle(Color("StatusDone"))
            Text("Questionário concluído")
                .font(.title2.bold())
                .foregroundStyle(Color("Azul-Init"))
            Text("Você fez \(score) de \(store.questions.reduce(0) { $0 + $1.points }) pontos.")
                .font(.headline)
                .foregroundStyle(Color("Azul-marinho-init"))
            Button("Fechar") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }

    private func submit(_ question: TrailQuizQuestion) {
        guard let selectedOption else { return }
        if selectedOption == question.correctAnswer {
            score += question.points
        }
        answered = true
    }

    private func advance() {
        if questionIndex == store.questions.count - 1 {
            finished = true
        } else {
            questionIndex += 1
            selectedOption = nil
            answered = false
        }
    }
}
