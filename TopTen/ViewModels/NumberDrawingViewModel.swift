import Foundation
import Observation

/// 核心數字池，負責處理隨機邏輯與狀態同步 (Swift 6 Actor-based)
actor NumberPool {
    private var availableNumbers: [Int] = []
    private var currentMax: Int = 10
    
    init(max: Int = 10) {
        self.currentMax = max
        self.availableNumbers = Array(1...max)
    }
    
    func draw() -> Int? {
        guard !availableNumbers.isEmpty else { return nil }
        let randomIndex = Int.random(in: 0..<availableNumbers.count)
        return availableNumbers.remove(at: randomIndex)
    }
    
    func reset(withMax newMax: Int? = nil) {
        if let newMax = newMax {
            self.currentMax = newMax
        }
        availableNumbers = Array(1...currentMax)
    }
    
    func getRemainingCount() -> Int {
        return availableNumbers.count
    }
    
    func getMaxNumber() -> Int {
        return currentMax
    }
}

@Observable
@MainActor
public final class NumberDrawingViewModel {
    private var pool = NumberPool(max: 10)
    
    public private(set) var lastDrawnNumber: Int?
    public private(set) var remainingCount: Int = 10
    public private(set) var maxNumber: Int = 10
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
    
    /// 更新最大值並重置數字池
    public func updateMaxNumber(to newMax: Int) async {
        guard newMax > 0 else { return }
        await pool.reset(withMax: newMax)
        self.maxNumber = newMax
        self.lastDrawnNumber = nil
        self.remainingCount = await pool.getRemainingCount()
        self.isPoolEmpty = false
    }
    
    /// 重置數字池 (保留當前最大值)
    public func resetPool() async {
        await pool.reset()
        self.lastDrawnNumber = nil
        self.remainingCount = await pool.getRemainingCount()
        self.isPoolEmpty = false
    }
}
