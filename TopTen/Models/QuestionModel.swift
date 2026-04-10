import Foundation
import SwiftData

@Model
public final class QuestionModel: Identifiable, Sendable {
    @Attribute(.unique) public var id: UUID
    public var content: String
    public var scaleLow: String
    public var scaleHigh: String
    public var category: String
    public var isBuiltIn: Bool
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        content: String,
        scaleLow: String,
        scaleHigh: String,
        category: String,
        isBuiltIn: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.content = content
        self.scaleLow = scaleLow
        self.scaleHigh = scaleHigh
        self.category = category
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
    }
}
