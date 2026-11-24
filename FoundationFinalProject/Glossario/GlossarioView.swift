import SwiftUI

struct GlossarioView: View {
    @StateObject private var vm = GlossarioViewModel()
    @State private var termoSelecionado: Termo?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if vm.carregando && vm.termos.isEmpty {
                        ProgressView("Carregando glossário…")
                            .frame(maxWidth: .infinity)
                    }
                    if let erro = vm.erro {
                        VStack(spacing: 12) {
                            Text(erro).multilineTextAlignment(.center)
                            Button("Tentar novamente") {
                                Task { await vm.carregar(atualizar: true) }
                            }
                            .disabled(vm.carregando)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    if vm.incompletos > 0 {
                        Text("\(vm.incompletos) registro(s) sem Palavra ou Definição não foram exibidos. Complete esses campos no Notion e atualize a lista.")
                            .font(.caption)
                            .foregroundStyle(Color("Azul-marinho-init"))
                    }
                    if !vm.termos.isEmpty {
                        if !vm.destaques.isEmpty {
                            Text("Termos em alta 🔥").font(.title2.bold())
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))]) {
                                ForEach(vm.destaques) { termo in botao(termo) }
                            }
                        }
                        Text("Termos").font(.title2.bold())
                        if vm.termosFiltrados.isEmpty {
                            ContentUnavailableView.search(text: vm.pesquisa)
                        }
                        ForEach(vm.gruposAlfabeticos, id: \.letra) { grupo in
                            VStack(alignment: .leading, spacing: 16) {
                                Text(grupo.letra)
                                    .font(.title.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilityAddTraits(.isHeader)
                                ForEach(grupo.termos) { termo in botao(termo) }
                            }
                        }
                    } else if !vm.carregando && vm.erro == nil {
                        ContentUnavailableView(
                            vm.incompletos > 0 ? "Nenhum termo completo" : "Nenhum termo cadastrado",
                            systemImage: "book.closed",
                            description: Text("Adicione palavras e definições na fonte glossario do Notion.")
                        )
                    }
                }
                .foregroundStyle(Color("Azul-Init"))
                .padding(24)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
            .background(Color("Branco-Init"))
            .navigationTitle("Glossário")
            .searchable(text: $vm.pesquisa, prompt: "Pesquise termos aqui")
            .task { await vm.carregar() }
            .refreshable { await vm.carregar(atualizar: true) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Atualizar", systemImage: "arrow.clockwise") {
                        Task { await vm.carregar(atualizar: true) }
                    }
                    .disabled(vm.carregando)
                }
            }
            .sheet(item: $termoSelecionado) { termo in
                TermoDetalheView(termo: termo)
            }
        }
    }

    private func botao(_ termo: Termo) -> some View {
        Button { termoSelecionado = termo } label: {
            Text(termo.nome)
                .font(.title3)
                .foregroundStyle(Color("Branco-Init"))
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("Azul-Init"), in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}
