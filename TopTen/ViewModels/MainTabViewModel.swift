import Foundation
import Observation

public enum TabType: CaseIterable, Sendable {
    case basic, adventure, nsfw, numberDrawing
}

public struct TabItem: Identifiable, Equatable, Hashable, Sendable {
    public let id = UUID()
    public let type: TabType
    public let title: String
    public let iconName: String
    
    public init(type: TabType, title: String, iconName: String) {
        self.type = type
        self.title = title
        self.iconName = iconName
    }
}

@Observable
@MainActor
public final class MainTabViewModel {
    public private(set) var tabs: [TabItem] = []
    public var selectedTab: TabItem?
    
    public init() {
        self.tabs = [
            TabItem(type: .basic, title: "基本版", iconName: "star.fill"),
            TabItem(type: .adventure, title: "大冒險", iconName: "bolt.fill"),
            TabItem(type: .nsfw, title: "沒有下限", iconName: "flame.fill"),
            TabItem(type: .numberDrawing, title: "抽數字", iconName: "number.square.fill")
        ]
        self.selectedTab = self.tabs.first
    }
}
