//
//  TempoSidebar.swift
//  Ambient
//
//  Updated to support continuous track‑pad scrolling with a fixed
//  centre indicator and automatic selection.
//

import SwiftUI

import AVFoundation

#if canImport(AppKit)
import AppKit   // haptic feedback
#endif

private struct BPMPositionKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int : CGFloat], nextValue: () -> [Int : CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct TempoSidebar: View {
    @Environment(\.themeStyle) private var themeStyle
    @Binding var selected: Int
    @Binding var tempoBPM: Double
    private let tempos: [Int] = Array(30...200)
    
    var body: some View {
        ZStack {
            if let imageName = themeStyle.tempoSidebarImageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else if themeStyle.padInnerShadow {
                themeStyle.sidebarShadowStyle.overlays()
            }

            GeometryReader { geo in
                let midY = geo.size.height / 2

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(tempos, id: \.self) { bpm in
                                BPMRow(bpm: bpm, selected: selected)
                                    .background(
                                        GeometryReader { rowGeo in
                                            Color.clear
                                                .preference(key: BPMPositionKey.self,
                                                            value: [bpm: rowGeo.frame(in: .named("TempoScroll")).midY])
                                        }
                                    )
                                    .id(bpm)
                            }
                            Spacer(minLength: midY)
                            Spacer(minLength: midY)
                        }
                        .padding(.trailing, 24)
                        .padding(.vertical, midY)
                    }
                    .coordinateSpace(name: "TempoScroll")
                    .onPreferenceChange(BPMPositionKey.self) { positions in
                        if let closest = positions.min(by: { abs(round($0.value) - midY) < abs(round($1.value) - midY) })?.key,
                           closest != selected {
                            selected = closest
                            tempoBPM = Double(closest)
                            #if canImport(AppKit)
                            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                            #endif
                        }
                    }
                    .onChange(of: selected) { newValue in
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(selected, anchor: .center)
                    }
                    .overlay(
                        Rectangle()
                            .fill(Color.red)
                            .frame(height: 4)
                            .frame(maxHeight: .infinity, alignment: .center)
                    )
                    .onMoveCommand { cmd in
                        switch cmd {
                        case .down, .right:
                            if selected < 200 { selected += 1 }
                        case .up, .left:
                            if selected > 30 { selected -= 1 }
                        default:
                            break
                        }
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(selected, anchor: .center)
                        }
                    }
                    .focusable()
                }
            }
        }
    }
}

private struct BPMRow: View {
    @Environment(\.themeStyle) private var themeStyle
    let bpm: Int
    let selected: Int
    
    var body: some View {
        Group {
            if bpm == selected {
                // highlighted centre value
                Text("\(bpm)")
                    .font(.custom("Michroma-Regular", size: 42, ))
                    .foregroundColor(themeStyle.textColor)
            } else if abs(bpm - selected) == 10 {
                // immediate neighbours
                Text("\(bpm)")
                    .font(.custom("Michroma-Regular", size: 26, ))
                    .foregroundColor(themeStyle.textColor.opacity(0.8))
            } else {
                // distant values collapse to dots
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(themeStyle.textColor.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
