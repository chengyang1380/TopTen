import SwiftUI
import SwiftData

@main
struct TopTenApp: App {
    let container: ModelContainer?
    @State private var databaseError: String?
    
    init() {
        do {
            let schema = Schema([QuestionModel.self])
            let config = ModelConfiguration(schema: schema)
            let newContainer = try ModelContainer(for: schema, configurations: [config])
            self.container = newContainer
            
            Task { @MainActor in
                let service = QuestionService(container: newContainer)
                let builtInQuestions = QuestionDataLoader.loadBuiltInQuestions()
                try? await service.seedInitialQuestions(from: builtInQuestions)
            }
        } catch {
            self.container = nil
            // 在 init 中使用區域變數紀錄錯誤，稍後在 View 出現時處理
            print("資料庫初始化失敗: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    if container == nil {
                        databaseError = "無法存取本地資料庫，題庫功能將受限。"
                    }
                }
                .alert("資料庫錯誤", isPresented: Binding(
                    get: { databaseError != nil },
                    set: { if !$0 { databaseError = nil } }
                )) {
                    Button("好的", role: .cancel) {}
                } message: {
                    Text(databaseError ?? "")
                }
        }
        // 若 container 為 nil，則不套用 modelContainer 以防崩潰
        // 這種情況下，依賴 modelContext 的 View 會顯示空內容或手動攔截
        .modelContainer(container ?? .fallback)
    }
}

extension ModelContainer {
    /// 提供一個安全的備援 Container (InMemory)，防止 App 崩潰
    @MainActor
    static var fallback: ModelContainer {
        let schema = Schema([QuestionModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }
}
