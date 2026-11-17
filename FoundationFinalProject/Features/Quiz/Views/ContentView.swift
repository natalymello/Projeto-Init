import SwiftUI

struct ContentView: View {
    @AppStorage("quiz.recommendedArea") private var savedRecommendation = ""
    let onContinueToTrails: (QuizArea) -> Void


    // Estado: escolhas do usuário e controle da tela.
    @StateObject private var vm = QuizViewModel()
    @State private var currentQuestion = 0
    @State private var userAnswers: [Int?] = Array(repeating: nil, count: 5)
    @State private var showResult = false
    @State private var resultProgress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var totalWeight: Int {
        questions.reduce(0) { $0 + $1.weight }
    }

    private var questions: [QuizQuestion] { vm.questions }

    // MARK: - Pontuação
    private var scores: [QuizArea: Int] {
        var result: [QuizArea: Int] = [:]
        // Inicializa todas as áreas com zero
        for area in QuizArea.allCases {
            result[area] = 0
        }
        // Percorre as respostas selecionadas
        for questionIndex in questions.indices {
            guard let answerIndex = userAnswers[questionIndex] else { continue }
            let question = questions[questionIndex]
            let selectedOption = question.options[answerIndex]
            // Soma o peso da pergunta à área escolhida
            result[selectedOption.area, default: 0] += question.weight
        }
        return result
    }

    private var rankedAreas: [QuizArea] {
        let totals = scores
        return QuizArea.allCases.sorted { first, second in
            let firstScore = totals[first, default: 0]
            let secondScore = totals[second, default: 0]
            if firstScore != secondScore {
                return firstScore > secondScore
            }
            // Desempate visual determinístico.
            // Áreas sem pontos podem empatar; o vencedor final não empata.
            return first.rawValue < second.rawValue
        }
    }

    private var winningArea: QuizArea {
        rankedAreas[0]
    }

    private var winningScore: Int {
        scores[winningArea, default: 0]
    }

    private func percentage(for area: QuizArea) -> Double {
        guard totalWeight > 0 else { return 0 }
        let points = scores[area, default: 0]
        return Double(points) / Double(totalWeight) * 100
    }

    private var winningAnswers: [(question: String, answer: String, points: Int)] {
        var contributions: [(question: String, answer: String, points: Int)] = []
        for questionIndex in questions.indices {
            guard let answerIndex = userAnswers[questionIndex]
            else {
                continue
            }
            let question = questions[questionIndex]
            let option = question.options[answerIndex]
            if option.area == winningArea {
                contributions.append(
                    (
                        question: "Pergunta \(question.id)",
                        answer: option.text,
                        points: question.weight
                    )
                )
            }
        }
        return Array(contributions.sorted { $0.points > $1.points }.prefix(2))
    }

    // MARK: - Tela e navegação
    var body: some View {
        ZStack {
            Color.quizBackground
                .ignoresSafeArea()
            Group {
                if vm.isLoading || (vm.questions.isEmpty && vm.errorMessage == nil) {
                    ProgressView("Carregando perguntas…")
                } else if let error = vm.errorMessage {
                    VStack(spacing: 16) {
                        Text(error).multilineTextAlignment(.center)
                        Button("Tentar novamente") { Task { await vm.load() } }
                    }.padding()
                } else if showResult {
                    resultScreen
                        .transition(.opacity)
                } else {
                    quizScreen
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task { await vm.load() }
        .preferredColorScheme(.light)
    }

    private var quizScreen: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Text("Pergunta \(currentQuestion + 1) de \(questions.count)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.quizGray)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 15)
                    Text(questions[currentQuestion].title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.quizBlue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                        .background(Color.appWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(spacing: 10) {
                        ForEach(questions[currentQuestion].options.indices, id: \.self) { index in
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
                .background(Color.quizBackground)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "note.text")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.quizBlue)
                Text("Quiz")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.quizBlue)
            }
            Text("Faça o quiz e descubra sua área ideal da tecnologia.")
                .font(.system(size: 14))
                .foregroundColor(Color.quizBodyText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private func optionButton(index: Int) -> some View {
        let option = questions[currentQuestion].options[index]
        let isSelected = userAnswers[currentQuestion] == index
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                userAnswers[currentQuestion] = index
            }
        } label: {
            Text("\(option.letter)) \(option.text)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.appWhite)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    isSelected ? Color.quizBlue : Color.quizOption
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.appWhite : Color.appClear,
                            lineWidth: 2
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.appShadow.opacity(0.15), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var navigationButtons: some View {
        HStack {
            if currentQuestion > 0 {
                Button {
                    previousQuestion()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.appWhite)
                        .frame(width: 44, height: 44)
                        .background(Color.quizBlue)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Pergunta anterior")
            }
            Spacer()
            Button {
                nextQuestion()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.appWhite)
                    .frame(width: 44, height: 44)
                    .background(Color.quizBlue)
                    .clipShape(Circle())
            }
            .disabled(userAnswers[currentQuestion] == nil)
            .opacity(userAnswers[currentQuestion] == nil ? 0.45 : 1)
            .accessibilityLabel(
                currentQuestion == questions.count - 1
                ? "Ver resultado"
                : "Próxima pergunta"
            )
        }
    }

    private func nextQuestion() {
        guard userAnswers[currentQuestion] != nil else {
            return
        }
        if currentQuestion < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentQuestion += 1
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                savedRecommendation = winningArea.rawValue
                showResult = true
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

    // MARK: - Resultado
    private var resultScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                resultHeader
                VStack(alignment: .leading, spacing: 24) {
                    scoreSection
                    winningAnswersSection
                    areaDescription
                    Button { onContinueToTrails(winningArea) } label: {
                        Label("Continuar para as trilhas", systemImage: "arrow.right")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(Color.appWhite)
                            .background(Color.quizBlue, in: Capsule())
                    }
                    restartButton
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
        }
        .task { await animateResult() }
        .background {
            Color.quizResultBackground.ignoresSafeArea()
        }
        .background(alignment: .top) {
            Color.quizResultBlue
                .frame(height: 100)
                .ignoresSafeArea(edges: .top)
        }
    }

    private var resultHeader: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 24,
                    bottomTrailingRadius: 24
                )
                .fill(Color.quizResultBlue)
                .frame(height: 140)
                .background(alignment: .top) {
                    Color.quizResultBlue
                        .frame(height: 140)
                        .ignoresSafeArea(edges: .top)
                }
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.quizResultIconBackground)
                    .frame(width: 132, height: 132)
                    .overlay {
                        Image(systemName: resultSymbol)
                            .font(.system(size: 56, weight: .light))
                            .foregroundStyle(Color.quizResultBlue)
                    }
                    .shadow(color: Color.appShadow.opacity(0.18), radius: 3, y: 4)
                    .offset(y: 34)
            }
            .padding(.bottom, 46)
            Text("Sua área sugerida...")
                .font(.system(size: 20))
                .padding(.bottom, 8)
            Text(winningArea.rawValue)
                .font(.system(size: 36, weight: .medium))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
            Text("\(winningScore) de \(totalWeight) pontos")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .padding(.top, 8)
        }
        .foregroundStyle(Color.quizResultBlue)
    }

