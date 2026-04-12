import Foundation
import Observation
import SwiftData

@Observable
@MainActor
public final class GameViewModel {
    public let category: String
    private(set) var service: QuestionServiceProtocol?
    
    public var allQuestions: [QuestionModel] = []
    public var currentQuestion: QuestionModel?
    public var searchText: String = ""
    public var isShowingAddSheet: Bool = false
    public var isShowingQuestionDialog: Bool = false
    public var isLoading: Bool = false
    
    public init(category: String, service: QuestionServiceProtocol? = nil) {
        self.category = category
        self.service = service
    }
    
    /// 取得過濾後的題目清單 (全域搜尋)
    public var filteredQuestions: [QuestionModel] {
        if searchText.isEmpty {
            return allQuestions
        }
        return allQuestions.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }
    
    /// 載入該分類下的所有題目
    public func loadQuestions() async {
        guard let service = service else { return }
        isLoading = true
        do {
            self.allQuestions = try await service.fetchQuestions(category: category, limit: nil, offset: nil)
        } catch {
            print("無法載入題目: \(error)")
        }
        isLoading = false
    }
    
    public func setup(service: QuestionServiceProtocol) {
        self.service = service
    }
    
    public func pickRandomQuestion() {
        guard !allQuestions.isEmpty else { return }
        self.currentQuestion = allQuestions.randomElement()
        self.isShowingQuestionDialog = true
    }
    
    public func deleteQuestion(at offsets: IndexSet) async {
        guard let service = service else { return }
        
        for index in offsets {
            let question = filteredQuestions[index]
            if !question.isBuiltIn {
                try? await service.deleteQuestion(question)
            }
        }
        await loadQuestions()
    }
    
    public func openAddSheet() {
        self.isShowingAddSheet = true
    }
}
