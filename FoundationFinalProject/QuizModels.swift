import SwiftUI

enum QuizArea: String, CaseIterable, Identifiable {
    case frontend = "Front-end"
    case backend = "Back-end"
    case uiux = "Design UI/UX"
    case cybersecurity = "Cibersegurança"
    case devops = "DevOps"
    var id: String {
        rawValue
    }
    var description: String {
        switch self {
        case .frontend:
            return """
            Front-end é a área responsável pela parte visual e interativa de aplicações e sites.

            Profissionais dessa área trabalham com interfaces, componentes, responsividade, acessibilidade e experiência de navegação.

            Tecnologias comuns: HTML, CSS, JavaScript, SwiftUI e React.
            """
        case .backend:
            return """
            Back-end é a área responsável pela lógica interna das aplicações.

            Profissionais dessa área trabalham com servidores, APIs, bancos de dados, autenticação e processamento de informações.

            Tecnologias comuns: Java, Python, Node.js, PostgreSQL e SQL.
            """
        case .uiux:
            return """
            Design UI/UX envolve a criação e o planejamento de interfaces digitais e experiências de utilização.

            Profissionais dessa área estudam usabilidade, identidade visual, prototipagem, acessibilidade e comportamento dos usuários.

            Ferramentas comuns: Figma, Adobe XD e ferramentas de prototipagem.
            """
        case .cybersecurity:
            return """
            Cibersegurança é a área responsável pela proteção de sistemas, redes, aplicações e informações.

            Profissionais dessa área trabalham com análise de vulnerabilidades, monitoramento, segurança de redes e prevenção de ameaças.

            Tecnologias comuns: Linux, redes, ferramentas de segurança e análise de vulnerabilidades.
            """
        case .devops:
            return """
            DevOps integra desenvolvimento de software e operações de infraestrutura.

            Profissionais dessa área trabalham com automação, integração contínua, entrega contínua, infraestrutura e monitoramento.

            Tecnologias comuns: Docker, Git, Linux, CI/CD e ferramentas de cloud.
            """
        }
    }
}

struct QuizOption: Identifiable {
    let letter: String
    let text: String
    let area: QuizArea
    var id: String {
        letter
    }
}

struct QuizQuestion: Identifiable {
    let id: Int
    let title: String
    let weight: Int
    let options: [QuizOption]
}

extension Color {
    static let quizBackground = Color(hex: 0xF8F9FA)
    static let quizBlue = Color(hex: 0x0F3B4C)
    static let quizOption = Color(hex: 0x527A8A)
    static let quizGray = Color(hex: 0xA0AAB2)
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