    private var resultSymbol: String {
        switch winningArea {
        case .frontend: return "rectangle.and.hand.point.up.left"
        case .backend: return "server.rack"
        case .uiux: return "paintpalette"
        case .cybersecurity: return "lock.shield"
        case .devops: return "gearshape.2"
        }
    }

    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(rankedAreas.prefix(3))) { area in
                let value = percentage(for: area) * resultProgress
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(area == winningArea
                             ? "Pontos no resultado sugerido"
                             : area.rawValue)
                            .font(.system(size: 12))
                        Spacer(minLength: 8)
                        Text(String(format: "%.1f%%", value))
                            .font(.system(size: 18))
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.appShadow.opacity(0.12))
                            Capsule()
                                .fill(Color.quizProgressFill)
                                .frame(width: geometry.size.width * CGFloat(value / 100))
                        }
                    }
                    .frame(height: 5)
                }
            }
            Text("Percentuais sobre os 51 pontos distribuídos entre as áreas.")
                .font(.caption2)
                .foregroundStyle(Color.secondaryText)
        }
        .foregroundStyle(Color.quizResultBlue)
    }

    private var winningAnswersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Você combina com a área porque:")
                .font(.system(size: 20))
                .foregroundStyle(Color.quizResultBlue)
                .fixedSize(horizontal: false, vertical: true)
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140), spacing: 18)],
                alignment: .leading,
                spacing: 18
            ) {
                ForEach(Array(winningAnswers.enumerated()), id: \.offset) { index, contribution in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.quizResultBlue)
                            .frame(width: 30, height: 30)
                            .background(Color.appWhite, in: Circle())
                        Text(contribution.answer)
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(contribution.question) · +\(contribution.points) pontos")
                            .font(.caption2)
                            .foregroundStyle(Color.appWhite.opacity(0.85))
                    }
                    .foregroundStyle(Color.appWhite)
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
                    .background(Color.quizResultCard, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.appShadow.opacity(0.16), radius: 2, y: 3)
                }
            }
        }
    }

    private var areaDescription: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("O que é essa área?")
                .font(.system(size: 23))
                .foregroundStyle(Color.quizResultBlue)
            VStack(alignment: .leading, spacing: 18) {
                Text("Conhecendo \(winningArea.rawValue)")
                    .font(.system(size: 22, weight: .medium))
                Text(winningArea.description)
                    .font(.system(size: 16))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(Color.appWhite)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.quizResultBlue, in: RoundedRectangle(cornerRadius: 22))
            .shadow(color: Color.appShadow.opacity(0.16), radius: 3, y: 3)
        }
    }

    private var restartButton: some View {
        Button(action: restartQuiz) {
            Label("Refazer quiz", systemImage: "arrow.clockwise")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.appWhite)
                .padding(.horizontal, 24)
                .padding(.vertical, 13)
                .background(Color.quizResultBlue, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Animação e reinício
    // O mesmo progresso controla a largura das barras e o percentual.

    @MainActor
    private func animateResult() async {
        resultProgress = 0
        guard !reduceMotion else {
            resultProgress = 1
            return
        }
        let clock = ContinuousClock()
        let start = clock.now
        let duration = 1.5
        while !Task.isCancelled {
            let elapsed = start.duration(to: clock.now).components
            let seconds = Double(elapsed.seconds)
                + Double(elapsed.attoseconds) / 1_000_000_000_000_000_000
            let fraction = min(max(seconds / duration, 0), 1)
            // Começa devagar, acelera e desacelera no final.
            resultProgress = fraction * fraction * (3 - 2 * fraction)
            if fraction >= 1 { return }
            do {
                try await Task.sleep(for: .milliseconds(16))
            } catch {
                return
            }
        }
    }

    private func restartQuiz() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentQuestion = 0
            userAnswers = Array(repeating: nil, count: questions.count)
            resultProgress = 0
            showResult = false
        }
    }
}

#Preview("iPhone 17") {
    InitRootView()
}
