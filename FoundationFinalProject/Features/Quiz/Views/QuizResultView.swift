import SwiftUI

struct QuizResultView: View {
    let result: QuizResult
    let onContinueToTrails: (QuizArea) -> Void
    let restartQuiz: () -> Void

    @State private var resultProgress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Resultado
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                resultHeader
                VStack(alignment: .leading, spacing: 24) {
                    scoreSection
                    winningAnswersSection
                    areaDescription
                    Button { onContinueToTrails(result.winningArea) } label: {
                        Label("Continuar para as trilhas", systemImage: "arrow.right")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(Color("Branco-Init"))
                            .background(Color("Azul-Init"), in: Capsule())
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
            Color("Branco-Init").ignoresSafeArea()
        }
        .background(alignment: .top) {
            Color("Azul-Init")
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
                .fill(Color("Azul-Init"))
                .frame(height: 140)
                .background(alignment: .top) {
                    Color("Azul-Init")
                        .frame(height: 140)
                        .ignoresSafeArea(edges: .top)
                }
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("Branco-Init"))
                    .frame(width: 132, height: 132)
                    .overlay {
                        Image(systemName: resultSymbol)
                            .font(.system(size: 56, weight: .light))
                            .foregroundStyle(Color("Azul-Init"))
                    }
                    .shadow(color: Color("Azul-marinho-init").opacity(0.18), radius: 3, y: 4)
                    .offset(y: 34)
            }
            .padding(.bottom, 46)
            Text("Sua área sugerida...")
                .font(.system(size: 20))
                .padding(.bottom, 8)
            Text(result.winningArea.rawValue)
                .font(.system(size: 36, weight: .medium))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
            Text("\(result.winningScore) de \(result.totalWeight) pontos")
                .font(.subheadline)
                .foregroundStyle(Color("Azul-marinho-init"))
                .padding(.top, 8)
        }
        .foregroundStyle(Color("Azul-Init"))
    }

    private var resultSymbol: String {
        switch result.winningArea {
        case .frontend: return "rectangle.and.hand.point.up.left"
        case .backend: return "server.rack"
        case .uiux: return "paintpalette"
        case .cybersecurity: return "lock.shield"
        case .devops: return "gearshape.2"
        }
    }

    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(result.rankedAreas.prefix(3))) { area in
                let value = result.percentage(for: area) * resultProgress
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(area == result.winningArea
                             ? "Pontos no resultado sugerido"
                             : area.rawValue)
                            .font(.system(size: 12))
                        Spacer(minLength: 8)
                        Text(String(format: "%.1f%%", value))
                            .font(.system(size: 18))
                    }
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color("Azul-marinho-init").opacity(0.12))
                            Capsule()
                                .fill(Color("Turquesa-Init"))
                                .frame(width: geometry.size.width * CGFloat(value / 100))
                        }
                    }
                    .frame(height: 5)
                }
            }
            Text("Percentuais sobre os \(result.totalWeight) pontos distribuídos entre as áreas.")
                .font(.caption2)
                .foregroundStyle(Color("Azul-marinho-init"))
        }
        .foregroundStyle(Color("Azul-Init"))
    }

    private var winningAnswersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Você combina com a área porque:")
                .font(.system(size: 20))
                .foregroundStyle(Color("Azul-Init"))
                .fixedSize(horizontal: false, vertical: true)
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140), spacing: 18)],
                alignment: .leading,
                spacing: 18
            ) {
                ForEach(Array(result.winningAnswers.enumerated()), id: \.offset) { index, contribution in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 17))
                            .foregroundStyle(Color("Azul-Init"))
                            .frame(width: 30, height: 30)
                            .background(Color("Branco-Init"), in: Circle())
                        Text(contribution.answer)
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Pergunta \(contribution.questionID) · +\(contribution.points) pontos")
                            .font(.caption2)
                            .foregroundStyle(Color("Branco-Init").opacity(0.85))
                    }
                    .foregroundStyle(Color("Branco-Init"))
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
                    .background(Color("Azul-Init"), in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color("Azul-marinho-init").opacity(0.16), radius: 2, y: 3)
                }
            }
        }
    }

    private var areaDescription: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("O que é essa área?")
                .font(.system(size: 23))
                .foregroundStyle(Color("Azul-Init"))
            VStack(alignment: .leading, spacing: 18) {
                Text("Conhecendo \(result.winningArea.rawValue)")
                    .font(.system(size: 22, weight: .medium))
                Text(result.winningArea.description)
                    .font(.system(size: 16))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(Color("Branco-Init"))
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("Azul-Init"), in: RoundedRectangle(cornerRadius: 22))
            .shadow(color: Color("Azul-marinho-init").opacity(0.16), radius: 3, y: 3)
        }
    }

    private var restartButton: some View {
        Button(action: restartQuiz) {
            Label("Refazer quiz", systemImage: "arrow.clockwise")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color("Branco-Init"))
                .padding(.horizontal, 24)
                .padding(.vertical, 13)
                .background(Color("Azul-Init"), in: Capsule())
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
        while !Task.isCancelled {
            let elapsed = start.duration(to: clock.now)
            let fraction = min(elapsed / .seconds(1.5), 1)
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
}
