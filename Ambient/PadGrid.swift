// //  PadGrid.swift //  Ambient
//
//  Created by 徐暄 on 2025/5/18.
//

// PadGrid.swift
import SwiftUI
import AVFoundation

struct PadGrid: View {
    @Binding var mutes: Set<Int>
    @Environment(\.themeStyle) private var themeStyle
    @StateObject private var audioManager = PadAudioManager()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 40), count: 4)
    private let padLabels = ["A1", "A2", "B1", "B2", "C1", "C2", "D1", "D2"]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 40) {
            ForEach(0..<8, id: \.self) { index in
                ZStack {
                    if themeStyle.padInnerShadow {
                        Image(mutes.contains(index) ? "button_ambient_press" : "button_ambient")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: themeStyle.padCornerRadius))
                    } else {
                        RoundedRectangle(cornerRadius: themeStyle.padCornerRadius)
                            .fill(themeStyle.padBackground)
                            .shadow(color: themeStyle.padShadow, radius: themeStyle.shadowRadius, y: 4)
                    }

                    if mutes.contains(index) {
                        TriangleWaveAnimation()
                    }
                }
                .frame(width: 180, height: 180)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        let label = padLabels[index]
                        audioManager.toggleLoop(for: label)
                        if mutes.contains(index) {
                            mutes.remove(index)
                        } else {
                            mutes.insert(index)
                        }
                    }
                }
            }
        }
        .onAppear {
            let index = 7
            let label = padLabels[index]
            if !mutes.contains(index) {
                audioManager.toggleLoop(for: label)
                mutes.insert(index)
            }
        }
    }
}

struct TriangleWaveAnimation: View {
    @State private var offsets: [CGSize] = Array(repeating: .zero, count: 6)

    var body: some View {
        ZStack {
            ForEach(0..<offsets.count, id: \.self) { i in
                TriangleShape()
                    .stroke(Color.black, lineWidth: 1.5)
                    .background(
                        TriangleShape()
                            .fill(Color.purple.opacity(0.05 + 0.05 * Double(i)))
                    )
                    .frame(width: 60, height: 60)
                    .offset(y: offsets[i].height)
                    .rotationEffect(.degrees(Double(i) * 4))
                    .blendMode(.plusLighter)
                    .animation(Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.1), value: offsets[i])
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                for i in offsets.indices {
                    offsets[i] = CGSize(width: 0, height: CGFloat.random(in: -10...10))
                }
            }
        }
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
