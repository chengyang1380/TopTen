import Testing
import Foundation
@testable import TopTen

@Suite("抽數字功能測試")
@MainActor
struct NumberDrawingViewModelTests {
    
    @Test("驗證初始化時數字池應有 10 張牌")
    func test_initialization_hasTenNumbers() async throws {
        let viewModel = NumberDrawingViewModel()
        let count = viewModel.remainingCount
        #expect(count == 10)
        #expect(viewModel.isPoolEmpty == false)
    }
    
    @Test("驗證抽牌後剩餘張數會減少且記錄最後抽中數字")
    func test_drawNumber_updatesState() async throws {
        let viewModel = NumberDrawingViewModel()
        
        await viewModel.drawNumber()
        
        #expect(viewModel.remainingCount == 9)
        #expect(viewModel.lastDrawnNumber != nil)
    }
    
    @Test("驗證連續抽 10 次後數字池應清空並標記為 Empty")
    func test_drawingTenTimes_emptiesPool() async throws {
        let viewModel = NumberDrawingViewModel()
        
        for _ in 1...10 {
            await viewModel.drawNumber()
        }
        
        #expect(viewModel.remainingCount == 0)
        #expect(viewModel.isPoolEmpty == true)
    }
    
    @Test("驗證重置後數字池應重新回到 10 張牌")
    func test_resetPool_restoresFullCount() async throws {
        let viewModel = NumberDrawingViewModel()
        
        // 先抽幾次
        await viewModel.drawNumber()
        await viewModel.drawNumber()
        
        // 執行重置
        await viewModel.resetPool()
        
        #expect(viewModel.remainingCount == 10)
        #expect(viewModel.lastDrawnNumber == nil)
        #expect(viewModel.isPoolEmpty == false)
    }
}
