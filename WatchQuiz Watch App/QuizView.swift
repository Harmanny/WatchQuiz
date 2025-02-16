import SwiftUI

struct QuizView: View {
    @StateObject private var questionManager = QuestionManager()
    @AppStorage("selectedCategories") private var selectedCategoriesString: String = ""
    @AppStorage("questionCount") private var questionCount: Int = 10
    @AppStorage("highscores") private var highscoresData: Data = Data()
    
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var quizCompleted = false
    @State private var randomizedQuestions: [Question] = []
    @State private var selectedAnswer: String? = nil
    @State private var showFeedback = false
    @State private var startTime = Date()
    @State private var localHighscores: [Int: Highscore] = [:]
    
    private var selectedCategories: [String] {
        selectedCategoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if quizCompleted {
                    Text("Quiz Over! Score: \(score)/\(randomizedQuestions.count)")
                        .font(.title)
                        .padding()
                    Button("Restart") {
                        restartQuiz()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                } else if currentIndex < randomizedQuestions.count {
                    Text(randomizedQuestions[currentIndex].question)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    
                    ForEach(randomizedQuestions[currentIndex].options, id: \ .self) { option in
                        Button(action: {
                            checkAnswer(option)
                        }) {
                            Text(option)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(buttonColor(for: option))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(showFeedback)
                    }
                }
            }
            .padding()
            .onAppear {
                loadRandomizedQuestions()
                startTime = Date()
                if let decoded = try? JSONDecoder().decode([Int: Highscore].self, from: highscoresData) {
                    localHighscores = decoded
                }
            }
        }
    }
    
    private func checkAnswer(_ selected: String) {
        selectedAnswer = selected
        showFeedback = true
        
        if selected == randomizedQuestions[currentIndex].answer {
            score += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentIndex < randomizedQuestions.count - 1 {
                currentIndex += 1
                selectedAnswer = nil
                showFeedback = false
            } else {
                quizCompleted = true
                saveHighscore()
            }
        }
    }
    
    private func buttonColor(for option: String) -> Color {
        if let selected = selectedAnswer {
            if option == randomizedQuestions[currentIndex].answer {
                return .green
            } else if option == selected {
                return .red
            } else {
                return .gray
            }
        }
        return .blue
    }
    
    private func restartQuiz() {
        currentIndex = 0
        score = 0
        quizCompleted = false
        selectedAnswer = nil
        showFeedback = false
        questionManager.resetAskedQuestions()
        loadRandomizedQuestions()
        startTime = Date()
    }
    
    private func loadRandomizedQuestions() {
        randomizedQuestions = questionManager.getFilteredQuestions(categories: selectedCategories, count: questionCount)
    }
    
    private func saveHighscore() {
        let timeTaken = Date().timeIntervalSince(startTime)
        let newScore = Highscore(score: score, time: timeTaken)
        
        if let existingScore = localHighscores[questionCount], existingScore.calculatedScore() > newScore.calculatedScore() {
            return
        }
        localHighscores[questionCount] = newScore
        
        if let encoded = try? JSONEncoder().encode(localHighscores) {
            highscoresData = encoded
        }
    }
}

