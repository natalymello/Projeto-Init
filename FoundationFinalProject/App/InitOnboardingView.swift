import SwiftUI

struct InitOnboardingView: View {
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Button("Pular", action: onSkip)
                        .font(.headline)
                        .frame(minWidth: 44, minHeight: 44)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 12)

                    Spacer(minLength: 32)
                    introduction
                        .padding(.horizontal, 12)

                    Spacer(minLength: 36)
                    features

                    Spacer(minLength: 48)
                    startButton
                    Spacer(minLength: 32)
                }
                .frame(maxWidth: 440)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Color("Branco-Init").ignoresSafeArea())
        .foregroundStyle(Color("Azul-marinho-init"))
    }

    private var introduction: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Seu início na tecnologia começa aqui!")
                .multilineTextAlignment(.center)
                .font(.title.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 50)
    }
    private var features: some View {
        VStack(alignment: .leading, spacing: 50) {
            feature("Descubra sua área", detail: "Responda ao quiz e descubra o seu caminho ideal no universo da tecnologia.", symbol: "target")
            feature("Explore a tecnologia", detail: "Consulte o glossário e entenda os termos técnicos, descomplique seu aprendizado.", symbol: "book.closed")
            feature("Estude e trace sua trilha", detail: "Explore as trilhas, organize seus estudos e aprimore seu conhecimento.", symbol: "signpost.right.and.left")
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
        .padding(.horizontal, 20)
        .padding(.vertical, 32)
        .foregroundStyle(Color("Branco-Init"))
        .background(Color("Azul-Init"), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color("Azul-marinho-init").opacity(0.22), radius: 3, y: 3)
    }

    private func feature(_ title: String, detail: String, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 32))
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.title3.weight(.semibold))
                Text(detail).font(.footnote)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var startButton: some View {
        Button(action: onContinue) {
            HStack(spacing: 8) {
                Text("Começar minha jornada")
                Image(systemName: "arrow.right")
                    .accessibilityHidden(true)
            }
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .foregroundStyle(Color("Branco-Init"))
            .background(Color("Azul-Init"), in: Capsule())
            .shadow(color: Color("Azul-marinho-init").opacity(0.25), radius: 3, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview { InitOnboardingView(onSkip: {}, onContinue: {}) }
