import Testing
@testable import TopTen
import Foundation

@Suite("主分頁測試")
@MainActor
struct MainTabViewModelTests {
    
    @Test("驗證初始化時具備 4 個正確的分頁")
    func test_tabInitialization_hasFourTabs() async throws {
        // Given
        let viewModel = MainTabViewModel()
        
        // Then
        #expect(viewModel.tabs.count == 4)
        #expect(viewModel.tabs[0].title == "基本版")
        #expect(viewModel.tabs[1].title == "大冒險")
        #expect(viewModel.tabs[2].title == "沒有下限")
        #expect(viewModel.tabs[3].title == "抽數字")
    }
    
    @Test("驗證預設選中的分頁是第一個")
    func test_initialSelection_isFirstTab() async throws {
        // Given
        let viewModel = MainTabViewModel()
        
        // Then
        #expect(viewModel.selectedTab == viewModel.tabs.first)
    }
}
