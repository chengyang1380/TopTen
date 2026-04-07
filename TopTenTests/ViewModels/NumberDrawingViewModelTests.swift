import Testing
import Foundation
@testable import TopTen

@Suite("發牌功能測試 (SDD)")
@MainActor
struct NumberDrawingViewModelTests {
    
    @Test("驗證初始化狀態下需要設定人數")
    func test_initialState_requiresSetup() async throws {
        let viewModel = NumberDrawingViewModel()
        #expect(viewModel.isSetupRequired == true)
        #expect(viewModel.cards.isEmpty == true)
    }
    
    @Test("驗證確認人數後正確分配卡片")
    func test_confirmSetup_generatesCorrectNumberOfCards() async throws {
        let viewModel = NumberDrawingViewModel()
        viewModel.playerCount = 6
        
        await viewModel.confirmSetup()
        
        #expect(viewModel.cards.count == 6)
        #expect(viewModel.isSetupRequired == false)
    }
    
    @Test("驗證分配的數字是否在範圍內且不重複")
    func test_confirmSetup_assignsUniqueNumbers() async throws {
        let viewModel = NumberDrawingViewModel()
        let count = 8
        viewModel.playerCount = count
        
        await viewModel.confirmSetup()
        
        let numbers = viewModel.cards.map { $0.number }
        let uniqueNumbers = Set(numbers)
        
        #expect(numbers.count == count)
        #expect(uniqueNumbers.count == count)
        #expect(numbers.allSatisfy { $0 >= 1 && $0 <= count })
    }
    
    @Test("驗證切換卡片揭曉狀態")
    func test_toggleReveal_changesCardState() async throws {
        let viewModel = NumberDrawingViewModel()
        await viewModel.confirmSetup()
        
        let cardId = try #require(viewModel.cards.first?.id)
        
        // 初始應該是隱藏
        #expect(viewModel.cards[0].isRevealed == false)
        
        // 揭曉
        viewModel.toggleReveal(for: cardId)
        #expect(viewModel.cards[0].isRevealed == true)
        
        // 再次蓋上
        viewModel.toggleReveal(for: cardId)
        #expect(viewModel.cards[0].isRevealed == false)
    }
    
    @Test("驗證重新洗牌後卡片數量不變")
    func test_reshuffle_maintainsCardCount() async throws {
        let viewModel = NumberDrawingViewModel()
        viewModel.playerCount = 10
        await viewModel.confirmSetup()
        
        await viewModel.reshuffle()
        
        #expect(viewModel.cards.count == 10)
    }
}
