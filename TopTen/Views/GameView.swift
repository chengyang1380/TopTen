import SwiftUI
import SwiftData

struct GameView: View {
    @State private var viewModel: GameViewModel
    @Environment(\.modelContext) private var modelContext
    
    init(category: String) {
        _viewModel = State(initialValue: GameViewModel(category: category))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. 頂部隨機題目展示區
                QuestionHeroSection(question: viewModel.currentQuestion)
                    .padding()
                
                // 2. 操作列
                HStack(spacing: 15) {
                    Button {
                        viewModel.pickRandomQuestion()
                    } label: {
                        Label("隨機出題", systemImage: "dice.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        viewModel.openAddSheet()
                    } label: {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.teal.opacity(0.1))
                            .foregroundColor(.teal)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // 3. 題目清單
                List {
                    Section("所有題目 (\(viewModel.filteredQuestions.count))") {
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
            }
            .navigationTitle(viewModel.category)
            .onAppear {
                // 注入 Service
                let service = QuestionService(container: modelContext.container)
                viewModel.setup(service: service)
                
                Task {
                    await viewModel.loadQuestions()
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddSheet) {
                AddQuestionView(category: viewModel.category) {
                    Task { await viewModel.loadQuestions() }
                }
            }
        }
    }
}

/// 頂部英雄區
struct QuestionHeroSection: View {
    let question: QuestionModel?
    
    var body: some View {
        VStack(spacing: 15) {
            if let question = question {
                VStack(spacing: 20) {
                    Text(question.content)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("1")
                                .font(.caption.bold())
                                .foregroundColor(.teal)
                            Text(question.scaleLow)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("10")
                                .font(.caption.bold())
                                .foregroundColor(.teal)
                            Text(question.scaleHigh)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(25)
                .frame(maxWidth: .infinity, minHeight: 180)
                .background(Color.teal.opacity(0.05))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                )
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundColor(.teal.opacity(0.5))
                    Text("點擊下方按鈕開始出題")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(20)
            }
        }
    }
}

/// 列表列組件
struct QuestionRow: View {
    let question: QuestionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(question.content)
                    .font(.body.bold())
                Spacer()
                if question.isBuiltIn {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            
            HStack {
                Text("1: \(question.scaleLow)")
                Spacer()
                Text("10: \(question.scaleHigh)")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
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
                    TextField("1 代表的意義 (例如：最不可能)", text: $low)
                    TextField("10 代表的意義 (例如：非常可能)", text: $high)
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
