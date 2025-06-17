//
//  ThemeStyle.swift
//  Ambient
//
//  Created by 徐暄 on 2025/5/20.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }
}

struct SidebarShadowStyle {
    let topColor: Color
    let topRadius: CGFloat
    let topOffsetY: CGFloat
    let bottomColor: Color
    let bottomRadius: CGFloat
    let bottomOffsetY: CGFloat
}

struct ThemeStyle {
    let background: Color
    let padBackground: Color
    let padShadow: Color
    let sidebarBackground: Color
    let textColor: Color
    let font: Font
    let accentColor: Color
    let padCornerRadius: CGFloat
    let shadowRadius: CGFloat
    let highlightColor: Color
    let inactiveOpacity: Double
    let padGradient: LinearGradient
    let padStrokeColor: Color
    let padInnerShadow: Bool
    let sidebarShadowStyle: SidebarShadowStyle
    let tempoSidebarImageName: String?
    let volumeSidebarImageName: String?
}

extension SidebarShadowStyle {
    func overlays() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .stroke(self.topColor, lineWidth: 2)
                .blur(radius: self.topRadius)
                .offset(x: 0, y: self.topOffsetY)
                .mask(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black, Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )

            RoundedRectangle(cornerRadius: 0)
                .stroke(self.bottomColor, lineWidth: 1)
                .blur(radius: self.bottomRadius)
                .offset(x: 0, y: self.bottomOffsetY)
                .mask(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.white]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        }
    }
}

extension ThemeStyle {
    static let ambient = ThemeStyle(
        background: Color(hex: "#C9CBC8"),
        padBackground: Color(red: 0.88, green: 0.89, blue: 0.85),
        padShadow: Color.black.opacity(0.35),
        sidebarBackground: Color(hex: "#D9DDD8"),
        textColor: .black,
        font: .custom("Michroma-Regular", size: 18),
        accentColor: .red,
        padCornerRadius: 10,
        shadowRadius: 10,
        highlightColor: .red,
        inactiveOpacity: 0.5,
        padGradient: LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.85),
                Color(red: 0.88, green: 0.89, blue: 0.85)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        padStrokeColor: Color.black.opacity(0.4),
        padInnerShadow: true,
        sidebarShadowStyle: SidebarShadowStyle(
            topColor: Color.black.opacity(0.25),
            topRadius: 14,
            topOffsetY: -5,
            bottomColor: Color.white.opacity(0.25),
            bottomRadius: 10,
            bottomOffsetY: 5
        ),
        tempoSidebarImageName: "sidebar_ambient_1",
        volumeSidebarImageName: "sidebar_ambient_2"
    )

    static let modern = ThemeStyle(
        background: Color(nsColor: .windowBackgroundColor),
        padBackground: Color.gray.opacity(0.15),
        padShadow: Color.black.opacity(0.1),
        sidebarBackground: Color(nsColor: .controlBackgroundColor),
        textColor: .primary,
        font: .system(size: 18, weight: .medium, design: .rounded),
        accentColor: .blue,
        padCornerRadius: 12,
        shadowRadius: 6,
        highlightColor: .blue,
        inactiveOpacity: 0.4,
        padGradient: LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.15)]),
            startPoint: .top,
            endPoint: .bottom
        ),
        padStrokeColor: .clear,
        padInnerShadow: false,
        sidebarShadowStyle: SidebarShadowStyle(
            topColor: .clear,
            topRadius: 0,
            topOffsetY: 0,
            bottomColor: .clear,
            bottomRadius: 0,
            bottomOffsetY: 0
        ),
        tempoSidebarImageName: nil,
        volumeSidebarImageName: nil
    )

    static let neo = ThemeStyle(
        background: Color(red: 0.95, green: 0.95, blue: 1.0),
        padBackground: Color.white,
        padShadow: Color.gray.opacity(0.3),
        sidebarBackground: Color(red: 0.92, green: 0.92, blue: 0.98),
        textColor: .primary,
        font: .system(size: 18, weight: .medium, design: .default),
        accentColor: .purple,
        padCornerRadius: 14,
        shadowRadius: 7,
        highlightColor: .purple,
        inactiveOpacity: 0.45,
        padGradient: LinearGradient(
            gradient: Gradient(colors: [Color.white, Color.white]),
            startPoint: .top,
            endPoint: .bottom
        ),
        padStrokeColor: .clear,
        padInnerShadow: false,
        sidebarShadowStyle: SidebarShadowStyle(
            topColor: .clear,
            topRadius: 0,
            topOffsetY: 0,
            bottomColor: .clear,
            bottomRadius: 0,
            bottomOffsetY: 0
        ),
        tempoSidebarImageName: nil,
        volumeSidebarImageName: nil
    )
}

extension MusicTheme {
    var style: ThemeStyle {
        switch self {
        case .ambient: return .ambient
        case .modern: return .modern
        case .neo: return .neo
        }
    }
}
