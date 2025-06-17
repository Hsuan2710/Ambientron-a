//  VolumeSidebar.swift
//  Ambient
//
//  Global master gain control: –12 dB … +12 dB
//

import SwiftUI
import AVFoundation

// MARK: - PreferenceKey for tracking row positions
private struct GainPositionKey: PreferenceKey {
    static var defaultValue: [Double: CGFloat] = [:]
    static func reduce(value: inout [Double : CGFloat], nextValue: () -> [Double : CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - VolumeSidebar
struct VolumeSidebar: View {
    @ObservedObject private var audioEngine = AudioEngine.shared
    private let steps = stride(from: -12.0, through: 12.0, by: 1).map { $0 }

    @Environment(\.themeStyle) private var themeStyle
    @State private var didScrollInitially = false

    var body: some View {
        ZStack {
            if let imageName = themeStyle.volumeSidebarImageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
            GeometryReader { geo in
                let midY = geo.size.height / 2
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 18) {
                            Spacer(minLength: midY) // Top padding
                            ForEach(steps, id: \.self) { db in
                                GainRow(db: db, selected: audioEngine.masterGainDB)
                                    .background(
                                        GeometryReader { r in
                                            Color.clear.preference(key: GainPositionKey.self,
                                                                   value: [db: round(r.frame(in: .named("GainScroll")).midY)])
                                        }
                                    )
                                    .id(db)
                            }
                            Spacer(minLength: midY) // Bottom padding
                        }
                        .padding(.vertical, midY)
                        .gesture(DragGesture()
                                    .onChanged { value in
                                        let delta = -value.translation.height / 40  // pixels→dB scale
                                        let tentative = (audioEngine.masterGainDB + Double(delta)).rounded()
                                        let clamped = min(max(tentative, -12), 12)
                                        if clamped != audioEngine.masterGainDB { updateGain(to: clamped) }
                                    })
                    }
                    .coordinateSpace(name: "GainScroll")
                    .onPreferenceChange(GainPositionKey.self) { pos in
                        // snap to the row closest to center
                        if let nearest = pos.min(by: { abs($0.value - midY) < abs($1.value - midY) })?.key,
                           nearest != audioEngine.masterGainDB {
                            updateGain(to: nearest)
                        #if canImport(AppKit)
                        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                        #endif
                        }
                    }
                    
                    .onChange(of: audioEngine.masterGainDB) { new in
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(new, anchor: .center)
                        }
                    }
                    .onAppear {
                        if !didScrollInitially {
                            didScrollInitially = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo(audioEngine.masterGainDB, anchor: .center)
                            }
                        }
                    }
                    .overlay(
                        Rectangle()
                            .fill(Color.red)
                            .frame(height: 4)
                            .frame(maxHeight: .infinity, alignment: .center)
                    )
                    .focusable()
                    .onMoveCommand { cmd in
                        switch cmd {
                        case .down, .right:
                            if audioEngine.masterGainDB < 12 { updateGain(to: audioEngine.masterGainDB + 1) }
                        case .up, .left:
                            if audioEngine.masterGainDB > -12 { updateGain(to: audioEngine.masterGainDB - 1) }
                        default: break
                        }
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(audioEngine.masterGainDB, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 160)
        .background(Color.clear)
    }
    
    private func updateGain(to newValue: Double) {
        audioEngine.masterGainDB = newValue
    }
}

// MARK: - GainRow
private struct GainRow: View {
    let db: Double
    let selected: Double
    
    var body: some View {
        Group {
            if db == selected {
                Text("\(Int(db)) dB")
                    .font(.custom("Michroma-Regular", size: 28 ))
                    .foregroundColor(.black)
            } else if abs(db - selected) == 1 {
                Text("\(Int(db))")
                    .font(.custom("Michroma-Regular", size: 18 ))
                    .foregroundColor(Color.black.opacity(0.8))
            } else {
                Capsule()
                    .frame(width: 4, height: 10)
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - AudioEngine singleton
final class AudioEngine: ObservableObject {
    static let shared = AudioEngine()
    let engine = AVAudioEngine()
    let environmentNode = AVAudioEnvironmentNode()
    
    var activePlayers: [AVAudioPlayerNode] = []
    
    @Published var masterGainDB: Double = 0.0 {
        didSet {
            updateVolume()
        }
    }
    
    private func updateVolume() {
        let linear = pow(10, masterGainDB / 20)
        environmentNode.outputVolume = Float(linear)

        // Update all active player volumes
        for player in activePlayers {
            player.volume = Float(linear)
        }
    }
    
    private init() {
        engine.attach(environmentNode)
        engine.connect(environmentNode, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }
}
