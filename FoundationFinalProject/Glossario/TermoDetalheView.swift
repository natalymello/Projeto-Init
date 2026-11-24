import SwiftUI

struct TermoDetalheView: View {
    let termo: Termo
    @Environment(\.dismiss) private var fechar

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(termo.nome).font(.largeTitle.bold())
                    Text(termo.significado)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if !termo.area.isEmpty {
                        Text(termo.area)
                            .font(.caption)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("Azul-Init").opacity(0.1), in: Capsule())
                    }
                }
                .foregroundStyle(Color("Azul-Init"))
                .padding(24)
            }
            .background(Color("Branco-Init").ignoresSafeArea())
            .toolbarBackground(Color("Branco-Init"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar", systemImage: "xmark") { fechar() }
                }
            }
        }
        .presentationBackground(Color("Branco-Init"))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
