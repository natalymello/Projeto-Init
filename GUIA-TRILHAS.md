# Trilhas no Init

## Variáveis no Scheme (Run → Arguments → Environment Variables)
- `BEARER_TOKEN`: token da integração Notion, com acesso às bases do quiz e das trilhas.
- `NOTION_DATA_SOURCE_ID`: ID da fonte do quiz, preservado da implementação existente.
- `NOTION_TRAILS_DATA_SOURCE_ID`: ID da fonte de trilhas, a mesma utilizada no exemplo_grafos.

Não inclua o prefixo Bearer no token. Não publique valores de credenciais. As variáveis do Scheme são usadas ao executar pelo Xcode.

## Navegação
InitRootView abre o quiz e permite acessar as trilhas pela aba Trilhas. O resultado do quiz também possui o botão Continuar para as trilhas. A escolha do quiz ainda não altera a ordenação das trilhas automaticamente.

## Arquivos importados do exemplo
TrailsView (lista), TrailsStore (consulta), TrailModels (mapeamento do Notion), RoadmapView (grafo), NodeCard (conteúdo, exemplo e status). Não foi importado o ponto de entrada do aplicativo de exemplo.

## Ordenação e progresso
A lista segue o campo Ordem do Notion. Para trocar uma trilha com a primeira, configure firstTrailKey em TrailsStore com o valor exato de Key. O status continua manual e local via AppStorage; depende não impõe bloqueio automático. O progresso salvo no app exemplo não é transferido automaticamente ao Init, que possui outro armazenamento de aplicativo.

Compatibilidade: os títulos usam `@NotionTitle` porque a revisão do swift-notion fixada no Init não gera corretamente a inicialização de `@NotionTitleProperty`. O pacote foi mantido na revisão existente.
