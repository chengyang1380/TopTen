import Foundation
import Observation

/// 牌卡資料結構
public struct PlayerCard: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let number: Int      // 藏在牌下的數字
    public let playerIndex: Int // 玩家編號 (1-n)
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
    
    public private(set) var cards: [PlayerCard] = []
    public var playerCount: Int = 8 // 預設值
    public var isSetupRequired: Bool = true // 是否需要初始設定
    
    public init() {}
    
    /// 確認設定並生成卡片
    public func confirmSetup() async {
        let shuffledNumbers = await distributor.distribute(count: playerCount)
        self.cards = shuffledNumbers.enumerated().map { index, number in
            PlayerCard(number: number, playerIndex: index + 1)
        }
        self.isSetupRequired = false
    }
    
    /// 取消設定 (僅關閉 Overlay)
    public func cancelSetup() {
        guard !cards.isEmpty else { return } // 若沒卡片不能取消
        self.isSetupRequired = false
    }
    
    /// 開啟設定畫面
    public func openSettings() {
        self.isSetupRequired = true
    }
    
    /// 切換特定卡片的揭曉狀態
    public func toggleReveal(for cardId: UUID) {
        if let index = cards.firstIndex(where: { $0.id == cardId }) {
            cards[index].isRevealed.toggle()
        }
    }
    
    /// 重新洗牌
    public func reshuffle() async {
        let shuffledNumbers = await distributor.distribute(count: playerCount)
        self.cards = shuffledNumbers.enumerated().map { index, number in
            PlayerCard(number: number, playerIndex: index + 1)
        }
    }
}
