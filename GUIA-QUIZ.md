# Entendendo o quiz, do início ao resultado

Este guia acompanha os dois projetos. O código do quiz é igual nas duas pastas; cada projeto tem apenas seu próprio arquivo de entrada do aplicativo. Todos os enunciados e alternativas vêm do Notion. As áreas, descrições das áreas, pesos e regras de associação ficam no Swift.

## 1. Arquivos que ficaram

| Arquivo | Responsabilidade |
| --- | --- |
| FoundationFinalProjectApp.swift ou QuizApp.swift | Iniciar o aplicativo e abrir ContentView. |
| QuizModels.swift | Definir áreas, alternativas, perguntas e cores. |
| QuizViewModel.swift | Consultar o Notion, converter os dados e controlar carregamento e erro. |
| ContentView.swift | Mostrar perguntas, guardar escolhas, calcular resultado e animar barras. |
| Assets.xcassets | Guardar recursos visuais do aplicativo. |
| Projeto .xcodeproj | Informar ao Xcode como montar o aplicativo. |

Não apague o arquivo App: @main indica por onde o programa começa. WindowGroup cria a janela e ContentView() abre a tela principal.

Foram removidos o catálogo local vazio, o wrapper QuizView que só abria ContentView, o CSV antigo, o relatório antigo e a dependência swift-notion do Projeto-Init. A consulta já usa URLSession, então esse pacote e sua dependência indireta swift-syntax eram desnecessários. As descrições das profissões foram preservadas. O cálculo e a animação foram preservados.

## 2. Vocabulário para acompanhar o Swift

- let: um valor que não será trocado; var: um valor que pode mudar.
- struct: agrupa dados ou descreve uma tela. enum: lista possibilidades conhecidas, como as cinco áreas. class: objeto que pode ser compartilhado e observado.
- [QuizQuestion]: lista de perguntas. [QuizArea: Int]: dicionário que associa cada área a uma pontuação.
- Int?: inteiro opcional; nil significa que ainda não existe valor. Na lista de respostas, nil é uma pergunta sem resposta.
- private: uso restrito ao tipo que contém a declaração. private(set): outras partes podem ler, mas somente o próprio tipo pode alterar.
- func: função que executa uma ação. Uma propriedade calculada, como scores, calcula um valor quando é consultada.
- guard: verifica uma condição e sai antecipadamente quando ela não é atendida.
- async/await: permite aguardar uma operação, como uma consulta de rede, sem bloquear a interface. Não significa que a operação sempre terá sucesso.
- throws/try/do/catch: uma função pode falhar; try tenta executá-la e catch recebe a falha.
- $0: primeiro valor recebido por um pequeno bloco de código. Por exemplo, questions.map { $0.id } cria uma lista dos números das perguntas.
- map transforma cada item; compactMap transforma e descarta valores ausentes; sorted ordena; prefix(2) pega no máximo os dois primeiros; reduce acumula um total.

## 3. QuizModels.swift: os dados

QuizArea lista Front-end, Back-end, Design UI/UX, Cibersegurança e DevOps. rawValue é o nome exibido. CaseIterable fornece allCases, a lista de todas as áreas. Identifiable fornece uma identidade para o SwiftUI distinguir os itens em uma lista. description contém a apresentação de cada profissão, mostrada no resultado.

QuizOption guarda letter (A a E), text (texto que veio do Notion) e area (a área que receberá o peso). A letra identifica a opção dentro da pergunta.

QuizQuestion guarda id (número de 1 a 5), title (enunciado), weight (peso) e options (as cinco alternativas).

A extensão de Color dá nomes às cores usadas na tela e permite escrever Color(hex: 0x003F56). O inicializador separa os canais vermelho, verde e azul desse número e os converte para a escala de 0 a 1 esperada pelo SwiftUI. A cor individual de cada área e quizLightGray foram removidas porque não eram usadas.

## 4. QuizViewModel.swift: o caminho dos dados

QuizViewModel é um ObservableObject: a tela observa suas mudanças. @Published faz com que mudanças em questions, isLoading e errorMessage atualizem a interface. @MainActor mantém essas alterações no contexto da interface.

questions começa vazia. isLoading informa se há uma consulta em andamento. errorMessage contém uma mensagem quando algo falha. Não existe modo local.

load() funciona assim:

