//
//  ThemeSwitcherBar.swift
//  Ambient
//
//  Created by 徐暄 on 2025/5/20.
//



import SwiftUI

private struct ThemePositionKey: PreferenceKey {
    static var defaultValue: [MusicTheme: CGFloat] = [:]
    static func reduce(value: inout [MusicTheme : CGFloat], nextValue: () -> [MusicTheme : CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

enum MusicTheme: String, CaseIterable, Identifiable {
    case ambient, modern, neo

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ambient: return "Ambient"
        case .modern: return "Modern"
        case .neo: return "Neo"
        }
    }
}

struct ThemeSwitcherBar: View {
    @Binding var selected: MusicTheme
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let midX = geo.size.width / 2

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 48) {
                    ForEach(MusicTheme.allCases) { theme in
                        GeometryReader { itemGeo in
                            let itemMidX = itemGeo.frame(in: .named("ThemeScroll")).midX
                            let distance = abs(itemMidX - midX)
                            let scale = max(0.9, 1.2 - distance / 300)
                            let opacity = max(0.4, 1.0 - distance / 300)

                            Text(theme.label)
                                .font(.custom("Michroma-Regular", size: 24))
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .foregroundColor(selected == theme ? .primary : .primary.opacity(0.4))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(minWidth: 120, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selected = theme
                                }
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear.preference(key: ThemePositionKey.self, value: [theme: proxy.frame(in: .named("ThemeScroll")).midX])
                                    }
                                )
                        }
                        .frame(minWidth: 120, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                    }
                }
                .padding(.horizontal, (geo.size.width - 120) / 2)
            }
            .coordinateSpace(name: "ThemeScroll")
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let direction = value.translation.width
                        guard let index = MusicTheme.allCases.firstIndex(of: selected) else { return }

                        if direction < -30, index < MusicTheme.allCases.count - 1 {
                            selected = MusicTheme.allCases[index + 1]
                        } else if direction > 30, index > 0 {
                            selected = MusicTheme.allCases[index - 1]
                        }
                    }
            )
            .onPreferenceChange(ThemePositionKey.self) { positions in
                let midX = geo.size.width / 2
                if let closest = positions.min(by: { abs($0.value - midX) < abs($1.value - midX) })?.key {
                    selected = closest
                }
            }
        }
        .frame(height: 100)
    }
}
