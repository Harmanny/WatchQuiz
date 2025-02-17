import SwiftUI

struct SettingsView: View {
    @StateObject private var questionManager = QuestionManager()
    @AppStorage("selectedCategories") private var selectedCategoriesString: String = ""
    @AppStorage("questionCount") private var questionCount: Int = 10
    
    @State private var selectedCategories: [String] = []
    @State private var availableCategories: [String] = []
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Select Categories")) {
                    ForEach(availableCategories, id: \ .self) { category in
                        Toggle(category, isOn: Binding(
                            get: { selectedCategories.contains(category) },
                            set: { newValue in
                                if newValue {
                                    selectedCategories.append(category)
                                } else {
                                    selectedCategories.removeAll { $0 == category }
                                }
                                selectedCategoriesString = selectedCategories.joined(separator: ",")
                            }
                        ))
                    }
                }
                
                Section(header: Text("Number of Questions")) {
                    Stepper(value: $questionCount, in: 5...20, step: 5) {
                        Text("\(questionCount)")
                    }
                }
            }
        }
        .onAppear {
            let allCategories = questionManager.categories
            let savedCategories = selectedCategoriesString.components(separatedBy: ",").filter { !$0.isEmpty }
            
            if savedCategories.isEmpty, !allCategories.isEmpty {
                selectedCategoriesString = allCategories.joined(separator: ",")
                selectedCategories = allCategories
            } else {
                selectedCategories = savedCategories
            }
            
            availableCategories = allCategories
        }
    }
}