1. Sai se as perguntas já foram obtidas ou se outra consulta está em andamento.
2. Ativa isLoading e limpa o erro anterior.
3. Lê BEARER_TOKEN e NOTION_DATA_SOURCE_ID das variáveis do esquema do Xcode. NOTION_TOKEN é aceito como nome alternativo para compatibilidade.
4. Verifica se ambos os valores existem e chama NotionQuizService.fetch.
5. Guarda as perguntas recebidas. Se falhar, guarda a mensagem de erro.
6. defer desativa isLoading ao sair, inclusive quando acontece um erro.

O antigo indicador loaded foi removido: uma lista de perguntas preenchida já informa que o carregamento terminou com sucesso.

QuizLoadError é o erro com mensagens compreensíveis para o usuário. LocalizedError permite obter essas mensagens por error.localizedDescription.

NotionQuizService.fetch faz a consulta:

1. Verifica se source parece um ID, com ou sem hífens, e monta a URL da fonte.
2. Cria uma requisição POST. Authorization leva o token; Notion-Version mantém a versão 2025-09-03 usada no projeto; Content-Type informa que o corpo é JSON.
3. Pede até 100 registros por página. Se houver cursor, pede a página seguinte.
4. URLSession.shared.data envia a requisição e aguarda a resposta.
5. Verifica o código HTTP e o formato do JSON. Uma falha vira mensagem na tela.
6. Converte cada registro com makeQuestion.
7. Se has_more for verdadeiro, continua com next_cursor. visitedCursors impede repetir indefinidamente o mesmo cursor.
8. Ordena as perguntas pelo número e exige exatamente [1, 2, 3, 4, 5]. Isso também rejeita números repetidos.

makeQuestion lê a coluna Pergunta, extrai o número inicial e encontra o peso correspondente. Remove a numeração do título para exibi-lo sem duplicação. Depois lê alternativa_A até alternativa_E e associa cada uma à sua área. Falta de título ou alternativa gera erro; não se pula silenciosamente uma pergunta inválida.

| Pergunta | Peso | A | B | C | D | E |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 6 | Back-end | Design UI/UX | Front-end | Cibersegurança | DevOps |
| 2 | 9 | Back-end | Design UI/UX | Front-end | DevOps | Cibersegurança |
| 3 | 11 | Back-end | Design UI/UX | Front-end | Cibersegurança | DevOps |
| 4 | 12 | Back-end | Design UI/UX | Front-end | Cibersegurança | DevOps |
| 5 | 13 | Back-end | Design UI/UX | Front-end | Cibersegurança | DevOps |

text junta os fragmentos de texto de uma propriedade Title ou Rich text. removeLetterPrefix remove A), A. e prefixos semelhantes, porque a interface já mostra a letra.

Se você mudar a posição das alternativas no Notion, ajuste areas em makeQuestion. Se alterar só o texto, ele será recebido na próxima execução do app. Não é necessário alterar o Swift para mudar apenas um enunciado.

## 5. ContentView.swift: estado e pontuação

@StateObject mantém o ViewModel enquanto a tela existe. @State guarda valores da interação. @Environment lê uma preferência do sistema: accessibilityReduceMotion indica se o usuário prefere reduzir movimentos.

- currentQuestion: posição da pergunta atual. Começa em 0, pois listas usam índices a partir de zero.
- userAnswers: cinco posições opcionais, inicialmente nil. Cada posição guarda o índice da alternativa escolhida. Exemplo: [0, 1, nil, nil, nil] significa Q1 A e Q2 B.
- showResult: escolhe entre perguntas e resultado.
- resultProgress: vai de 0 a 1 durante a animação.
- questions: acesso curto a vm.questions.
- totalWeight: soma os pesos recebidos, totalizando 51.

scores começa todas as áreas em zero. Para cada pergunta respondida, encontra a alternativa escolhida e soma question.weight à área dela. Exemplo: Q1 A soma 6 em Back-end; Q2 B soma 9 em Design UI/UX. O cálculo parte das seleções atuais, por isso voltar e trocar uma alternativa substitui a contribuição anterior, sem duplicar pontos.

rankedAreas ordena as áreas do maior total para o menor. Em igualdade de pontos, usa o nome para manter uma ordem visual previsível. Esse critério serve às áreas zeradas: os pesos e as cinco respostas garantem que o primeiro colocado não empate.

winningArea é a primeira área do ranking. winningScore consulta os pontos dela. percentage divide os pontos da área por totalWeight e multiplica por 100. O número representa a parcela dos pontos, não uma probabilidade de aptidão profissional.

