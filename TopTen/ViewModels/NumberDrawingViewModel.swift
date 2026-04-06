import Foundation
import Observation

/// 核心數字池，負責處理隨機逻辑與狀態同步 (Swift 6 Actor-based)
actor NumberPool {
    private var availableNumbers: [Int] = Array(1...10)
    
    func draw() -> Int? {
        guard !availableNumbers.isEmpty else { return nil }
        let randomIndex = Int.random(in: 0..<availableNumbers.count)
        return availableNumbers.remove(at: randomIndex)
    }
    
    func reset() {
        availableNumbers = Array(1...10)
    }
    
    func getRemainingCount() -> Int {
        return availableNumbers.count
    }
}

@Observable
@MainActor
public final class NumberDrawingViewModel {
    private let pool = NumberPool()
    
    public private(set) var lastDrawnNumber: Int?
    public private(set) var remainingCount: Int = 10
    public private(set) var isPoolEmpty = false
    
    public init() {}
    
    /// 執行抽數字動作 (Async)
    public func drawNumber() async {
        guard !isPoolEmpty else { return }
        
        let number = await pool.draw()
        self.lastDrawnNumber = number
        self.remainingCount = await pool.getRemainingCount()
        
        if self.remainingCount == 0 {
            self.isPoolEmpty = true
        }
    }
    
    /// 重置數字池
    public func resetPool() async {
        await pool.reset()
        self.lastDrawnNumber = nil
        self.remainingCount = await pool.getRemainingCount()
        self.isPoolEmpty = false
    }
}
