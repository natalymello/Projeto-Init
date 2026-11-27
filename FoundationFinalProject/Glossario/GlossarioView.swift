import SwiftUI

struct GlossarioView: View {
    @StateObject private var vm = GlossarioViewModel()
    @State private var termoSelecionado: Termo?
    private let margem: CGFloat = 24

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

                    if !vm.termos.isEmpty {
                        if !vm.tags.isEmpty {
                            filtroPorTag
                                .padding(.horizontal, -margem)
                        }
                        if !vm.destaques.isEmpty {
                            Text("Termos em alta").font(.title2.bold())
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
                .padding(margem)
                .frame(maxWidth: .infinity)
            }
            .background(Color("Branco-Init"))
            .navigationTitle("Glossário")
            .searchable(text: $vm.pesquisa, prompt: "Pesquise termos aqui")
            .task { await vm.carregar() }
            .refreshable { await vm.carregar(atualizar: true) }
            .sheet(item: $termoSelecionado) { termo in
                TermoDetalheView(termo: termo)
            }
        }
    }

    private var filtroPorTag: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                opcaoDeFiltro("Todos", tag: nil)
                ForEach(vm.tags, id: \.self) { tag in
                    opcaoDeFiltro(tag, tag: tag)
                }
            }
        }
        .defaultScrollAnchor(.leading)
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Filtrar por tag")
    }

    private func opcaoDeFiltro(_ titulo: String, tag: String?) -> some View {
        let selecionado = vm.tagSelecionada == tag

        return Button {
            vm.tagSelecionada = tag
        } label: {
            Text(titulo)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .foregroundStyle(selecionado ? Color("Branco-Init") : Color("Azul-Init"))
                .background {
                    if selecionado {
                        Capsule().fill(Color("Azul-Init"))
                    } else {
                        Capsule().fill(.quaternary)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selecionado ? .isSelected : [])
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
