import SwiftUI

struct InitLoadingView: View {
    var body: some View {
        ZStack {
            Color("Branco-Init").ignoresSafeArea()

            Image(systemName: "desktopcomputer")
                .font(.system(size: 51, weight: .regular))
                .foregroundStyle(Color("Azul-Init"))
                .overlay(alignment: .top) {
                    Text("Init")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("Branco-Init"))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color("Azul-Init"), in: RoundedRectangle(cornerRadius: 4))
                        .padding(.top, 9)
                }
                .accessibilityLabel("Carregando Init")
        }
    }
}

#Preview { InitLoadingView() }
