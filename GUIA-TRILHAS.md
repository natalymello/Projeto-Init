# Trilhas no Init

## Variáveis no Scheme (Run → Arguments → Environment Variables)
- `BEARER_TOKEN`: token da integração Notion, com acesso às bases do quiz e das trilhas.
- `NOTION_DATA_SOURCE_ID`: ID da fonte do quiz, preservado da implementação existente.
- `NOTION_TRAILS_DATA_SOURCE_ID`: ID da fonte de trilhas, a mesma utilizada no exemplo_grafos.
- `NOTION_TRAIL_QUIZ_DATA_SOURCE_ID`: ID da fonte de dados do questionário final das trilhas.

Não inclua o prefixo Bearer no token. Não publique valores de credenciais. As variáveis do Scheme são usadas ao executar pelo Xcode.

## Navegação
InitRootView abre as abas Trilhas e Glossário. O quiz de área é iniciado pelo botão da tela Trilhas; ao terminar, o resultado salva a área sugerida e pode retornar às trilhas. A escolha do quiz ainda não altera a ordenação automaticamente.

## Arquivos importados do exemplo
TrailsView (lista), TrailsStore (consulta), TrailModels (mapeamento do Notion), RoadmapView (grafo), RoadmapNodeView (nós) e TrailNodeDetailView (conteúdo, exemplo e status). Não foi importado o ponto de entrada do aplicativo de exemplo.

## Ordenação e progresso
A lista segue o campo Ordem do Notion. Para trocar uma trilha com a primeira, configure firstTrailKey em TrailsStore com o valor exato de Key. O status continua manual e local via AppStorage; depende não impõe bloqueio automático. O progresso salvo no app exemplo não é transferido automaticamente ao Init, que possui outro armazenamento de aplicativo.

Compatibilidade: os títulos usam `@NotionTitle` porque a revisão do swift-notion fixada no Init não gera corretamente a inicialização de `@NotionTitleProperty`. O pacote foi mantido na revisão existente.

## Questionário ao final da trilha
O botão no fim do mapa abre um questionário carregado do Notion. As perguntas são filtradas pela propriedade `Key_trilha`, cujo valor precisa ser igual à chave da trilha usada pelo aplicativo. Crie estas propriedades na fonte de dados do questionário:

| Propriedade | Tipo | Conteúdo |
| --- | --- | --- |
| `Pergunta` | Título | Enunciado |
| `Key_trilha` | Texto | Chave da trilha (por exemplo, `devops`) |
| `Alternativa_A` | Texto | Texto da opção A |
| `Alternativa_B` | Texto | Texto da opção B |
| `Alternativa_C` | Texto | Texto da opção C |
| `Alternativa_D` | Texto | Texto da opção D |
| `Resposta_correta` | Seleção ou texto | Uma letra: `A`, `B`, `C` ou `D` |
| `Pontos` | Número | Pontos por acerto (padrão 1 se vazio) |
| `Ordem` | Número | Posição da pergunta (padrão 0 se vazio) |
| `Explicacao` | Texto | Explicação opcional mostrada após responder |

Cadastre uma linha por pergunta. O app usa registros com enunciado, quatro alternativas e resposta correta preenchidos. Ele soma os pontos das respostas certas e mostra o resultado final. No Scheme do Xcode, reutilize `BEARER_TOKEN` e adicione `NOTION_TRAIL_QUIZ_DATA_SOURCE_ID`. Compartilhe a fonte com a integração Notion usada pelo app. Não grave o token no código nem no repositório.

### Testar apenas o layout
Para abrir cinco perguntas fictícias sem configurar o Notion, adicione temporariamente `TRAIL_QUIZ_DEMO` com valor `true` em **Run → Arguments → Environment Variables** no Scheme do Xcode. A tela mostrará o aviso “Modo de demonstração”. Apague ou desmarque essa variável para voltar a carregar as perguntas reais do Notion. Esses dados servem apenas para visualizar o questionário e não são enviados ao Notion.
