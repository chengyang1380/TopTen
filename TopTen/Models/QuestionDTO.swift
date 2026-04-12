import Foundation

/// 用於解析 JSON 的資料傳輸對象
public struct QuestionDTO: Decodable, Sendable {
    public let content: String
    public let scaleLow: String
    public let scaleHigh: String
    public let category: String
    
    public func toModel() -> QuestionModel {
        QuestionModel(
            content: content,
            scaleLow: scaleLow,
            scaleHigh: scaleHigh,
            category: category,
            isBuiltIn: true
        )
    }
}

/// 負責從 Bundle 載入 JSON 的工具
public final class QuestionDataLoader {
    public static func loadBuiltInQuestions() -> [QuestionModel] {
        let files = ["questions_basic"] // 未來可加入 "questions_adventure", "questions_nsfw"
        var allModels: [QuestionModel] = []
        
        let decoder = JSONDecoder()
        
        for fileName in files {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let dtos = try? decoder.decode([QuestionDTO].self, from: data) else {
                continue
            }
            allModels.append(contentsOf: dtos.map { $0.toModel() })
        }
        
        return allModels
    }
}
