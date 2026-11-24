struct QuizResult {
    struct Contribution {
        let questionID: Int
        let answer: String
        let area: QuizArea
        let points: Int
    }

    let totalWeight: Int
    let rankedAreas: [QuizArea]
    let winningAnswers: [Contribution]
    private let scores: [QuizArea: Int]

    var winningArea: QuizArea { rankedAreas[0] }
    var winningScore: Int { scores[winningArea, default: 0] }

    init(questions: [QuizQuestion], answers: [Int: Int]) {
        var totals: [QuizArea: Int] = [:]
        var contributions: [Contribution] = []

        for question in questions {
            guard let index = answers[question.id], question.options.indices.contains(index) else { continue }
            let option = question.options[index]
            totals[option.area, default: 0] += question.weight
            contributions.append(Contribution(questionID: question.id, answer: option.text,
                                              area: option.area, points: question.weight))
        }

        // Em caso de empate, a ordem alfabética deixa o ranking previsível.
        let ranking = QuizArea.allCases.sorted { first, second in
            let firstScore = totals[first, default: 0]
            let secondScore = totals[second, default: 0]
            if firstScore == secondScore { return first.rawValue < second.rawValue }
            return firstScore > secondScore
        }

        scores = totals
        rankedAreas = ranking
        totalWeight = questions.reduce(0) { $0 + $1.weight }
        winningAnswers = Array(contributions.filter { $0.area == ranking[0] }
            .sorted { $0.points > $1.points }.prefix(2))
    }

    func percentage(for area: QuizArea) -> Double {
        guard totalWeight > 0 else { return 0 }
        return Double(scores[area, default: 0]) / Double(totalWeight) * 100
    }
}
