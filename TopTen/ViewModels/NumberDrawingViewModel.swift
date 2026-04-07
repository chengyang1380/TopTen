import Foundation
import Observation

/// 牌卡資料結構
public struct PlayerCard: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let number: Int
    public let playerIndex: Int
    public var isRevealed: Bool = false
    
    public init(number: Int, playerIndex: Int) {
        self.number = number
        self.playerIndex = playerIndex
    }
}

actor CardDistributor {
    func distribute(count: Int) -> [Int] {
        guard count > 0 else { return [] }
        var numbers = Array(1...count)
        numbers.shuffle()
        return numbers
    }
}

@Observable
@MainActor
public final class NumberDrawingViewModel {
    private let distributor = CardDistributor()
    
    // --- 業務數據狀態 ---
    public private(set) var cards: [PlayerCard] = []
    public var playerCount: Int = 8
    
    // --- UI 流程狀態 (Navigation/Flow) ---
    public var isSetupRequired: Bool = true
    public var isShowingResetAlert: Bool = false
    public var cardToToggle: PlayerCard? = nil // 用於 Bottom Sheet 的選中卡片
    
    public init() {}
    
    // --- Actions ---
    
    public func confirmSetup() async {
        let shuffledNumbers = await distributor.distribute(count: playerCount)
        self.cards = shuffledNumbers.enumerated().map { index, number in
            PlayerCard(number: number, playerIndex: index + 1)
        }
        self.isSetupRequired = false
    }
    
    public func cancelSetup() {
        guard !cards.isEmpty else { return }
        self.isSetupRequired = false
    }
    
    public func openSettings() {
        self.isSetupRequired = true
    }
    
    public func requestReset() {
        self.isShowingResetAlert = true
    }
    
    public func requestReveal(for card: PlayerCard) {
        if card.isRevealed {
            // 已揭曉則直接蓋牌 (無需確認)
            toggleReveal(for: card.id)
        } else {
            // 尚未揭曉則觸發 Bottom Sheet 確認
            self.cardToToggle = card
        }
    }
    
    public func confirmReveal(for cardId: UUID) {
        toggleReveal(for: cardId)
        self.cardToToggle = nil
    }
    
    private func toggleReveal(for cardId: UUID) {
        if let index = cards.firstIndex(where: { $0.id == cardId }) {
            cards[index].isRevealed.toggle()
        }
    }
    
    public func reshuffle() async {
        let shuffledNumbers = await distributor.distribute(count: playerCount)
        self.cards = shuffledNumbers.enumerated().map { index, number in
            PlayerCard(number: number, playerIndex: index + 1)
        }
        self.isShowingResetAlert = false
    }
}
