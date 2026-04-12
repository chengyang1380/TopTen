import SwiftUI
import SwiftData

struct GameView: View {
    @State private var viewModel: GameViewModel
    @Environment(\.modelContext) private var modelContext
    
    private var localizedTitle: String {
        switch viewModel.category {
        case "Basic": return "基本版"
        case "Adventure": return "大冒險"
        case "NSFW": return "沒有下限"
        default: return viewModel.category
        }
    }
    
    init(category: String) {
        _viewModel = State(initialValue: GameViewModel(category: category))
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("所有題目 (\(viewModel.allQuestions.count))") {
                    ForEach(viewModel.filteredQuestions) { question in
                        QuestionRow(question: question)
                    }
                    .onDelete { offsets in
                        Task { await viewModel.deleteQuestion(at: offsets) }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $viewModel.searchText, prompt: "搜尋題目...")
            .navigationTitle(localizedTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 15) {
                        Button {
                            viewModel.pickRandomQuestion()
                        } label: {
                            Image(systemName: "dice.fill")
                        }
                        
                        Button {
                            viewModel.openAddSheet()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .alert(
                "隨機出題",
                isPresented: $viewModel.isShowingQuestionDialog,
                presenting: viewModel.currentQuestion
            ) { question in
                Button("收到！", role: .cancel) {}
            } message: { question in
                Text("\(question.content)\n\n1: \(question.scaleLow)\n10: \(question.scaleHigh)")
            }
            .onAppear {
                let service = QuestionService(container: modelContext.container)
                viewModel.setup(service: service)
                Task { await viewModel.loadQuestions() }
            }
            .sheet(isPresented: $viewModel.isShowingAddSheet) {
                AddQuestionView(category: viewModel.category) {
                    Task { await viewModel.loadQuestions() }
                }
            }
        }
    }
}

/// 列表列組件
struct QuestionRow: View {
    let question: QuestionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(question.content)
                    .font(.subheadline.bold())
                Spacer()
                if question.isBuiltIn {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.4))
                }
            }
            
            HStack {
                Text("1: \(question.scaleLow)")
                Spacer()
                Text("10: \(question.scaleHigh)")
            }
            .font(.system(size: 10))
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

/// 新增題目視圖
struct AddQuestionView: View {
    let category: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var content = ""
    @State private var low = ""
    @State private var high = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("題目內容") {
                    TextField("請輸入題目...", text: $content, axis: .vertical)
                        .lineLimit(3...5)
                }
                Section("量表描述") {
                    TextField("1 代表的意義", text: $low)
                    TextField("10 代表的意義", text: $high)
                }
            }
            .navigationTitle("新增題目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        save()
                    }
                    .disabled(content.isEmpty || low.isEmpty || high.isEmpty)
                }
            }
        }
    }
    
    private func save() {
        let newQuestion = QuestionModel(
            content: content,
            scaleLow: low,
            scaleHigh: high,
            category: category
        )
        modelContext.insert(newQuestion)
        onSave()
        dismiss()
    }
}
