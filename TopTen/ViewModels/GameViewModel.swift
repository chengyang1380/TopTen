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
    
    public init(category: String, service: QuestionServiceProtocol? = nil) {
        self.category = category
        self.service = service
    }
    
    /// 取得過濾後的題目清單
    public var filteredQuestions: [QuestionModel] {
        if searchText.isEmpty {
            return allQuestions
        }
        return allQuestions.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }
    
    /// 重新載入所有題目
    public func loadQuestions() async {
        guard let service = service else { return }
        do {
            self.allQuestions = try await service.fetchQuestions(category: category)
        } catch {
            print("無法載入題目: \(error)")
        }
    }
    
    /// 設置服務 (DI)
    public func setup(service: QuestionServiceProtocol) {
        self.service = service
    }
    
    /// 隨機出題
    public func pickRandomQuestion() {
        self.currentQuestion = allQuestions.randomElement()
    }
    
    /// 刪除題目
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
