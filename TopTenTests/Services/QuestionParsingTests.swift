import Testing
import Foundation
@testable import TopTen

@Suite("題庫解析測試")
struct QuestionParsingTests {
    
    @Test("驗證 DTO 能正確轉換為 QuestionModel")
    func test_dtoToModel_conversion() {
        let dto = QuestionDTO(
            content: "測試",
            scaleLow: "1",
            scaleHigh: "10",
            category: "Basic"
        )
        
        let model = dto.toModel()
        
        #expect(model.content == "測試")
        #expect(model.category == "Basic")
        #expect(model.isBuiltIn == true)
    }
}
