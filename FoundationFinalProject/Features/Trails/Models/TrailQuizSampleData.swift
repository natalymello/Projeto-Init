import Foundation

// Perguntas de demonstração para conferir o layout sem conectar ao Notion.
enum TrailQuizSampleData {
    static let questions = [
        TrailQuizQuestion(
            id: "demo-1", order: 1,
            prompt: "O que significa a sigla API?",
            options: ["Application Programming Interface", "Automated Program Internet", "Applied Platform Input", "Apple Programming Item"],
            correctAnswer: "A", points: 10,
            explanation: "Uma API define como diferentes programas podem trocar informações."
        ),
        TrailQuizQuestion(
            id: "demo-2", order: 2,
            prompt: "Qual linguagem é usada para criar a interface deste aplicativo?",
            options: ["HTML", "Swift", "SQL", "Bash"],
            correctAnswer: "B", points: 10,
            explanation: "O aplicativo foi feito em Swift com a biblioteca SwiftUI."
        ),
        TrailQuizQuestion(
            id: "demo-3", order: 3,
            prompt: "Para que serve uma senha forte?",
            options: ["Aumentar o brilho", "Deixar a internet mais rápida", "Dificultar o acesso indevido", "Liberar espaço no celular"],
            correctAnswer: "C", points: 10,
            explanation: "Senhas longas e únicas ajudam a proteger contas."
        ),
        TrailQuizQuestion(
            id: "demo-4", order: 4,
            prompt: "O que é um banco de dados?",
            options: ["Um tipo de tela", "Um cabo de rede", "Um editor de imagens", "Um lugar organizado para guardar informações"],
            correctAnswer: "D", points: 10,
            explanation: "Bancos de dados organizam informações para que aplicativos possam consultá-las."
        ),
        TrailQuizQuestion(
            id: "demo-5", order: 5,
            prompt: "O que significa salvar um projeto no Git?",
            options: ["Registrar uma versão das alterações", "Desligar o computador", "Apagar os arquivos antigos", "Publicar automaticamente na loja"],
            correctAnswer: "A", points: 10,
            explanation: "O Git guarda o histórico das alterações de um projeto."
        )
    ]
}
