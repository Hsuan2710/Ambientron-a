//
//  MainWindow.swift
//  Ambient
//
//  Created by 徐暄 on 2025/5/18.
//
// MainWindow.swift
import SwiftUI

private struct ThemeStyleKey: EnvironmentKey {
    static let defaultValue = ThemeStyle.modern
}

extension EnvironmentValues {
    var themeStyle: ThemeStyle {
        get { self[ThemeStyleKey.self] }
        set { self[ThemeStyleKey.self] = newValue }
    }
}

@main
struct Ambient: App {
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .frame(minWidth: 900, minHeight: 500)
        }
        // 如需多視窗可改用 WindowGroup(id:)
    }
}

struct MainWindow: View {
    @StateObject private var audioManager = PadAudioManager()
    @State private var selectedTempo: Int = 60      // 預設 60 BPM
    @State private var mutes: Set<Int> = []         // 被靜音的 pad 編號
    @State private var masterGain: Double = 0      // -12 dB ... +12 dB
    @State private var selectedTheme: MusicTheme = .modern
    
    var themeStyle: ThemeStyle {
        selectedTheme.style
    }
    
    var body: some View {
        VStack {
            ThemeSwitcherBar(selected: $selectedTheme)
                .padding(.top, 16)
            HStack(spacing: 0) {
                // 左側 Tempo 選單
                TempoSidebar(selected: $selectedTempo, tempoBPM: $audioManager.tempoBPM)
                    .onChange(of: selectedTempo) { newTempo in
                        audioManager.tempoBPM = Double(newTempo)
                    }
                    .frame(width: 170)
                    .background(themeStyle.sidebarBackground)
                
                // 右側 2×4 Pad
                PadGrid(mutes: $mutes)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 60)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 右側 Volume Bar
                VolumeSidebar()
                    .frame(width: 170)
                    .background(themeStyle.sidebarBackground)
            }
        }
        .environmentObject(audioManager)
        .environment(\.themeStyle, themeStyle)
        .background(themeStyle.background.ignoresSafeArea())
    }
}

#Preview {
    MainWindow()
        .frame(width: 900, height: 500)
}
