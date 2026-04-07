import SwiftUI

struct NumberDrawingView: View {
    @State private var viewModel = NumberDrawingViewModel()
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // 頂部小工具
                    HStack {
                        Text("\(viewModel.playerCount) 人局")
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            haptic.impactOccurred()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                viewModel.openSettings()
                            }
                        } label: {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.teal)
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 25) {
                            ForEach(viewModel.cards) { card in
                                PlayerCardView(card: card) {
                                    handleCardTap(card: card)
                                }
                            }
                        }
                        .padding(25)
                    }
                    
                    // 底部動作區
                    VStack(spacing: 12) {
                        Button {
                            haptic.impactOccurred()
                            viewModel.requestReset()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                Text("重新洗牌")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
                .navigationTitle("發牌")
                .alert("確定要重新洗牌嗎？", isPresented: $viewModel.isShowingResetAlert) {
                    Button("確定重置", role: .destructive) {
                        Task { await viewModel.reshuffle() }
                    }
                    Button("取消", role: .cancel) {}
                } message: {
                    Text("這將會打亂所有數字並重新發放。")
                }
                
                // 1. 初始設定 Overlay
                if viewModel.isSetupRequired {
                    SetupOverlay(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 1.1))
                        ))
                        .zIndex(2)
                }
                
                // 2. 翻牌確認 Overlay
                if let card = viewModel.cardToToggle {
                    RevealOverlay(viewModel: viewModel, card: card)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 1.1))
                        ))
                        .zIndex(3)
                }
            }
        }
    }
    
    private func handleCardTap(card: PlayerCard) {
        haptic.impactOccurred(intensity: 0.6)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            viewModel.requestReveal(for: card)
        }
    }
}

/// 揭曉確認對話框 (優化動畫與視覺)
struct RevealOverlay: View {
    let viewModel: NumberDrawingViewModel
    let card: PlayerCard
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                VStack(spacing: 12) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.teal)
                    
                    Text("揭曉數字？")
                        .font(.title3.bold())
                    
                    Text("確定要翻開 **玩家 \(card.playerIndex)** 的數字嗎？\n請確保只有您本人在看螢幕。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            viewModel.confirmReveal(for: card.id)
                        }
                    } label: {
                        Text("確定揭曉")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            viewModel.cardToToggle = nil
                        }
                    } label: {
                        Text("取消")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .padding(30)
            .background(Color(.systemBackground))
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.15), radius: 20)
            .padding(40)
        }
    }
}

/// 初始設定對話框
struct SetupOverlay: View {
    @Bindable var viewModel: NumberDrawingViewModel
    @State private var tempPlayerCount: Int = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .blur(radius: 10)
            
            VStack(spacing: 25) {
                Text("本局共有幾位玩家？")
                    .font(.title2.bold())
                
                HStack(spacing: 20) {
                    Button {
                        if tempPlayerCount > 2 { tempPlayerCount -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.teal)
                    }
                    
                    Text("\(tempPlayerCount)")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .frame(minWidth: 80)
                    
                    Button {
                        if tempPlayerCount < 20 { tempPlayerCount += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.teal)
                    }
                }
                
                VStack(spacing: 12) {
                    Button {
                        viewModel.playerCount = tempPlayerCount
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            Task { await viewModel.confirmSetup() }
                        }
                    } label: {
                        Text("開始發牌")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    if !viewModel.cards.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                viewModel.cancelSetup()
                            }
                        } label: {
                            Text("返回遊戲")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
            }
            .padding(30)
            .background(Color(.systemBackground))
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.15), radius: 20)
            .padding(40)
        }
        .onAppear {
            tempPlayerCount = viewModel.playerCount
        }
    }
}

/// 玩家卡片組件 (修正鏡像問題)
struct PlayerCardView: View {
    let card: PlayerCard
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // 牌背
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(
                        colors: [.teal, .teal.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        Image(systemName: "eye.slash.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.6))
                    )
                
                // 牌面
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .overlay(
                        Text("\(card.number)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.teal)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    )
                    .opacity(card.isRevealed ? 1 : 0)
            }
            .frame(height: 140)
            .rotation3DEffect(
                .degrees(card.isRevealed ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .onTapGesture {
                onTap()
            }
            
            Text("玩家 \(card.playerIndex)")
                .font(.caption.bold())
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NumberDrawingView()
}
