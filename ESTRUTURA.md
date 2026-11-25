# Organização do projeto

- `FoundationFinalProject/App/`: ponto de entrada e navegação entre Trilhas e Glossário.
- `FoundationFinalProject/Features/Quiz/Models/`: perguntas, alternativas, áreas e cálculo da pontuação.
- `FoundationFinalProject/Features/Quiz/ViewModels/`: carregamento do quiz e serviço Notion existente.
- `FoundationFinalProject/Features/Quiz/Views/`: tela de perguntas (`QuizView`) e tela do resultado (`QuizResultView`).
- `FoundationFinalProject/Features/Trails/Models/`: modelos do Notion e status dos conteúdos.
- `FoundationFinalProject/Features/Trails/Stores/`: carregamento e ordenação das trilhas.
- `FoundationFinalProject/Features/Trails/Views/`: lista, grafo, detalhes e questionário final.
- `FoundationFinalProject/Resources/`: catálogo de imagens, ícone e cores.

O Xcode usa um grupo sincronizado com a pasta FoundationFinalProject, incluindo automaticamente os arquivos das subpastas. Não é necessário arrastá-los novamente para o projeto.

Esta organização mantém os tipos, a navegação e o funcionamento existentes. As configurações do Scheme permanecem no projeto Xcode.

## Integração com o glossário

`App/InitRootView.swift` abre as abas Trilhas e Glossário. O quiz de área pode ser iniciado na tela Trilhas. O questionário final de cada trilha fica em `Features/Trails` e usa o Notion; perguntas fictícias ficam disponíveis só para demonstração. O glossário permanece em `Glossario/`, com consulta própria ao Notion, agrupamento alfabético e detalhe opaco. As cores vêm de `Resources/Assets.xcassets`. O resultado do quiz de área salva a recomendação e pode voltar às Trilhas.
