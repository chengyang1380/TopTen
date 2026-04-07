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
    
    @Test("驗證揭曉流程：蓋牌狀態點擊應觸發確認對話框")
    func test_requestReveal_onHiddenCard_setsCardToToggle() async throws {
        let viewModel = NumberDrawingViewModel()
        await viewModel.confirmSetup()
        let card = viewModel.cards[0]
        
        // 動作：請求揭曉一張蓋著的牌
        viewModel.requestReveal(for: card)
        
        // 驗證：應該暫存該卡片以顯示確認對話框，且牌依然是蓋著的
        #expect(viewModel.cardToToggle == card)
        #expect(viewModel.cards[0].isRevealed == false)
    }
    
    @Test("驗證確認揭曉後卡片狀態變更")
    func test_confirmReveal_changesCardStateAndClearsToggle() async throws {
        let viewModel = NumberDrawingViewModel()
        await viewModel.confirmSetup()
        let card = viewModel.cards[0]
        
        viewModel.requestReveal(for: card)
        viewModel.confirmReveal(for: card.id)
        
        #expect(viewModel.cards[0].isRevealed == true)
        #expect(viewModel.cardToToggle == nil)
    }
    
    @Test("驗證揭曉狀態下再次點擊應直接蓋牌")
    func test_requestReveal_onRevealedCard_togglesBackDirectly() async throws {
        let viewModel = NumberDrawingViewModel()
        await viewModel.confirmSetup()
        let cardId = viewModel.cards[0].id
        
        // 先揭曉
        viewModel.confirmReveal(for: cardId)
        #expect(viewModel.cards[0].isRevealed == true)
        
        // 動作：再次請求揭曉（此時應該是蓋回去）
        viewModel.requestReveal(for: viewModel.cards[0])
        
        // 驗證：牌蓋回去了，且不需要對話框確認
        #expect(viewModel.cards[0].isRevealed == false)
        #expect(viewModel.cardToToggle == nil)
    }
    
    @Test("驗證重置請求會觸發 Alert 狀態")
    func test_requestReset_showsAlert() async throws {
        let viewModel = NumberDrawingViewModel()
        viewModel.requestReset()
        #expect(viewModel.isShowingResetAlert == true)
    }
    
    @Test("驗證重新洗牌後會關閉 Alert")
    func test_reshuffle_closesAlert() async throws {
        let viewModel = NumberDrawingViewModel()
        viewModel.requestReset()
        
        await viewModel.reshuffle()
        
        #expect(viewModel.isShowingResetAlert == false)
    }
}
