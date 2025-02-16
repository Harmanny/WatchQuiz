import SwiftUI

struct Highscore: Codable {
    var score: Int
    var time: Double
    
    func calculatedScore() -> Double {
        return Double(score) * 1000.0 - time // Prioritize correctness, then speed
    }
}

struct HighscoreView: View {
    @AppStorage("highscores") private var highscoresData: Data = Data()
    
    private var highscores: [Int: Highscore] {
        get {
            if let decoded = try? JSONDecoder().decode([Int: Highscore].self, from: highscoresData) {
                return decoded
            }
            return [:]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                highscoresData = encoded
            }
        }
    }
    
    var body: some View {
        List(highscores.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
            VStack(alignment: .leading) {
                Text("\(key) Questions")
                    .font(.headline)
                Text("Highscore: \(value.score), Time: \(String(format: "%.2f", value.time))s")
                    .font(.subheadline)
            }
        }
        .navigationTitle("Highscores")
    }
}
