import Foundation
import SwiftData

/// 題目服務介面
public protocol QuestionServiceProtocol: Sendable {
    func fetchQuestions(category: String, limit: Int?, offset: Int?) async throws -> [QuestionModel]
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
    public func fetchQuestions(category: String, limit: Int? = nil, offset: Int? = nil) async throws -> [QuestionModel] {
        var descriptor = FetchDescriptor<QuestionModel>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
        if let offset = offset {
            descriptor.fetchOffset = offset
        }
        
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
    
    /// 種子資料初始化 (Seeding)：補齊缺失的內建題目
    @MainActor
    public func seedInitialQuestions(from jsonQuestions: [QuestionModel]) async throws {
        // 獲取目前資料庫中所有的內建題目內容
        let descriptor = FetchDescriptor<QuestionModel>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let existingQuestions = try container.mainContext.fetch(descriptor)
        let existingContents = Set(existingQuestions.map { $0.content })
        
        // 只插入資料庫中還沒有的題目
        for question in jsonQuestions {
            if !existingContents.contains(question.content) {
                container.mainContext.insert(question)
            }
        }
        
        try container.mainContext.save()
    }
}
