# Organização do projeto

- `FoundationFinalProject/App/`: ponto de entrada e navegação entre quiz e trilhas.
- `FoundationFinalProject/Features/Quiz/Models/`: perguntas, alternativas, áreas e cores existentes do quiz.
- `FoundationFinalProject/Features/Quiz/ViewModels/`: carregamento do quiz e serviço Notion existente.
- `FoundationFinalProject/Features/Quiz/Views/`: interface do quiz e resultado (`ContentView`).
- `FoundationFinalProject/Features/Trails/Models/`: modelos do Notion e status dos conteúdos.
- `FoundationFinalProject/Features/Trails/Stores/`: carregamento e ordenação das trilhas.
- `FoundationFinalProject/Features/Trails/Views/`: lista, grafo e cartões de conteúdo.
- `FoundationFinalProject/Resources/`: catálogo de imagens, ícone e cores.

O Xcode usa um grupo sincronizado com a pasta FoundationFinalProject, incluindo automaticamente os arquivos das subpastas. Não é necessário arrastá-los novamente para o projeto.

Esta organização mantém os tipos, a navegação e o funcionamento existentes. As configurações do Scheme permanecem no projeto Xcode.

## Integração com o glossário

`App/InitRootView.swift` reúne as abas Quiz, Trilhas e Glossário. A tela do quiz está em `Features/Quiz/Views/QuizView.swift`, com seus modelos e ViewModel em `Features/Quiz`. O glossário permanece em `Glossario/`, com consulta própria ao Notion, agrupamento alfabético e detalhe opaco. As cores compartilhadas agora vêm de `Resources/Assets.xcassets`, sem extensões duplicadas de Color. O botão Continuar do resultado preserva a recomendação e abre Trilhas.
