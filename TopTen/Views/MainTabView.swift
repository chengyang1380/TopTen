import SwiftUI

struct MainTabView: View {
    @State private var viewModel = MainTabViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(viewModel.tabs) { tab in
                Group {
                    if tab.type == .numberDrawing {
                        NumberDrawingView()
                    } else {
                        TabContentView(tab: tab)
                    }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.iconName)
                }
                .tag(Optional(tab))
            }
        }
        .tint(.teal)
    }
}

struct TabContentView: View {
    let tab: TabItem
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 80))
                    .foregroundStyle(.teal)
                
                Text(tab.title)
                    .font(.largeTitle.bold())
                
                Text("功能開發中...")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle(tab.title)
        }
    }
}

#Preview {
    MainTabView()
}
