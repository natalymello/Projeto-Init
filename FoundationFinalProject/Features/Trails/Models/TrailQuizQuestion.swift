import Foundation

struct TrailQuizQuestion: Identifiable {
    let id: String
    let order: Int
    let prompt: String
    let options: [String]
    let correctAnswer: String
    let points: Int
    let explanation: String
}
