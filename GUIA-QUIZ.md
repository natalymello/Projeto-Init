# Como apresentar o quiz

Comece em Trilhas e abra o quiz. Acompanhe uma resposta desde a consulta ao Notion até o cartão que explica a recomendação.

| Arquivo | O que mostrar na apresentação |
| --- | --- |
| InitRootView.swift | Reúne as abas Trilhas e Glossário. |
| TrailsView.swift | Abre o quiz e destaca a trilha recomendada. |
| QuizViewModel.swift | Busca as perguntas e alternativas no Notion e informa quando estão prontas. |
| QuizModels.swift | Define o que cada pergunta e alternativa guarda. |
| QuizView.swift | Mostra uma pergunta por vez e guarda a escolha de cada uma. |
| QuizResult.swift | Soma os pontos e escolhe as duas respostas mais importantes para a área vencedora. |
| QuizResultView.swift | Mostra a recomendação, anima as barras e oferece continuar ou refazer. |

**Exemplo para falar em voz alta.** “Se eu escolher alternativas de Design nas perguntas 1, 2 e 4, elas valem 6, 9 e 12 pontos. Se as outras respostas forem de DevOps, Design ganha com 27 dos 51 pontos. A barra chega a 52,9%. Os dois cartões mostram primeiro a resposta de 12 pontos e depois a de 9.”

## Como acompanhar no Xcode

Abra o arquivo indicado em cada capítulo. A coluna da esquerda é a linha do arquivo. Leia primeiro o trecho em Swift, tente dizer o que ele faz e confira a tradução à direita. As linhas em branco separam ideias. Uma linha com apenas `}` fecha o bloco aberto pela chave `{` correspondente. Uma linha com apenas `)` termina uma chamada. Essas linhas usam a mesma regra em todos os capítulos.

**Antes da primeira linha.** Pense em uma pergunta de papel com número, enunciado, alternativas e valor em pontos. Uma `struct` diz quais campos essa ficha tem. `let` dá um nome a um valor que fica fixo. `var` permite mudar o valor ou calcular um valor quando ele é lido. Depois de dois-pontos vem o tipo do dado. `String` é texto, `Int` é número inteiro, `Double` aceita casas decimais e `Bool` vale verdadeiro ou falso.

**Como ler os sinais.** `=` guarda um valor e `==` compara dois valores. `[QuizOption]` é uma lista de alternativas. `[Int: Int]` é uma tabela que associa um número a outro. `?` depois de um tipo indica que um valor pode estar ausente. Essa ausência se chama `nil`. Em uma escolha como `condição ? A : B`, leia “se for verdade, use A, senão use B”. Um ponto acessa algo que pertence ao valor anterior. Uma linha começando com ponto geralmente continua a instrução de cima. `func` dá um nome a uma ação, os parênteses recebem o que ela precisa e `->` indica o que ela devolve. `private` limita quem pode usar aquele nome.

**Um toque para acompanhar.** Se a pessoa toca em B na pergunta 2, o app guarda `userAnswers[2] = 1`. O 2 é o número impresso na pergunta. O 1 é a posição de B, porque as posições começam em zero. Se ela voltar e escolher C, o mesmo espaço passa a guardar 2. Só a escolha final entra na soma.

## 1. Do que uma pergunta é feita

Arquivo no projeto — [QuizModels.swift](FoundationFinalProject/Features/Quiz/Models/QuizModels.swift)

### As cinco áreas

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 1 | `enum QuizArea: String, CaseIterable, Identifiable {` | Cria um conjunto fechado de áreas. Cada área tem um nome em texto, pode ser listada com allCases e tem uma identidade para o SwiftUI. |
| 2 | `case frontend = "Front-end"` | Cria a área escrita à esquerda do sinal de igual. O texto entre aspas é seu nome de exibição. |
| 3 | `case backend = "Back-end"` | Cria a área escrita à esquerda do sinal de igual. O texto entre aspas é seu nome de exibição. |
| 4 | `case uiux = "Design UI/UX"` | Cria a área escrita à esquerda do sinal de igual. O texto entre aspas é seu nome de exibição. |
| 5 | `case cybersecurity = "Cibersegurança"` | Cria a área escrita à esquerda do sinal de igual. O texto entre aspas é seu nome de exibição. |
| 6 | `case devops = "DevOps"` | Cria a área escrita à esquerda do sinal de igual. O texto entre aspas é seu nome de exibição. |
| 7 | `var id: String { rawValue }` | Usa esse nome como identidade da área. rawValue lê o texto entre aspas acima. |

### O texto de cada profissão

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 8 | `var description: String {` | Permite pedir uma descrição em texto a qualquer área. |
| 9 | `switch self {` | Olha qual é a área atual e escolhe um dos casos abaixo. |
| 10 | `case .frontend:` | Começa o caso da área indicada. As próximas linhas fornecem sua descrição. |
| 11 | `return """` | Começa o texto de várias linhas que será entregue à tela. |
| 12 | `Front-end é a área responsável pela parte visual e interativa de aplicações e sites.` | Primeiro parágrafo que a pessoa lê quando essa área vence. |
| 14 | `Profissionais dessa área trabalham com interfaces, componentes, responsividade, acessibilidade e experiência de navegação.` | Segundo parágrafo, com exemplos do trabalho nessa área. |
| 16 | `Tecnologias comuns: HTML, CSS, JavaScript, SwiftUI e React.` | Último parágrafo, com exemplos de tecnologias ou ferramentas. |
| 17 | `"""` | Termina o texto da descrição, incluindo os parágrafos acima. |
| 18 | `case .backend:` | Começa o caso da área indicada. As próximas linhas fornecem sua descrição. |
| 19 | `return """` | Começa o texto de várias linhas que será entregue à tela. |
| 20 | `Back-end é a área responsável pela lógica interna das aplicações.` | Primeiro parágrafo que a pessoa lê quando essa área vence. |
| 22 | `Profissionais dessa área trabalham com servidores, APIs, bancos de dados, autenticação e processamento de informações.` | Segundo parágrafo, com exemplos do trabalho nessa área. |
| 24 | `Tecnologias comuns: Java, Python, Node.js, PostgreSQL e SQL.` | Último parágrafo, com exemplos de tecnologias ou ferramentas. |
| 25 | `"""` | Termina o texto da descrição, incluindo os parágrafos acima. |
| 26 | `case .uiux:` | Começa o caso da área indicada. As próximas linhas fornecem sua descrição. |
| 27 | `return """` | Começa o texto de várias linhas que será entregue à tela. |
| 28 | `Design UI/UX envolve a criação e o planejamento de interfaces digitais e experiências de utilização.` | Primeiro parágrafo que a pessoa lê quando essa área vence. |
| 30 | `Profissionais dessa área estudam usabilidade, identidade visual, prototipagem, acessibilidade e comportamento dos usuários.` | Segundo parágrafo, com exemplos do trabalho nessa área. |
| 32 | `Ferramentas comuns: Figma, Adobe XD e ferramentas de prototipagem.` | Último parágrafo, com exemplos de tecnologias ou ferramentas. |
| 33 | `"""` | Termina o texto da descrição, incluindo os parágrafos acima. |
| 34 | `case .cybersecurity:` | Começa o caso da área indicada. As próximas linhas fornecem sua descrição. |
| 35 | `return """` | Começa o texto de várias linhas que será entregue à tela. |
| 36 | `Cibersegurança é a área responsável pela proteção de sistemas, redes, aplicações e informações.` | Primeiro parágrafo que a pessoa lê quando essa área vence. |
| 38 | `Profissionais dessa área trabalham com análise de vulnerabilidades, monitoramento, segurança de redes e prevenção de ameaças.` | Segundo parágrafo, com exemplos do trabalho nessa área. |
| 40 | `Tecnologias comuns: Linux, redes, ferramentas de segurança e análise de vulnerabilidades.` | Último parágrafo, com exemplos de tecnologias ou ferramentas. |
| 41 | `"""` | Termina o texto da descrição, incluindo os parágrafos acima. |
| 42 | `case .devops:` | Começa o caso da área indicada. As próximas linhas fornecem sua descrição. |
| 43 | `return """` | Começa o texto de várias linhas que será entregue à tela. |
| 44 | `DevOps integra desenvolvimento de software e operações de infraestrutura.` | Primeiro parágrafo que a pessoa lê quando essa área vence. |
| 46 | `Profissionais dessa área trabalham com automação, integração contínua, entrega contínua, infraestrutura e monitoramento.` | Segundo parágrafo, com exemplos do trabalho nessa área. |
| 48 | `Tecnologias comuns: Docker, Git, Linux, CI/CD e ferramentas de cloud.` | Último parágrafo, com exemplos de tecnologias ou ferramentas. |
| 49 | `"""` | Termina o texto da descrição, incluindo os parágrafos acima. |

