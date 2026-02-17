//
//  LevelGridView.swift
//  MatjesSchule
//
//  Level-Raster mit Sterne-Anzeige
//

import SwiftUI

struct LevelGridView: View {
    @EnvironmentObject var progressManager: ProgressManager

    let halbjahr: Int // 0 = alle
    let levelRange: ClosedRange<Int>
    let allQuestions: [Question]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var availableLevels: Set<Int> {
        QuestionLoader.availableLevels(in: allQuestions)
    }

    private var headerTitle: String {
        switch halbjahr {
        case 1: return "1. Halbjahr"
        case 2: return "2. Halbjahr"
        case 3: return "3. Halbjahr"
        case 4: return "4. Halbjahr"
        case 5: return "5. Halbjahr"
        case 6: return "6. Halbjahr"
        default: return "Alle Level"
        }
    }

    private var headerSubtitle: String {
        switch halbjahr {
        case 1: return "Grundlagen"
        case 2: return "Warenkunde"
        case 3: return "Vertiefung"
        case 4: return "Anwenden & Bewerten"
        case 5: return "Pr\u{00FC}fungsvorbereitung"
        case 6: return "Meisterklasse"
        default: return "Level 1-20"
        }
    }

    private var totalStars: Int {
        levelRange.reduce(0) { sum, level in
            let stars = progressManager.starsForLevel(level)
            return sum + max(0, stars)
        }
    }

    private var maxStars: Int {
        levelRange.count * 3
    }

    private var progressFraction: CGFloat {
        guard maxStars > 0 else { return 0 }
        return CGFloat(totalStars) / CGFloat(maxStars)
    }

    /// Das nächste spielbare Level (freigeschaltet, aber noch nicht mit 3 Sternen)
    private var nextPlayableLevel: Int? {
        for level in levelRange {
            let isUnlocked = progressManager.isLevelUnlocked(level, in: levelRange)
            let stars = progressManager.starsForLevel(level)
            if isUnlocked && stars < 3 && availableLevels.contains(level) {
                return level
            }
        }
        return nil
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color.blue.opacity(0.4), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Fortschritts-Header
                    VStack(spacing: 8) {
                        Text(headerTitle)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text(headerSubtitle)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)

                        // Gesamt-Fortschritt
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("\(totalStars) / \(maxStars)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                        }
                        .padding(.top, 4)

                        // Fortschrittsbalken
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 6)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(0, geo.size.width * progressFraction), height: 6)
                                    .shadow(color: .orange.opacity(0.4), radius: 3, y: 0)
                                    .animation(.easeInOut(duration: 0.5), value: progressFraction)
                            }
                        }
                        .frame(height: 6)
                        .padding(.horizontal, 40)
                        .padding(.top, 4)
                    }
                    .padding(.top, 20)

                    // Level Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(levelRange), id: \.self) { level in
                            let hasQuestions = availableLevels.contains(level)
                            let isUnlocked = progressManager.isLevelUnlocked(level, in: levelRange)
                            let stars = progressManager.starsForLevel(level)
                            let isNext = level == nextPlayableLevel

                            if hasQuestions && isUnlocked {
                                NavigationLink(destination:
                                    LevelGameView(
                                        level: level,
                                        allQuestions: allQuestions
                                    )
                                ) {
                                    LevelCell(
                                        level: level,
                                        stars: stars,
                                        state: .unlocked,
                                        isCheckpoint: level % 10 == 0,
                                        isNextLevel: isNext
                                    )
                                }
                            } else {
                                LevelCell(
                                    level: level,
                                    stars: stars,
                                    state: hasQuestions ? .locked : .comingSoon,
                                    isCheckpoint: level % 10 == 0,
                                    isNextLevel: false
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Level Cell
struct LevelCell: View {
    let level: Int
    let stars: Int // -1 = unplayed
    let state: CellState
    let isCheckpoint: Bool
    let isNextLevel: Bool

    @State private var pulse = false

    enum CellState {
        case unlocked
        case locked
        case comingSoon
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(cellBackground)
                    .frame(width: 90, height: 90)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: isCheckpoint ? 2 : 1)
                    )
                    .shadow(color: glowColor, radius: glowRadius)
                    .scaleEffect(isNextLevel && pulse ? 1.06 : 1.0)

                VStack(spacing: 4) {
                    if state == .locked || state == .comingSoon {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                    } else {
                        Text("\(level)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }

            // Sterne-Anzeige
            if state == .unlocked {
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { starIndex in
                        Image(systemName: starIndex < max(0, stars) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(starIndex < max(0, stars) ? .yellow : .gray.opacity(0.4))
                    }
                }
            } else if state == .comingSoon {
                Text("Bald")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
            } else {
                // Locked - empty space for alignment
                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "star")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.2))
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .onAppear {
            if isNextLevel {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
    }

    private var accessibilityDescription: String {
        switch state {
        case .unlocked:
            let starText = max(0, stars)
            return "Level \(level), \(starText) von 3 Sternen\(isNextLevel ? ", nächstes Level" : "")"
        case .locked:
            return "Level \(level), gesperrt"
        case .comingSoon:
            return "Level \(level), demnächst verfügbar"
        }
    }

    private var cellBackground: Color {
        switch state {
        case .unlocked:
            if stars >= 3 { return Color.yellow.opacity(0.15) }
            if stars >= 1 { return Color.blue.opacity(0.3) }
            return Color.white.opacity(0.1)
        case .locked: return Color.gray.opacity(0.1)
        case .comingSoon: return Color.gray.opacity(0.05)
        }
    }

    private var borderColor: Color {
        switch state {
        case .unlocked:
            if isCheckpoint { return Color.orange }
            if isNextLevel { return Color.orange.opacity(0.7) }
            if stars >= 3 { return Color.yellow.opacity(0.5) }
            return Color.white.opacity(0.2)
        case .locked: return Color.gray.opacity(0.2)
        case .comingSoon: return Color.gray.opacity(0.1)
        }
    }

    private var glowColor: Color {
        if state == .unlocked && isNextLevel { return Color.orange.opacity(0.4) }
        if state == .unlocked && isCheckpoint { return Color.orange.opacity(0.3) }
        if state == .unlocked && stars >= 3 { return Color.yellow.opacity(0.2) }
        return Color.clear
    }

    private var glowRadius: CGFloat {
        if state == .unlocked && isNextLevel { return 8 }
        if state == .unlocked && (isCheckpoint || stars >= 3) { return 6 }
        return 0
    }
}
