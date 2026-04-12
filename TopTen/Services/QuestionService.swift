import Foundation
import SwiftData

/// 題目服務介面
public protocol QuestionServiceProtocol: Sendable {
    func fetchQuestions(category: String) async throws -> [QuestionModel]
    func addQuestion(_ question: QuestionModel) async throws
    func deleteQuestion(_ question: QuestionModel) async throws
    func fetchRandomQuestion(category: String) async throws -> QuestionModel?
}

/// 實際的 SwiftData 實作
public final actor QuestionService: QuestionServiceProtocol {
    private let container: ModelContainer
    
    public init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    public func fetchQuestions(category: String) async throws -> [QuestionModel] {
        let descriptor = FetchDescriptor<QuestionModel>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try container.mainContext.fetch(descriptor)
    }
    
    @MainActor
    public func addQuestion(_ question: QuestionModel) async throws {
        container.mainContext.insert(question)
        try container.mainContext.save()
    }
    
    @MainActor
    public func deleteQuestion(_ question: QuestionModel) async throws {
        container.mainContext.delete(question)
        try container.mainContext.save()
    }
    
    @MainActor
    public func fetchRandomQuestion(category: String) async throws -> QuestionModel? {
        let all = try await fetchQuestions(category: category)
        return all.randomElement()
    }
    
    /// 種子資料初始化 (Seeding)
    @MainActor
    public func seedInitialQuestions(from jsonQuestions: [QuestionModel]) async throws {
        // 檢查是否已存在內建題目，避免重複 Seeding
        let descriptor = FetchDescriptor<QuestionModel>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let existing = try container.mainContext.fetch(descriptor)
        
        if existing.isEmpty {
            for question in jsonQuestions {
                container.mainContext.insert(question)
            }
            try container.mainContext.save()
        }
    }
}