### A alternativa e a pergunta

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 54 | `struct QuizOption {` | Define quais informações pertencem a uma alternativa. |
| 55 | `let letter: String` | Guarda sua letra, por exemplo B. |
| 56 | `let text: String` | Guarda a frase da alternativa que veio do Notion. |
| 57 | `let area: QuizArea` | Indica qual área recebe os pontos se a pessoa escolher esta alternativa. |
| 60 | `struct QuizQuestion: Identifiable {` | Define a ficha de uma pergunta. Identifiable indica que ela possui um identificador. |
| 61 | `let id: Int` | Guarda o número da pergunta, de 1 a 5. |
| 62 | `let title: String` | Guarda o enunciado que a pessoa vai ler. |
| 63 | `let weight: Int` | Guarda quantos pontos esta pergunta vale. |
| 64 | `let options: [QuizOption]` | Guarda as alternativas, na ordem que a tela deve exibir. |

## 2. Como as perguntas chegam do Notion

Arquivo no projeto — [QuizViewModel.swift](FoundationFinalProject/Features/Quiz/ViewModels/QuizViewModel.swift)

### Carregamento e erro

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 1 | `import Foundation` | Traz ferramentas para trabalhar com endereços, dados e requisições de rede. |
| 2 | `import Combine` | Traz os recursos que avisam a tela quando os dados mudam. |
| 4 | `// Carrega as perguntas e avisa a tela quando o estado muda.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 5 | `@MainActor` | Mantém este código no contexto em que o app atualiza a interface. A espera pela rede usa await. |
| 6 | `final class QuizViewModel: ObservableObject {` | Cria o objeto que a tela acompanha. ObservableObject permite observar mudanças e final indica que essa classe está completa para fins de herança. |
| 7 | `@Published private(set) var questions: [QuizQuestion] = []` | Começa com uma lista vazia. @Published avisa a tela quando muda. private(set) permite que a tela leia a lista e reserva a escrita para este objeto. |
| 8 | `private var isLoading = false` | Guarda se já existe uma busca em andamento para evitar duas consultas simultâneas. |
| 9 | `@Published private(set) var errorMessage: String?` | Guarda uma possível mensagem de erro. A interrogação permite começar sem mensagem. |
| 11 | `func load() async {` | Define a ação de carregar. async permite fazer uma pausa enquanto os dados chegam. |
| 12 | `guard questions.isEmpty, !isLoading else { return }` | Só continua se a lista ainda estiver vazia e nenhuma busca estiver em andamento. O ponto de exclamação inverte a condição. |
| 13 | `isLoading = true` | Marca a consulta como iniciada. |
| 14 | `errorMessage = nil` | Apaga a mensagem da tentativa anterior. |
| 15 | `defer { isLoading = false }` | Agenda a liberação da consulta para a saída da função, inclusive em caso de erro. |
| 17 | `let environment = ProcessInfo.processInfo.environment` | Lê as configurações que o Xcode entregou ao aplicativo ao iniciá-lo. |
| 18 | `let token = (environment["BEARER_TOKEN"] ?? environment["NOTION_TOKEN"] ?? "")` | Procura a chave de acesso. Cada ?? tenta o próximo valor se o anterior estiver ausente. |
| 19 | `.trimmingCharacters(in: .whitespacesAndNewlines)` | Retira espaços e quebras de linha das extremidades do valor lido. |
| 20 | `let source = (environment["NOTION_DATA_SOURCE_ID"] ?? "")` | Lê o identificador da tabela do quiz. Se estiver ausente, começa com texto vazio. |
| 21 | `.trimmingCharacters(in: .whitespacesAndNewlines)` | Retira espaços e quebras de linha das extremidades do valor lido. |
| 23 | `do {` | Começa uma tentativa que pode falhar. O catch abaixo trata a falha. |
| 24 | `guard !token.isEmpty, !source.isEmpty else {` | Exige que a chave e o identificador estejam preenchidos. |
| 25 | `throw QuizLoadError.invalid("Configure BEARER_TOKEN e NOTION_DATA_SOURCE_ID no esquema do Xcode.")` | Interrompe a tentativa com instruções de configuração para a pessoa que está rodando o app. |
| 27 | `questions = try await NotionQuizService.fetch(token: token, source: source)` | Pede as perguntas, aguarda a resposta e guarda a lista. try indica que a operação pode falhar. |
| 28 | `} catch {` | Se a tentativa falhar, entra neste bloco. |
| 29 | `errorMessage = error.localizedDescription` | Guarda a explicação da falha para a tela exibir. |

### Preparar a consulta

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 34 | `enum QuizLoadError: LocalizedError {` | Define o tipo de erro que o quiz consegue explicar em texto. |
| 35 | `case invalid(String)` | Cada erro deste tipo carrega uma frase. |
| 36 | `var errorDescription: String? {` | Define a mensagem que o sistema pode exibir. |
| 37 | `switch self {` | Inspeciona o erro recebido. |
| 38 | `case .invalid(let message): return message` | Extrai a frase guardada e a devolve. |
| 43 | `// Converte a resposta do Notion nos modelos usados pela tela.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 44 | `@MainActor` | Mantém este código no contexto em que o app atualiza a interface. A espera pela rede usa await. |
| 45 | `enum NotionQuizService {` | Reúne as funções que conversam com o Notion. static permite chamá-las pelo nome do serviço. |
| 46 | `private static let weights = [1: 6, 2: 9, 3: 11, 4: 12, 5: 13]` | Associa cada número de pergunta a um peso. Por exemplo, a pergunta 2 vale 9 pontos. |
| 48 | `static func fetch(token: String, source: String) async throws -> [QuizQuestion] {` | Define a busca. Recebe chave e identificador, pode esperar, pode falhar e, se der certo, devolve uma lista de perguntas. |
| 49 | `guard UUID(uuidString: source) != nil \|\|` | Verifica se o identificador tem o formato de UUID. As duas barras significam “ou”. |
| 50 | `(source.count == 32 && source.allSatisfy({ $0.isHexDigit })),` | Também aceita 32 caracteres hexadecimais, ou seja, algarismos e letras de A a F. |
| 51 | `let url = URL(string: "https://api.notion.com/v1/data_sources/\(source)/query") else {` | Encaixa o identificador no endereço da consulta e tenta criar uma URL válida. |
| 52 | `throw QuizLoadError.invalid("Use apenas o ID da fonte quiz, sem a URL do Notion.")` | Encerra a tentativa quando o identificador ou o endereço é inválido. |
| 54 | `var questions: [QuizQuestion] = []` | Cria a lista que receberá as perguntas de todas as páginas. |
| 55 | `var cursor: String?` | Reserva um texto opcional para marcar o início da próxima página. |
| 56 | `var visitedCursors = Set<String>()` | Cria um conjunto sem repetições para lembrar quais marcadores já apareceram. |

### Buscar uma página

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 58 | `repeat {` | Inicia uma busca que pode se repetir caso haja mais páginas. |
| 59 | `var request = URLRequest(url: url)` | Cria o pedido de rede usando o endereço preparado acima. |
| 60 | `request.httpMethod = "POST"` | Usa o método POST exigido para esta consulta. |
| 61 | `request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")` | Envia a chave no campo de autorização para o Notion reconhecer a integração. |
| 62 | `request.setValue("2025-09-03", forHTTPHeaderField: "Notion-Version")` | Informa ao Notion qual versão da API o código usa. |
| 63 | `request.setValue("application/json", forHTTPHeaderField: "Content-Type")` | Avisa que o corpo do pedido será escrito no formato JSON, um formato de troca de dados. |
| 64 | `var body: [String: Any] = ["page_size": 100]` | Pede até 100 registros nesta página. O dicionário aceita tipos de valores diferentes. |
| 65 | `if let cursor { body["start_cursor"] = cursor }` | Se já houver marcador, pede a página que começa nele. |
| 66 | `request.httpBody = try JSONSerialization.data(withJSONObject: body)` | Converte os campos do pedido em bytes para enviá-los. |
| 68 | `let (data, response) = try await URLSession.shared.data(for: request)` | Envia o pedido e espera. data contém o conteúdo recebido e response contém informações da resposta. |
| 69 | `guard let http = response as? HTTPURLResponse else {` | Tenta ler a resposta como HTTP, o protocolo da consulta. |
| 70 | `throw QuizLoadError.invalid("Resposta de rede inválida.")` | Interrompe com uma mensagem se faltar uma resposta HTTP válida. |
| 72 | `guard (200..<300).contains(http.statusCode) else {` | Aceita códigos de 200 até 299, que indicam sucesso. |
| 73 | `throw QuizLoadError.invalid("Erro HTTP \(http.statusCode). Confira o token, o ID da fonte e o acesso da integração.")` | Inclui o código da falha na mensagem para facilitar a conferência das configurações. |
| 75 | `guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],` | Tenta ler os bytes como JSON e interpretar o conteúdo como uma coleção de campos com nome. |
| 76 | `let records = json["results"] as? [[String: Any]] else {` | Procura o campo results e verifica se ele contém uma lista de registros. |
| 77 | `throw QuizLoadError.invalid("Resposta do Notion em formato inesperado.")` | Informa que a resposta veio em um formato que o app não conseguiu ler. |
| 79 | `for record in records {` | Percorre as linhas recebidas nesta página do Notion. |
| 80 | `questions.append(try makeQuestion(from: record))` | Converte uma linha em pergunta e adiciona à lista. Um erro de conversão interrompe a consulta. |

### Buscar as páginas seguintes

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 82 | `// Continua a consulta se o Notion dividir os resultados em páginas.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 83 | `if json["has_more"] as? Bool == true {` | Confere se o Notion informou que há outra página. |
| 84 | `guard let next = json["next_cursor"] as? String,` | Lê o marcador que indica onde a próxima página começa. |
| 85 | `visitedCursors.insert(next).inserted else {` | Guarda o marcador e exige que ele seja novo, para evitar buscar a mesma página em círculo. |
| 86 | `throw QuizLoadError.invalid("Paginação inválida na resposta do Notion.")` | Interrompe a consulta se o marcador estiver ausente ou repetido. |
| 88 | `cursor = next` | Guarda o marcador para a próxima volta. |
| 89 | `} else {` | Se a condição anterior for falsa, segue por este caminho. |
| 90 | `cursor = nil` | Retira o marcador quando a consulta chega à última página. |
| 92 | `} while cursor != nil` | Volta ao repeat enquanto existir um marcador. |
| 94 | `questions.sort { $0.id < $1.id }` | Coloca as perguntas em ordem crescente de número. |
| 95 | `guard questions.map({ $0.id }) == [1, 2, 3, 4, 5] else {` | Compara os números recebidos à sequência completa. Essa comparação também detecta números repetidos. |
| 96 | `throw QuizLoadError.invalid("A fonte deve ter exatamente cinco perguntas, numeradas de 1 a 5 no início do título.")` | Explica o que conferir na tabela quando a sequência está incorreta. |
| 98 | `return questions` | Entrega a lista pronta à função load. |

### Ler uma pergunta

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 101 | `private static func makeQuestion(from record: [String: Any]) throws -> QuizQuestion {` | Define a ação de transformar um registro bruto do Notion em uma pergunta do app. |
| 102 | `guard let properties = record["properties"] as? [String: Any] else {` | Procura o campo properties, onde ficam as células daquela linha. |
| 103 | `throw QuizLoadError.invalid("Registro sem propriedades.")` | Informa que o registro veio sem essas células. |
| 105 | `let fullTitle = text("Pergunta", in: properties)` | Lê o conteúdo completo da coluna Pergunta. |
| 106 | `let numberText = fullTitle.prefix { $0.isNumber }` | Pega os algarismos no início do enunciado. Em “2. Qual…”, obtém “2”. |
| 107 | `guard let number = Int(String(numberText)), let weight = weights[number] else {` | Transforma os algarismos em inteiro e procura o peso desse número. |
| 108 | `throw QuizLoadError.invalid("Cada título deve começar com um número de 1 a 5.")` | Dá erro caso o título comece sem um número aceito. |
| 110 | `let title = String(fullTitle.dropFirst(numberText.count))` | Retira os algarismos iniciais para formar o enunciado exibido. |
| 111 | `.trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: ".-)")))` | Limpa nas pontas espaços, quebras de linha e os sinais listados entre aspas. |
| 112 | `guard !title.isEmpty else {` | Confere se sobrou texto para a pessoa ler. |
| 113 | `throw QuizLoadError.invalid("A pergunta \(number) está sem título.")` | Informa qual pergunta ficou sem enunciado. |
| 115 | `// A pergunta 2 troca a posição de DevOps e Cibersegurança.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 116 | `let areas: [QuizArea] = number == 2` | Verifica se está montando as alternativas da pergunta 2. |
| 117 | `? [.backend, .uiux, .frontend, .devops, .cybersecurity]` | Se for a pergunta 2, D corresponde a DevOps e E a Cibersegurança. |
| 118 | `: [.backend, .uiux, .frontend, .cybersecurity, .devops]` | Nas outras perguntas, D corresponde a Cibersegurança e E a DevOps. |
| 119 | `let options = try ["A", "B", "C", "D", "E"].enumerated().map { index, letter in` | Passa por A até E, recebendo posição e letra. map monta uma alternativa para cada letra. |
| 120 | `let column = "alternativa_\(letter)"` | Forma o nome da coluna, por exemplo alternativa_B. |
| 121 | `let answer = removeLetterPrefix(text(column, in: properties), letter: letter)` | Lê a célula e remove a letra inicial caso ela já esteja escrita no texto. |
| 122 | `guard !answer.isEmpty else {` | Verifica se a alternativa tem conteúdo. |
| 123 | `throw QuizLoadError.invalid("Preencha \(column) da pergunta \(number).")` | Identifica a célula que precisa ser preenchida no Notion. |
| 125 | `return QuizOption(letter: letter, text: answer, area: areas[index])` | Entrega uma alternativa com letra, frase e área correspondente à posição. |
| 127 | `return QuizQuestion(id: number, title: title, weight: weight, options: options)` | Junta número, enunciado, peso e alternativas na ficha da pergunta. |

### Reconstruir o texto das células

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 130 | `// Title e Rich text chegam como listas de fragmentos de texto.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 131 | `private static func text(_ name: String, in properties: [String: Any]) -> String {` | Define a leitura de uma célula a partir de seu nome e das propriedades do registro. |
| 132 | `guard let property = properties[name] as? [String: Any],` | Procura a coluna pelo nome. |
| 133 | `let type = property["type"] as? String,` | Lê o tipo da coluna, por exemplo title ou rich_text. |
| 134 | `let fragments = property[type] as? [[String: Any]] else { return "" }` | Usa esse tipo como chave para achar os pedaços de texto. Se faltar alguma parte da estrutura, devolve texto vazio. |
| 135 | `return fragments.compactMap { $0["plain_text"] as? String }.joined()` | Pega plain_text de cada pedaço que contém texto e junta tudo em uma única frase. |
| 136 | `.trimmingCharacters(in: .whitespacesAndNewlines)` | Limpa espaços e quebras de linha das pontas. |
| 139 | `private static func removeLetterPrefix(_ text: String, letter: String) -> String {` | Define a limpeza da letra que às vezes já vem escrita na alternativa. |
| 140 | `for prefix in ["\(letter))", "\(letter).", "\(letter) -"] {` | Experimenta três inícios possíveis. Para B, são B), B. e B seguido de espaço e hífen. |
| 141 | `if text.hasPrefix(prefix) {` | Confere se a frase começa exatamente com o prefixo da vez. |
| 142 | `return String(text.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)` | Remove esse prefixo, limpa os espaços nas pontas e devolve a frase. |
| 145 | `return text` | Se nenhum prefixo combinar, devolve a frase recebida. |

## 3. O que acontece quando alguém toca em uma alternativa

Arquivo no projeto — [QuizView.swift](FoundationFinalProject/Features/Quiz/Views/QuizView.swift)

### O que a tela lembra

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 1 | `import SwiftUI` | Traz os recursos usados para desenhar a interface do iPhone. |
| 3 | `struct QuizView: View {` | Define a tela interativa do quiz. |
| 4 | `@AppStorage("quiz.recommendedArea") private var savedRecommendation = ""` | Lembra a área recomendada mesmo depois de fechar o aplicativo. O texto entre aspas identifica onde salvar esse valor. |
| 5 | `let onContinueToTrails: (QuizArea) -> Void` | Recebe uma ação de quem abriu o quiz. Quando chamada, ela recebe a área vencedora. Void indica que a ação termina sem devolver um valor. |
| 7 | `@StateObject private var viewModel = QuizViewModel()` | Cria o objeto que carrega as perguntas e o mantém vivo quando o SwiftUI redesenha esta tela. |
| 8 | `@State private var currentQuestion = 0` | Começa na posição zero, a primeira pergunta. @State faz a tela acompanhar mudanças nesse número. |
| 9 | `// A chave é o número da pergunta e o valor é o índice da alternativa escolhida.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 10 | `@State private var userAnswers: [Int: Int] = [:]` | Cria um dicionário vazio. Cada número de pergunta terá a posição da alternativa escolhida. |
| 11 | `@State private var result: QuizResult?` | Reserva espaço para o resultado. Começa vazio e recebe um QuizResult ao terminar. |
| 13 | `private var questions: [QuizQuestion] { viewModel.questions }` | Dá à tela um nome curto para ler a lista que chegou do Notion. |
| 15 | `private var activeQuestion: QuizQuestion { questions[currentQuestion] }` | Busca nessa lista a pergunta que ocupa a posição atual. |
| 17 | `// MARK: - Tela e navegação` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |

### Escolher o que mostrar

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 18 | `var body: some View {` | Define o conteúdo que o SwiftUI vai desenhar. |
| 19 | `ZStack {` | Coloca um elemento sobre o outro. |
| 20 | `Color("Branco-Init")` | Coloca a cor de fundo atrás do conteúdo. |
| 21 | `.ignoresSafeArea()` | Estende essa cor até as bordas do aparelho. |
| 22 | `Group {` | Reúne as próximas opções de tela para aplicar o mesmo tamanho ao conjunto. |
| 23 | `if let error = viewModel.errorMessage {` | Se existe uma mensagem de erro, dá a ela um nome para exibi-la. |
| 24 | `VStack(spacing: 16) {` | Empilha os elementos de cima para baixo, com 16 pontos de espaço entre eles. |
| 25 | `Text(error).multilineTextAlignment(.center)` | Exibe a mensagem de falha e centraliza suas linhas de texto. |
| 26 | `Button("Tentar novamente") { Task { await viewModel.load() } }` | Desenha um botão que inicia outra tentativa de carregar quando a pessoa toca. |
| 27 | `}.padding()` | Termina a coluna de erro e dá espaço ao redor dela. |
| 28 | `} else if questions.isEmpty {` | Se ainda não chegaram perguntas, usa a tela de espera. |
| 29 | `ProgressView("Carregando perguntas…")` | Mostra o indicador de carregamento com uma frase. |
| 30 | `} else if let result {` | Se já existe um resultado, entrega seu valor a este bloco. |
| 31 | `QuizResultView(result: result, onContinueToTrails: onContinueToTrails, restartQuiz: restartQuiz)` | Abre a tela de resultado e passa as ações para continuar e refazer. |
| 32 | `.transition(.opacity)` | Ao trocar de tela com animação, faz esta parte aparecer ou sumir aos poucos. |
| 33 | `} else {` | Se a condição anterior for falsa, segue por este caminho. |
| 34 | `quizScreen` | Mostra a tela de perguntas quando os dados estão prontos e o quiz está em andamento. |
| 35 | `.transition(.opacity)` | Ao trocar de tela com animação, faz esta parte aparecer ou sumir aos poucos. |
| 38 | `.frame(maxWidth: .infinity, maxHeight: .infinity)` | Define largura máxima de todo o espaço disponível e altura máxima de todo o espaço disponível. |
| 40 | `.task { await viewModel.load() }` | Inicia o carregamento quando a tela aparece. |
| 41 | `.preferredColorScheme(.light)` | Pede ao sistema a aparência clara para esta tela. |

### Desenhar uma pergunta

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 44 | `private var quizScreen: some View {` | Define a parte visual que reúne pergunta, alternativas e navegação. |
| 45 | `VStack(spacing: 0) {` | Empilha os elementos de cima para baixo, com 0 pontos de espaço entre eles. |
| 46 | `header` | Insere o cabeçalho definido mais abaixo. |
| 47 | `ScrollView(showsIndicators: false) {` | Permite rolar o conteúdo na vertical e oculta o indicador lateral. |
| 48 | `VStack(spacing: 12) {` | Empilha os elementos de cima para baixo, com 12 pontos de espaço entre eles. |
| 49 | `Text("Pergunta \(currentQuestion + 1) de \(questions.count)")` | Mostra o número da pergunta e o total. Soma 1 à posição para que a pessoa veja “Pergunta 1 de 5”. |
| 50 | `.font(.system(size: 13, weight: .medium))` | Usa a fonte do sistema com tamanho 13 e traço médio. |
| 51 | `.foregroundColor(Color("Azul-marinho-init"))` | Aplica a cor indicada ao texto ou ícone. |
| 52 | `.frame(maxWidth: .infinity)` | Define largura máxima de todo o espaço disponível. |
| 53 | `.padding(.top, 15)` | Acrescenta espaço em cima de 15 pontos. |
| 54 | `Text(activeQuestion.title)` | Exibe o enunciado lido do Notion. |
| 55 | `.font(.system(size: 15, weight: .semibold))` | Usa a fonte do sistema com tamanho 15 e traço seminegrito. |
| 56 | `.foregroundColor(Color("Azul-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 57 | `.frame(maxWidth: .infinity, alignment: .leading)` | Define largura máxima de todo o espaço disponível, com o conteúdo alinhado ao início. |
| 58 | `.padding(15)` | Acrescenta espaço em todos os lados de 15 pontos. |
| 59 | `.background(Color("Branco-Init"))` | Pinta o fundo com a cor indicada. |
| 60 | `.clipShape(RoundedRectangle(cornerRadius: 12))` | Recorta o conteúdo no formato de um retângulo com cantos arredondados. |
| 61 | `VStack(spacing: 10) {` | Empilha os elementos de cima para baixo, com 10 pontos de espaço entre eles. |
| 62 | `ForEach(activeQuestion.options.indices, id: \.self) { index in` | Percorre as posições das opções da pergunta. Cada posição identifica um botão dentro desse conjunto. |
| 63 | `optionButton(index: index)` | Desenha a alternativa que está naquela posição. |
| 67 | `.padding(.horizontal, 20)` | Acrescenta espaço nas laterais de 20 pontos. |
| 68 | `.padding(.bottom, 20)` | Acrescenta espaço embaixo de 20 pontos. |
| 70 | `Spacer(minLength: 0)` | Ocupa espaço livre abaixo da rolagem, podendo encolher até zero. |
| 72 | `.frame(maxWidth: 430)` | Define largura máxima de 430 pontos. |
| 73 | `.frame(maxWidth: .infinity)` | Define largura máxima de todo o espaço disponível. |
| 74 | `.safeAreaInset(edge: .bottom, spacing: 0) {` | Dentro da largura disponível, centraliza a coluna limitada pela linha anterior. |
| 75 | `navigationButtons` | Reserva a parte inferior da tela para os controles, respeitando a área segura do iPhone. |
| 76 | `.padding(.horizontal, 24)` | Insere os botões de voltar e avançar. |
| 77 | `.padding(.top, 12)` | Acrescenta espaço em cima de 12 pontos. |
| 78 | `.padding(.bottom, 8)` | Acrescenta espaço embaixo de 8 pontos. |
| 79 | `.background(Color("Branco-Init"))` | Pinta o fundo com a cor indicada. |

### Desenhar o cabeçalho

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 83 | `private var header: some View {` | Define o cabeçalho com ícone, título e frase de apresentação. |
| 84 | `VStack(alignment: .leading, spacing: 6) {` | Empilha os elementos de cima para baixo e alinha pelo início, com 6 pontos de espaço entre eles. |
| 85 | `HStack(spacing: 10) {` | Coloca os elementos lado a lado, com 10 pontos de espaço entre eles. |
| 86 | `Image(systemName: "note.text")` | Desenha o ícone de anotação fornecido pelo sistema. |
| 87 | `.font(.system(size: 30, weight: .medium))` | Usa a fonte do sistema com tamanho 30 e traço médio. |
| 88 | `Text("Quiz")` | Mostra a palavra Quiz. |
| 89 | `.font(.system(size: 28, weight: .bold))` | Usa a fonte do sistema com tamanho 28 e traço negrito. |
| 91 | `.foregroundColor(Color("Azul-Init"))` | Colore o ícone e o título de uma só vez, porque ambos pertencem à linha acima. |
| 92 | `Text("Faça o quiz e descubra sua área ideal da tecnologia.")` | Exibe a frase de apresentação abaixo do título. |
| 93 | `.font(.system(size: 14))` | Usa a fonte do sistema com tamanho 14. |
| 94 | `.foregroundColor(Color("Azul-marinho-init"))` | Aplica a cor indicada ao texto ou ícone. |
| 95 | `.fixedSize(horizontal: false, vertical: true)` | Respeita a largura disponível e deixa o texto crescer para baixo quando precisa de mais linhas. |
| 97 | `.frame(maxWidth: .infinity, alignment: .leading)` | Define largura máxima de todo o espaço disponível, com o conteúdo alinhado ao início. |
| 98 | `.padding(.horizontal, 24)` | Acrescenta espaço nas laterais de 24 pontos. |
| 99 | `.padding(.top, 8)` | Acrescenta espaço em cima de 8 pontos. |
| 100 | `.padding(.bottom, 12)` | Acrescenta espaço embaixo de 12 pontos. |

### Guardar um toque

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 103 | `private func optionButton(index: Int) -> some View {` | Define como montar o botão de uma alternativa a partir de sua posição. |
| 104 | `let option = activeQuestion.options[index]` | Busca a opção nessa posição para acessar a letra e o texto. |
| 105 | `let isSelected = userAnswers[activeQuestion.id] == index` | Compara a escolha guardada com a posição deste botão. O resultado indica se ele está marcado. |
| 106 | `return Button {` | Cria o botão e começa a definir o que acontece ao tocar. |
| 107 | `withAnimation(.easeInOut(duration: 0.15)) {` | Anima a mudança dentro das chaves durante 0,15 segundo. |
| 108 | `userAnswers[activeQuestion.id] = index` | Grava a posição escolhida no espaço reservado à pergunta. Um segundo toque em outra opção substitui a escolha anterior. |
| 110 | `} label: {` | Termina a ação do botão e começa a descrever sua aparência. |
| 111 | `Text("\(option.letter)) \(option.text)")` | Junta a letra, um parêntese e o texto. A pessoa lê algo como “B) Desenhar”. |
| 112 | `.font(.system(size: 13, weight: .medium))` | Usa a fonte do sistema com tamanho 13 e traço médio. |
| 113 | `.foregroundColor(isSelected ? Color("Azul-marinho-init") : Color("Branco-Init"))` | Usa texto escuro sobre a alternativa selecionada e claro sobre as demais. |
| 114 | `.multilineTextAlignment(.leading)` | Alinha as linhas do texto ao início. |
| 115 | `.frame(maxWidth: .infinity, alignment: .leading)` | Define largura máxima de todo o espaço disponível, com o conteúdo alinhado ao início. |
| 116 | `.padding(14)` | Acrescenta espaço em todos os lados de 14 pontos. |
| 117 | `.background(isSelected ? Color("Turquesa-Init") : Color("Azul-Init"))` | Usa turquesa na alternativa escolhida e azul nas demais. |
| 118 | `.overlay {` | Coloca um desenho por cima do fundo para criar o contorno. |
| 119 | `RoundedRectangle(cornerRadius: 12)` | Desenha o caminho da borda com cantos de raio 12. |
| 120 | `.stroke(` | Começa a especificar a cor e a espessura desse contorno. |
| 121 | `isSelected ? Color("Azul-Init") : Color.appClear,` | Usa um contorno azul na escolha atual e transparente nas outras. |
| 122 | `lineWidth: 2` | Dá 2 pontos de espessura à linha de contorno. |
| 125 | `.clipShape(RoundedRectangle(cornerRadius: 12))` | Recorta o conteúdo no formato de um retângulo com cantos arredondados. |
| 126 | `.shadow(color: Color("Azul-marinho-init").opacity(0.15), radius: 3, y: 2)` | Desenha uma sombra. opacity controla a transparência, radius o desfoque e y o deslocamento para baixo. |
| 128 | `.buttonStyle(.plain)` | Usa o desenho que o código deu ao botão. |
| 129 | `.accessibilityAddTraits(isSelected ? .isSelected : [])` | Avisa ao leitor de tela se a alternativa está selecionada. |

### Voltar, avançar e refazer

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 132 | `private var navigationButtons: some View {` | Define a fileira de botões no rodapé. |
| 133 | `HStack {` | Coloca os elementos lado a lado. |
| 134 | `if currentQuestion > 0 {` | Só desenha o botão Voltar a partir da segunda pergunta. |
| 135 | `Button(action: previousQuestion) { arrow("chevron.left") }` | Tocar na seta esquerda executa previousQuestion. |
| 136 | `.accessibilityLabel("Pergunta anterior")` | Dá ao leitor de tela uma descrição da seta esquerda. |
| 138 | `Spacer()` | Ocupa o espaço livre da fileira, deixando a seta direita na outra ponta. |
| 139 | `Button(action: nextQuestion) { arrow("chevron.right") }` | Tocar na seta direita executa nextQuestion. |
| 140 | `.disabled(userAnswers[activeQuestion.id] == nil)` | Bloqueia o avanço enquanto esta pergunta estiver sem resposta. |
| 141 | `.opacity(userAnswers[activeQuestion.id] == nil ? 0.45 : 1)` | Deixa o botão com 45% de opacidade se estiver bloqueado e totalmente visível se estiver liberado. |
| 142 | `.accessibilityLabel(` | Começa a escolher o nome que o leitor de tela dirá para a seta direita. |
| 143 | `currentQuestion == questions.count - 1` | Verifica se esta é a última posição da lista. |
| 144 | `? "Ver resultado"` | Se for a última, anuncia “Ver resultado”. |
| 145 | `: "Próxima pergunta"` | Nas demais, anuncia “Próxima pergunta”. |
| 150 | `private func arrow(_ symbol: String) -> some View {` | Define um único desenho de seta usado pelos dois botões. O parâmetro symbol escolhe a direção. |
| 151 | `Image(systemName: symbol)` | Desenha o símbolo do sistema cujo nome o botão forneceu. |
| 152 | `.font(.system(size: 18, weight: .medium))` | Usa a fonte do sistema com tamanho 18 e traço médio. |
| 153 | `.foregroundColor(Color("Branco-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 154 | `.frame(width: 44, height: 44)` | Define largura de 44 pontos e altura de 44 pontos. |
| 155 | `.background(Color("Azul-Init"), in: Circle())` | Pinta o fundo com a cor indicada e dá a ele formato circular. |
| 158 | `private func nextQuestion() {` | Define a ação da seta direita. |
| 159 | `guard userAnswers[activeQuestion.id] != nil else {` | Confere se há uma escolha registrada antes de avançar. |
| 160 | `return` | Encerra esta ação aqui. |
| 162 | `if currentQuestion < questions.count - 1 {` | Verifica se ainda existe uma pergunta depois da atual. |
| 163 | `withAnimation(.easeInOut(duration: 0.2)) {` | Anima a mudança dentro das chaves durante 0,2 segundo. |
| 164 | `currentQuestion += 1` | Soma um à posição. Com isso, a próxima pergunta aparece. |
| 166 | `} else {` | Se a condição anterior for falsa, segue por este caminho. |
| 167 | `withAnimation(.easeInOut(duration: 0.3)) {` | Anima a mudança dentro das chaves durante 0,3 segundo. |
| 168 | `let completedQuiz = QuizResult(questions: questions, answers: userAnswers)` | Ao terminar a quinta pergunta, entrega todas as escolhas e perguntas ao cálculo do resultado. |
| 169 | `savedRecommendation = completedQuiz.winningArea.rawValue` | Salva o nome da área vencedora para a aba Trilhas destacar a recomendação. |
| 170 | `result = completedQuiz` | Guarda o resultado pronto. A condição da linha 30 passa a mostrar a outra tela. |
| 175 | `private func previousQuestion() {` | Define a ação da seta esquerda. |
| 176 | `guard currentQuestion > 0 else {` | Confere se há uma posição anterior para a qual voltar. |
| 177 | `return` | Encerra esta ação aqui. |
| 179 | `withAnimation(.easeInOut(duration: 0.2)) {` | Anima a mudança dentro das chaves durante 0,2 segundo. |
| 180 | `currentQuestion -= 1` | Diminui a posição em um. A escolha feita antes continua no dicionário. |
| 184 | `private func restartQuiz() {` | Define como começar uma nova rodada com as perguntas já carregadas. |
| 185 | `withAnimation(.easeInOut(duration: 0.3)) {` | Anima a mudança dentro das chaves durante 0,3 segundo. |
| 186 | `currentQuestion = 0` | Volta para a primeira posição. |
| 187 | `userAnswers.removeAll()` | Esvazia a tabela das escolhas da rodada anterior. |
| 188 | `result = nil` | Retira o resultado desta tela. O SwiftUI volta a exibir as perguntas. |
| 193 | `#Preview("iPhone 17") {` | Define uma prévia no Xcode com o nome “iPhone 17”. |
| 194 | `InitRootView()` | Usa a tela principal do app como ponto de partida dessa prévia. |

## 4. Como uma resposta vira pontos

Arquivo no projeto — [QuizResult.swift](FoundationFinalProject/Features/Quiz/Models/QuizResult.swift)

### O que guardar no resultado

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 1 | `struct QuizResult {` | Define a ficha do resultado de uma rodada. |
| 2 | `struct Contribution {` | Define uma ficha menor para explicar a contribuição de uma resposta. |
| 3 | `let questionID: Int` | Guarda o número da pergunta que deu pontos. |
| 4 | `let answer: String` | Guarda o texto escolhido pela pessoa. |
| 5 | `let area: QuizArea` | Guarda a área que recebeu os pontos. |
| 6 | `let points: Int` | Guarda quantos pontos essa escolha valeu. |
| 9 | `let totalWeight: Int` | Guarda a soma dos pesos das perguntas. Nas cinco perguntas atuais, é 51. |
| 10 | `let rankedAreas: [QuizArea]` | Guarda as áreas em ordem de pontuação. |
| 11 | `let winningAnswers: [Contribution]` | Guarda até duas respostas que explicam a vitória da primeira área. |
| 12 | `private let scores: [QuizArea: Int]` | Guarda uma tabela com os pontos de cada área para uso dentro deste cálculo. |
| 14 | `var winningArea: QuizArea { rankedAreas[0] }` | Pega a primeira área da lista ordenada. A posição zero é o primeiro lugar. |
| 15 | `var winningScore: Int { scores[winningArea, default: 0] }` | Procura a pontuação da vencedora. Uma área sem entrada na tabela vale zero. |

### Somar por área

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 17 | `init(questions: [QuizQuestion], answers: [Int: Int]) {` | init é o trecho executado ao criar o resultado. Recebe as perguntas e as escolhas finais. |
| 18 | `var totals: [QuizArea: Int] = [:]` | Começa uma tabela de pontos vazia. |
| 19 | `var contributions: [Contribution] = []` | Começa uma lista vazia para lembrar quanto cada resposta contribuiu. |
| 21 | `for question in questions {` | Pega uma pergunta por vez. |
| 22 | `guard let index = answers[question.id], question.options.indices.contains(index) else { continue }` | Procura a escolha dessa pergunta e confirma que a posição existe. continue pula apenas essa pergunta se faltar uma escolha válida. |
| 23 | `let option = question.options[index]` | Pega a alternativa escolhida usando a posição guardada. |
| 24 | `totals[option.area, default: 0] += question.weight` | Soma o peso à área daquela alternativa. Na primeira soma da área, parte de zero. |
| 25 | `contributions.append(Contribution(questionID: question.id, answer: option.text,` | Começa a guardar a origem dos pontos, com número da pergunta e texto escolhido. |
| 26 | `area: option.area, points: question.weight))` | Completa a ficha com área e pontos e a acrescenta à lista de contribuições. |

### Ordenar e escolher os dois cartões

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 29 | `// Em caso de empate, a ordem alfabética deixa o ranking previsível.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 30 | `let ranking = QuizArea.allCases.sorted { first, second in` | Pede uma lista ordenada das cinco áreas. first e second são duas áreas que o Swift compara a cada passo. |
| 31 | `let firstScore = totals[first, default: 0]` | Lê os pontos da primeira área em comparação. |
| 32 | `let secondScore = totals[second, default: 0]` | Lê os pontos da segunda área em comparação. |
| 33 | `if firstScore == secondScore { return first.rawValue < second.rawValue }` | Se houver empate, coloca antes o nome que vem primeiro em ordem alfabética. |
| 34 | `return firstScore > secondScore` | Se os pontos forem diferentes, coloca antes a área com mais pontos. |
| 37 | `scores = totals` | Guarda os totais calculados no resultado. |
| 38 | `rankedAreas = ranking` | Guarda a ordem calculada das áreas. |
| 39 | `totalWeight = questions.reduce(0) { $0 + $1.weight }` | Começa em zero e soma um peso por vez. Aqui, $0 é o total até agora e $1 é a pergunta da vez. |
| 40 | `winningAnswers = Array(contributions.filter { $0.area == ranking[0] }` | Filtra as contribuições e mantém apenas as que deram pontos à área em primeiro lugar. |
| 41 | `.sorted { $0.points > $1.points }.prefix(2))` | Ordena essas respostas do maior peso para o menor e guarda até as duas primeiras. |

### Calcular a porcentagem

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 44 | `func percentage(for area: QuizArea) -> Double {` | Define o cálculo da porcentagem de uma área e devolve um número com casas decimais. |
| 45 | `guard totalWeight > 0 else { return 0 }` | Se o total for zero, devolve zero para evitar uma divisão por zero. |
| 46 | `return Double(scores[area, default: 0]) / Double(totalWeight) * 100` | Divide os pontos da área pelo total e multiplica por 100. Double permite obter, por exemplo, 52,94 em vez de perder a parte decimal. |

## 5. Como o resultado aparece no iPhone

Arquivo no projeto — [QuizResultView.swift](FoundationFinalProject/Features/Quiz/Views/QuizResultView.swift)

### Receber o resultado e montar a página

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 1 | `import SwiftUI` | Traz os recursos usados para desenhar a interface do iPhone. |
| 3 | `struct QuizResultView: View {` | Define a tela que apresenta o resultado. |
| 4 | `let result: QuizResult` | Recebe a ficha com ranking, pontos e justificativas calculados no capítulo anterior. |
| 5 | `let onContinueToTrails: (QuizArea) -> Void` | Recebe a ação de seguir para Trilhas levando a área recomendada. |
| 6 | `let restartQuiz: () -> Void` | Recebe a ação de refazer. Os parênteses vazios indicam que basta acioná-la. |
| 8 | `@State private var resultProgress: Double = 0` | Começa a animação em zero. Quando chega a 1, a tela mostra todo o percentual calculado. |
| 9 | `@Environment(\.accessibilityReduceMotion) private var reduceMotion` | Lê a preferência “Reduzir Movimento” nas configurações de acessibilidade do aparelho. |
| 11 | `// MARK: - Resultado` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 12 | `var body: some View {` | Define o conteúdo que será exibido nesta tela. |
| 13 | `ScrollView(showsIndicators: false) {` | Permite rolar o conteúdo na vertical e oculta o indicador lateral. |
| 14 | `VStack(spacing: 0) {` | Empilha os elementos de cima para baixo, com 0 pontos de espaço entre eles. |
| 15 | `resultHeader` | Insere o cabeçalho com a profissão vencedora. |
| 16 | `VStack(alignment: .leading, spacing: 24) {` | Empilha os elementos de cima para baixo e alinha pelo início, com 24 pontos de espaço entre eles. |
| 17 | `scoreSection` | Insere a seção das barras de pontuação. |
| 18 | `winningAnswersSection` | Insere os cartões que justificam o resultado. |
| 19 | `areaDescription` | Insere a explicação sobre a área vencedora. |
| 20 | `Button { onContinueToTrails(result.winningArea) } label: {` | Cria o botão que repassa a área vencedora para quem abriu o quiz. |
| 21 | `Label("Continuar para as trilhas", systemImage: "arrow.right")` | Mostra o texto do botão acompanhado de uma seta. |
| 22 | `.font(.headline)` | Usa o estilo de texto de título. |
| 23 | `.frame(maxWidth: .infinity)` | Define largura máxima de todo o espaço disponível. |
| 24 | `.padding()` | Acrescenta espaço em todos os lados usando a medida padrão. |
| 25 | `.foregroundStyle(Color("Branco-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 26 | `.background(Color("Azul-Init"), in: Capsule())` | Pinta o fundo com a cor indicada e dá a ele formato de cápsula. |
| 28 | `restartButton` | Insere o botão de reiniciar. |
| 29 | `.frame(maxWidth: .infinity)` | Define largura máxima de todo o espaço disponível. |
| 31 | `.padding(.horizontal, 28)` | Acrescenta espaço nas laterais de 28 pontos. |
| 32 | `.padding(.top, 24)` | Acrescenta espaço em cima de 24 pontos. |
| 33 | `.padding(.bottom, 32)` | Acrescenta espaço embaixo de 32 pontos. |
| 34 | `.frame(maxWidth: 480)` | Define largura máxima de 480 pontos. |
| 35 | `.frame(maxWidth: .infinity)` | Centraliza a coluna de até 480 pontos no espaço restante. |
| 38 | `.task { await animateResult() }` | Inicia a animação das barras quando o resultado aparece. |
| 39 | `.background {` | Começa o fundo da página. |
| 40 | `Color("Branco-Init").ignoresSafeArea()` | Aplica a cor de fundo do resultado até as bordas da tela. |
| 42 | `.background(alignment: .top) {` | Coloca mais um fundo alinhado ao topo. |
| 43 | `Color("Azul-Init")` | Usa a cor da faixa superior. |
| 44 | `.frame(height: 100)` | Define altura de 100 pontos. |
| 45 | `.ignoresSafeArea(edges: .top)` | Estende essa faixa até a borda de cima do aparelho. |

### Cabeçalho da área vencedora

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 49 | `private var resultHeader: some View {` | Define o cabeçalho da recomendação. |
| 50 | `VStack(spacing: 0) {` | Empilha os elementos de cima para baixo, com 0 pontos de espaço entre eles. |
| 51 | `ZStack(alignment: .bottom) {` | Coloca um elemento sobre o outro e alinha pela base. |
| 52 | `UnevenRoundedRectangle(` | Começa um retângulo em que cada canto pode ter um arredondamento diferente. |
| 53 | `bottomLeadingRadius: 24,` | Arredonda o canto inferior do lado inicial em 24 pontos. |
| 54 | `bottomTrailingRadius: 24` | Arredonda o outro canto inferior na mesma medida. |
| 56 | `.fill(Color("Azul-Init"))` | Preenche o retângulo com a cor do cabeçalho. |
| 57 | `.frame(height: 140)` | Define altura de 140 pontos. |
| 58 | `.background(alignment: .top) {` | Coloca uma extensão da faixa atrás do topo do cabeçalho. |
| 59 | `Color("Azul-Init")` | Pinta essa extensão da mesma cor da faixa. |
| 60 | `.frame(height: 140)` | Define altura de 140 pontos. |
| 61 | `.ignoresSafeArea(edges: .top)` | Estende a cor por trás da área reservada ao sistema no topo. |
| 63 | `RoundedRectangle(cornerRadius: 24)` | Desenha o bloco de cantos arredondados que recebe o ícone. |
| 64 | `.fill(Color("Branco-Init"))` | Pinta o interior do bloco com a cor de fundo do ícone. |
| 65 | `.frame(width: 132, height: 132)` | Define largura de 132 pontos e altura de 132 pontos. |
| 66 | `.overlay {` | Coloca o símbolo por cima do bloco. |
| 67 | `Image(systemName: resultSymbol)` | Pede ao sistema a imagem com o nome escolhido para a área vencedora. |
| 68 | `.font(.system(size: 56, weight: .light))` | Usa a fonte do sistema com tamanho 56 e traço fino. |
| 69 | `.foregroundStyle(Color("Azul-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 71 | `.shadow(color: Color("Azul-marinho-init").opacity(0.18), radius: 3, y: 4)` | Desenha uma sombra. opacity controla a transparência, radius o desfoque e y o deslocamento para baixo. |
| 72 | `.offset(y: 34)` | Desloca o bloco 34 pontos para baixo, deixando-o sobre a borda da faixa. |
| 74 | `.padding(.bottom, 46)` | Acrescenta espaço embaixo de 46 pontos. |
| 75 | `Text("Sua área sugerida...")` | Apresenta o rótulo que vem antes do nome da área. |
| 76 | `.font(.system(size: 20))` | Usa a fonte do sistema com tamanho 20. |
| 77 | `.padding(.bottom, 8)` | Acrescenta espaço embaixo de 8 pontos. |
| 78 | `Text(result.winningArea.rawValue)` | Exibe o nome legível da área vencedora. |
| 79 | `.font(.system(size: 36, weight: .medium))` | Usa a fonte do sistema com tamanho 36 e traço médio. |
| 80 | `.multilineTextAlignment(.center)` | Alinha as linhas do texto ao centro. |
| 81 | `.fixedSize(horizontal: false, vertical: true)` | Respeita a largura disponível e deixa o texto crescer para baixo quando precisa de mais linhas. |
| 82 | `.padding(.horizontal, 24)` | Acrescenta espaço nas laterais de 24 pontos. |
| 83 | `Text("\(result.winningScore) de \(result.totalWeight) pontos")` | Monta a frase com pontos da vencedora e pontos totais, por exemplo “27 de 51 pontos”. |
| 84 | `.font(.subheadline)` | Usa o estilo de texto de subtítulo. |
| 85 | `.foregroundStyle(Color("Azul-marinho-init"))` | Aplica a cor indicada ao texto ou ícone. |
| 86 | `.padding(.top, 8)` | Acrescenta espaço em cima de 8 pontos. |
| 88 | `.foregroundStyle(Color("Azul-Init"))` | Aplica a cor indicada ao texto ou ícone. |

### Ícones e barras

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 91 | `private var resultSymbol: String {` | Define qual nome de ícone usar. |
| 92 | `switch result.winningArea {` | Olha a área vencedora para escolher uma das cinco opções. |
| 93 | `case .frontend: return "rectangle.and.hand.point.up.left"` | Quando a área à esquerda vence, usa o ícone do sistema identificado entre aspas. |
| 94 | `case .backend: return "server.rack"` | Quando a área à esquerda vence, usa o ícone do sistema identificado entre aspas. |
| 95 | `case .uiux: return "paintpalette"` | Quando a área à esquerda vence, usa o ícone do sistema identificado entre aspas. |
| 96 | `case .cybersecurity: return "lock.shield"` | Quando a área à esquerda vence, usa o ícone do sistema identificado entre aspas. |
| 97 | `case .devops: return "gearshape.2"` | Quando a área à esquerda vence, usa o ícone do sistema identificado entre aspas. |
| 101 | `private var scoreSection: some View {` | Define a seção com as barras de porcentagem. |
| 102 | `VStack(alignment: .leading, spacing: 14) {` | Empilha os elementos de cima para baixo e alinha pelo início, com 14 pontos de espaço entre eles. |
| 103 | `ForEach(Array(result.rankedAreas.prefix(3))) { area in` | Percorre até as três primeiras áreas do ranking, uma barra por área. |
| 104 | `let value = result.percentage(for: area) * resultProgress` | Multiplica o percentual final pelo progresso da animação. Com um resultado de 60% e progresso de 0,5, a tela mostra 30%. |
| 105 | `VStack(alignment: .leading, spacing: 6) {` | Empilha os elementos de cima para baixo e alinha pelo início, com 6 pontos de espaço entre eles. |
| 106 | `HStack(alignment: .firstTextBaseline) {` | Coloca os elementos lado a lado e alinha pela base da primeira linha de texto. |
| 107 | `Text(area == result.winningArea` | Começa a escolher o texto da linha verificando se a área é a vencedora. |
| 108 | `? "Pontos no resultado sugerido"` | Para a vencedora, usa a frase “Pontos no resultado sugerido”. |
| 109 | `: area.rawValue)` | Para outra área, usa o próprio nome dela. |
| 110 | `.font(.system(size: 12))` | Usa a fonte do sistema com tamanho 12. |
| 111 | `Spacer(minLength: 8)` | Afasta o título da porcentagem e garante pelo menos 8 pontos entre eles. |
| 112 | `Text(String(format: "%.1f%%", value))` | Exibe o valor com uma casa decimal e o sinal %. No formato, %% imprime um único sinal. |
| 113 | `.font(.system(size: 18))` | Usa a fonte do sistema com tamanho 18. |
| 115 | `GeometryReader { geometry in` | Mede a largura disponível para desenhar a barra naquele aparelho. |
| 116 | `ZStack(alignment: .leading) {` | Coloca um elemento sobre o outro e alinha pelo início. |
| 117 | `Capsule().fill(Color("Azul-marinho-init").opacity(0.12))` | Desenha a faixa inteira de fundo em formato de cápsula e com 12% de opacidade. |
| 118 | `Capsule()` | Desenha outra cápsula por cima, que será a parte preenchida. |
| 119 | `.fill(Color("Turquesa-Init"))` | Pinta a parte preenchida com a cor do progresso. |
| 120 | `.frame(width: geometry.size.width * CGFloat(value / 100))` | Multiplica a largura disponível pela fração já exibida. Em uma faixa de 200 pontos, 50% preenche 100. |
| 123 | `.frame(height: 5)` | Define altura de 5 pontos. |
| 126 | `Text("Percentuais sobre os \(result.totalWeight) pontos distribuídos entre as áreas.")` | Explica o total sobre o qual a porcentagem foi calculada, usando o total desta rodada. |
| 127 | `.font(.caption2)` | Usa o estilo de texto de legenda pequena. |
| 128 | `.foregroundStyle(Color("Azul-marinho-init"))` | Aplica a cor indicada ao texto ou ícone. |
| 130 | `.foregroundStyle(Color("Azul-Init"))` | Aplica a cor indicada ao texto ou ícone. |

### Os cartões de justificativa

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 133 | `private var winningAnswersSection: some View {` | Define a seção que explica por que a área foi sugerida. |
| 134 | `VStack(alignment: .leading, spacing: 14) {` | Empilha os elementos de cima para baixo e alinha pelo início, com 14 pontos de espaço entre eles. |
| 135 | `Text("Você combina com a área porque:")` | Apresenta a frase que introduz os cartões. |
| 136 | `.font(.system(size: 20))` | Usa a fonte do sistema com tamanho 20. |
| 137 | `.foregroundStyle(Color("Azul-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 138 | `.fixedSize(horizontal: false, vertical: true)` | Respeita a largura disponível e deixa o texto crescer para baixo quando precisa de mais linhas. |
| 139 | `LazyVGrid(` | Começa a grade que organiza os cartões conforme a largura do aparelho. |
| 140 | `columns: [GridItem(.adaptive(minimum: 140), spacing: 18)],` | Pede colunas que se adaptem, com tamanho mínimo de 140 pontos e 18 pontos entre elas. |
| 141 | `alignment: .leading,` | Alinha os cartões ao início da grade. |
| 142 | `spacing: 18` | Deixa 18 pontos entre as fileiras. |
| 143 | `) {` | Termina as opções da grade e começa seu conteúdo. |
| 144 | `ForEach(Array(result.winningAnswers.enumerated()), id: \.offset) { index, contribution in` | Para cada uma das até duas contribuições, recebe sua posição e seus dados. A posição identifica o cartão nessa pequena lista. |
| 145 | `VStack(alignment: .leading, spacing: 12) {` | Empilha os elementos de cima para baixo e alinha pelo início, com 12 pontos de espaço entre eles. |
| 146 | `Text("\(index + 1)")` | Numera o cartão na ordem de importância, começando em 1. |
| 147 | `.font(.system(size: 17))` | Usa a fonte do sistema com tamanho 17. |
| 148 | `.foregroundStyle(Color("Azul-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 149 | `.frame(width: 30, height: 30)` | Define largura de 30 pontos e altura de 30 pontos. |
| 150 | `.background(Color("Branco-Init"), in: Circle())` | Pinta o fundo com a cor indicada e dá a ele formato circular. |
| 151 | `Text(contribution.answer)` | Mostra a alternativa realmente escolhida pela pessoa. |
| 152 | `.font(.system(size: 15))` | Usa a fonte do sistema com tamanho 15. |
| 153 | `.fixedSize(horizontal: false, vertical: true)` | Respeita a largura disponível e deixa o texto crescer para baixo quando precisa de mais linhas. |
| 154 | `Text("Pergunta \(contribution.questionID) · +\(contribution.points) pontos")` | Mostra o número original da pergunta e quantos pontos ela deu. |
| 155 | `.font(.caption2)` | Usa o estilo de texto de legenda pequena. |
| 156 | `.foregroundStyle(Color("Branco-Init").opacity(0.85))` | Aplica a cor indicada ao texto ou ícone, com 85% de opacidade. |
| 158 | `.foregroundStyle(Color("Branco-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 159 | `.padding(16)` | Acrescenta espaço em todos os lados de 16 pontos. |
| 160 | `.frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)` | Define largura máxima de todo o espaço disponível e altura mínima de 160 pontos, com o conteúdo no alto à esquerda. |
| 161 | `.background(Color("Azul-Init"), in: RoundedRectangle(cornerRadius: 16))` | Pinta o fundo com a cor indicada com cantos arredondados. |
| 162 | `.shadow(color: Color("Azul-marinho-init").opacity(0.16), radius: 2, y: 3)` | Desenha uma sombra. opacity controla a transparência, radius o desfoque e y o deslocamento para baixo. |

### Descrição e botão de reinício

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 168 | `private var areaDescription: some View {` | Define o bloco sobre a profissão. |
| 169 | `VStack(alignment: .leading, spacing: 14) {` | Empilha os elementos de cima para baixo e alinha pelo início, com 14 pontos de espaço entre eles. |
| 170 | `Text("O que é essa área?")` | Mostra a pergunta que introduz a descrição. |
| 171 | `.font(.system(size: 23))` | Usa a fonte do sistema com tamanho 23. |
| 172 | `.foregroundStyle(Color("Azul-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 173 | `VStack(alignment: .leading, spacing: 18) {` | Empilha os elementos de cima para baixo e alinha pelo início, com 18 pontos de espaço entre eles. |
| 174 | `Text("Conhecendo \(result.winningArea.rawValue)")` | Monta o título com o nome da profissão recomendada. |
| 175 | `.font(.system(size: 22, weight: .medium))` | Usa a fonte do sistema com tamanho 22 e traço médio. |
| 176 | `Text(result.winningArea.description)` | Mostra os parágrafos guardados para essa área em QuizModels. |
| 177 | `.font(.system(size: 16))` | Usa a fonte do sistema com tamanho 16. |
| 178 | `.lineSpacing(5)` | Acrescenta 5 pontos de espaço entre linhas do texto. |
| 179 | `.fixedSize(horizontal: false, vertical: true)` | Respeita a largura disponível e deixa o texto crescer para baixo quando precisa de mais linhas. |
| 181 | `.foregroundStyle(Color("Branco-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 182 | `.padding(20)` | Acrescenta espaço em todos os lados de 20 pontos. |
| 183 | `.frame(maxWidth: .infinity, alignment: .leading)` | Define largura máxima de todo o espaço disponível, com o conteúdo alinhado ao início. |
| 184 | `.background(Color("Azul-Init"), in: RoundedRectangle(cornerRadius: 22))` | Pinta o fundo com a cor indicada com cantos arredondados. |
| 185 | `.shadow(color: Color("Azul-marinho-init").opacity(0.16), radius: 3, y: 3)` | Desenha uma sombra. opacity controla a transparência, radius o desfoque e y o deslocamento para baixo. |
| 189 | `private var restartButton: some View {` | Define a aparência do botão para iniciar outra rodada. |
| 190 | `Button(action: restartQuiz) {` | Executa a ação restartQuiz quando a pessoa toca. |
| 191 | `Label("Refazer quiz", systemImage: "arrow.clockwise")` | Mostra o texto de reinício e o ícone de seta circular. |
| 192 | `.font(.system(size: 16, weight: .semibold))` | Usa a fonte do sistema com tamanho 16 e traço seminegrito. |
| 193 | `.foregroundStyle(Color("Branco-Init"))` | Aplica a cor indicada ao texto ou ícone. |
| 194 | `.padding(.horizontal, 24)` | Acrescenta espaço nas laterais de 24 pontos. |
| 195 | `.padding(.vertical, 13)` | Acrescenta espaço em cima e embaixo de 13 pontos. |
| 196 | `.background(Color("Azul-Init"), in: Capsule())` | Pinta o fundo com a cor indicada e dá a ele formato de cápsula. |
| 198 | `.buttonStyle(.plain)` | Usa o desenho que o código deu ao botão. |

### Animação em câmera lenta

| Linha | Swift | Em palavras simples |
| ---: | --- | --- |
| 201 | `// MARK: - Animação e reinício` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 202 | `// O mesmo progresso controla a largura das barras e o percentual.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 204 | `@MainActor` | Garante que a animação atualize o estado no contexto da interface. |
| 205 | `private func animateResult() async {` | Define a ação que atualiza o progresso e que pode aguardar entre os quadros. |
| 206 | `resultProgress = 0` | Começa com número e barra em zero. |
| 207 | `guard !reduceMotion else {` | Confere a preferência de acessibilidade antes de iniciar o movimento. |
| 208 | `resultProgress = 1` | Quando a pessoa prefere movimento reduzido, coloca o progresso diretamente no final. |
| 209 | `return` | Encerra esta ação aqui. |
| 211 | `let clock = ContinuousClock()` | Cria um relógio para medir quanto tempo realmente passou. |
| 212 | `let start = clock.now` | Anota o instante em que a animação começou. |
| 213 | `while !Task.isCancelled {` | Repete enquanto o SwiftUI mantiver a tarefa ativa. |
| 214 | `let elapsed = start.duration(to: clock.now)` | Mede o tempo entre o início e o instante atual. |
| 215 | `let fraction = min(elapsed / .seconds(1.5), 1)` | Divide o tempo passado por 1,5 segundo. Na metade do tempo dá 0,5. min impede passar de 1. |
| 216 | `// Começa devagar, acelera e desacelera no final.` | Comentário para quem lê o arquivo. O aplicativo pula esta linha. |
| 217 | `resultProgress = fraction * fraction * (3 - 2 * fraction)` | Suaviza a subida. A fórmula começa devagar, acelera no meio e freia no final. Esse mesmo valor alimenta o número e a barra. |
| 218 | `if fraction >= 1 { return }` | Ao atingir o fim, encerra as atualizações. |
| 219 | `do {` | Começa uma tentativa que pode falhar. O catch abaixo trata a falha. |
| 220 | `try await Task.sleep(for: .milliseconds(16))` | Aguarda cerca de 16 milissegundos para dar tempo ao aparelho de mostrar o quadro. |
| 221 | `} catch {` | Se a tentativa falhar, entra neste bloco. |
| 222 | `return` | Se a pausa for interrompida, encerra a animação. |

## Configurar e conferir

No Xcode: Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables. Habilite BEARER_TOKEN e NOTION_DATA_SOURCE_ID. A integração precisa ter acesso à fonte quiz. Os títulos devem começar com 1. até 5.; as outras colunas devem se chamar exatamente alternativa_A até alternativa_E e ser Rich text.

Confira no simulador: carregar as perguntas, selecionar/voltar/trocar uma resposta, terminar o quiz, observar barras e percentuais, conferir os dois maiores pesos nos cartões e refazer o quiz. Sem as variáveis, deve aparecer erro, nunca perguntas locais.

A estrutura do arquivo de projeto foi validada com plutil. Não foi possível compilar ou executar o simulador neste ambiente, pois as ferramentas do Xcode não estão configuradas. A execução real continua necessária para confirmar compilação, aparência e integração com sua fonte.


## Glossário conectado ao Notion

A aba Glossário usa BEARER_TOKEN (ou NOTION_TOKEN) e NOTION_GLOSSARIO_DATA_SOURCE_ID. Configure essa nova variável em Run > Arguments > Environment Variables, com o ID da fonte glossario. Mantenha NOTION_DATA_SOURCE_ID para o quiz. A integração precisa ter acesso às duas fontes.

As colunas correspondem à captura: Palavra (Title), Definição (Rich text) e Tag (Rich text; também aceita Select ou Multi-select). Palavra e Definição são obrigatórias. Tag pode ficar vazia; nesse caso, o detalhe não mostra a etiqueta. A relação roadmapNode não é consultada nesta tela; ela continua disponível no Notion para uma futura navegação aos roadmaps.

Não há termos locais. GlossarioViewModel.carregar lê as variáveis e publica carregamento, lista e erro. NotionGlossarioService consulta todas as páginas da fonte e converte cada registro em Termo. GlossarioView mostra os termos em ordem alfabética; a busca considera palavra, definição e tag. Ao tocar, TermoDetalheView apresenta o significado e a tag. O texto da definição é exibido sem a formatação de negrito/itálico do Notion.

Atualize os dados pelo botão de seta circular ou puxando a lista para baixo. Uma fonte vazia mostra mensagem própria. Em falhas de atualização, a lista já recebida permanece visível junto com o erro e o botão de tentar novamente.

Para usar Termos em alta, adicione opcionalmente uma propriedade Destaque do tipo Checkbox e marque os termos desejados. São exibidos até quatro destaques em ordem alfabética, respeitando a pesquisa. Sem essa propriedade, a seção fica oculta; não é inventado um ranking de popularidade.

Referências: https://developers.notion.com/reference/query-a-data-source e https://developers.notion.com/reference/page-property-values. A leitura foi verificada com registros de teste; a consulta real depende da configuração da fonte no Xcode.

Registros incompletos no glossário: linhas com Palavra ou Definição vazias são ignoradas, sem impedir a exibição dos termos completos. A tela informa a quantidade ignorada. Colunas obrigatórias ausentes ou tipos incompatíveis continuam gerando erro de configuração. Depois de completar os campos no Notion, atualize a lista pelo botão. Nenhum registro é alterado ou apagado no banco pelo aplicativo.
