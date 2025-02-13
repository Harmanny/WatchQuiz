import SwiftUI
import Combine

// Question Model
struct Question: Codable, Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let answer: String
    let category: String
    
    private enum CodingKeys: String, CodingKey {
        case question, options, answer, category
    }
}

// Question Manager
class QuestionManager: ObservableObject {
    @Published var questions: [Question] = []
    @Published var categories: [String] = []
    private var categoriesLoaded = false
    
    init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        if let url = Bundle.main.url(forResource: "questions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedQuestions = try JSONDecoder().decode([Question].self, from: data)
                questions = decodedQuestions
                if !categoriesLoaded {
                    extractCategories()
                    categoriesLoaded = true
                }
            } catch {
                print("Error loading questions: \(error)")
            }
        }
    }
    
    private func extractCategories() {
        let uniqueCategories = Set(questions.map { $0.category })
        categories = Array(uniqueCategories).sorted()
    }
    
    func getFilteredQuestions(categories: [String], count: Int) -> [Question] {
        let filtered = questions.filter { categories.contains($0.category) }
        return Array(filtered.shuffled().prefix(count))
    }
}