winningAnswers percorre as escolhas, mantém apenas as que contribuíram para a vencedora, ordena do maior peso para o menor e pega no máximo duas. Se apenas uma pergunta contribuiu, aparece apenas um cartão. A soma exibida no resultado continua considerando as cinco respostas, não só esses cartões.

## 6. ContentView.swift: o que cada parte desenha

body é a entrada visual. ZStack coloca o fundo atrás do conteúdo. A ordem das condições protege o acesso às listas: enquanto não há perguntas, mostra carregamento; se houver erro, mostra mensagem e botão de tentar novamente; depois mostra o quiz ou o resultado. .task chama load quando a tela aparece.

quizScreen organiza o cabeçalho e uma ScrollView vertical com número, enunciado e alternativas. A largura máxima e as margens mantêm o conteúdo adequado ao celular. safeAreaInset coloca a navegação no rodapé, respeitando a área segura.

header mostra o ícone, o título Quiz e a introdução. optionButton monta uma alternativa, compara seu índice à seleção atual e muda a cor quando está marcada. O toque atualiza userAnswers. A indicação de seleção também é exposta para acessibilidade.

navigationButtons desenha voltar e avançar. O botão voltar só aparece após a primeira pergunta. Avançar fica desabilitado quando não há seleção. nextQuestion avança ou ativa showResult na quinta pergunta. previousQuestion volta sem apagar escolhas.

resultScreen é a rolagem do resultado. resultHeader desenha a faixa azul, o ícone sobreposto, o nome vencedor e os pontos. resultSymbol escolhe um SF Symbol para cada área.

scoreSection mostra as três primeiras áreas. O valor mostrado é percentage(for: area) multiplicado por resultProgress. GeometryReader fornece a largura disponível, e a barra preenchida usa essa largura multiplicada pelo percentual dividido por 100. Número e barra consultam o mesmo progresso e sobem juntos.

winningAnswersSection desenha até dois cartões. LazyVGrid usa colunas adaptáveis: duas quando há espaço e uma em uma largura menor, evitando rolagem horizontal. Cada cartão mostra o texto da resposta, a pergunta original e seu peso. Os círculos 1 e 2 indicam a ordem das maiores contribuições.

areaDescription apresenta a descrição da área em um cartão azul. restartButton chama restartQuiz. Os modificadores font, foregroundStyle/foregroundColor, padding, background, frame, clipShape e shadow definem, respectivamente, fonte, cor, espaçamento, fundo, tamanho/alinhamento, recorte e sombra.

## 7. Animação e reinício

A .task do resultado chama animateResult quando essa parte aparece. A função zera resultProgress e acompanha o tempo com ContinuousClock, que mede tempo decorrido. Divide o tempo por 1,5 segundo para obter uma fração entre 0 e 1. A fórmula fraction × fraction × (3 − 2 × fraction) suaviza a aceleração e a desaceleração.

O laço atualiza o progresso aproximadamente a cada 16 milissegundos. Task.sleep suspende a tarefa entre atualizações, sem travar a interface. Ao chegar em 1, termina. Se a tela desaparecer, o SwiftUI cancela a tarefa, e o tratamento da suspensão encerra a função. Com Reduzir Movimento ativado, o resultado aparece diretamente no valor final.

restartQuiz volta à primeira pergunta, apaga seleções, zera o progresso e esconde o resultado. As perguntas já carregadas do Notion permanecem na memória da sessão. Uma nova execução do aplicativo consulta novamente.

#Preview permite abrir a prévia no Xcode. Como não há perguntas locais, a prévia também depende de configurar acesso ao Notion; não contém dados de exemplo.

## 8. Configurar e conferir

No Xcode: Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables. Habilite BEARER_TOKEN e NOTION_DATA_SOURCE_ID. A integração precisa ter acesso à fonte quiz. Os títulos devem começar com 1. até 5.; as outras colunas devem se chamar exatamente alternativa_A até alternativa_E e ser Rich text.

Confira no simulador: carregar as perguntas, selecionar/voltar/trocar uma resposta, terminar o quiz, observar barras e percentuais, conferir os dois maiores pesos nos cartões e refazer o quiz. Sem as variáveis, deve aparecer erro, nunca perguntas locais.

A estrutura do arquivo de projeto foi validada com plutil. Não foi possível compilar ou executar o simulador neste ambiente, pois as ferramentas do Xcode não estão configuradas. A execução real continua necessária para confirmar compilação, aparência e integração com sua fonte.
