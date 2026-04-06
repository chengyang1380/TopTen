import Testing
import Foundation
@testable import TopTen

@Suite("抽數字功能測試 (SDD)")
@MainActor
struct NumberDrawingViewModelTests {
    
    @Test("驗證可以自定義最大值 (例如 8)")
    func test_customMaxValue_initializesCorrectly() async throws {
        let viewModel = NumberDrawingViewModel()
        await viewModel.updateMaxNumber(to: 8)
        
        #expect(viewModel.maxNumber == 8)
        #expect(viewModel.remainingCount == 8)
    }
    
    @Test("驗證設定新最大值後會重置數字池")
    func test_updateMaxNumber_resetsPool() async throws {
        let viewModel = NumberDrawingViewModel()
        
        await viewModel.drawNumber() // 剩下 9 張
        await viewModel.updateMaxNumber(to: 12)
        
        #expect(viewModel.remainingCount == 12)
        #expect(viewModel.lastDrawnNumber == nil)
    }
    
    @Test("驗證在自定義最大值 (5) 下抽完所有數字")
    func test_drawingUntilEmpty_withCustomMax() async throws {
        let viewModel = NumberDrawingViewModel()
        await viewModel.updateMaxNumber(to: 5)
        
        for _ in 1...5 {
            await viewModel.drawNumber()
        }
        
        #expect(viewModel.remainingCount == 0)
        #expect(viewModel.isPoolEmpty == true)
    }
}
