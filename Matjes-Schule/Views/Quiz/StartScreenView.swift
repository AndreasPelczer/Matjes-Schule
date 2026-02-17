//
//  StartScreenView.swift
//  MatjesSchule
//
//  Halbjahr-Auswahl mit Prüfungen
//

import SwiftUI

struct StartScreenView: View {
    @EnvironmentObject var progressManager: ProgressManager

    let allQuestions = QuestionLoader.loadFromJSON()

    @State private var flameGlow = false
    @State private var headerVisible = false
    @State private var contentVisible = false
    @State private var cursorVisible = true
    @State private var showComingSoonAlert = false

    /// Halbjahr-Konfiguration mit Level-Ranges
    private struct HalbjahrConfig {
        let number: Int
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
        let levelRange: ClosedRange<Int>
        let unlockHint: String
        let isComingSoon: Bool

        init(number: Int, title: String, subtitle: String, icon: String, color: Color, levelRange: ClosedRange<Int>, unlockHint: String, isComingSoon: Bool = false) {
            self.number = number
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.color = color
            self.levelRange = levelRange
            self.unlockHint = unlockHint
            self.isComingSoon = isComingSoon
        }
    }

    private let halbjahre: [HalbjahrConfig] = [
        HalbjahrConfig(number: 1, title: "1. Halbjahr", subtitle: "Grundlagen", icon: "1.circle.fill", color: .green, levelRange: 1...5, unlockHint: ""),
        HalbjahrConfig(number: 2, title: "2. Halbjahr", subtitle: "Warenkunde", icon: "2.circle.fill", color: .blue, levelRange: 6...10, unlockHint: "Level 5 abschlie\u{00DF}en"),
        HalbjahrConfig(number: 3, title: "3. Halbjahr", subtitle: "Vertiefung", icon: "3.circle.fill", color: .purple, levelRange: 11...15, unlockHint: "Level 10 abschlie\u{00DF}en"),
        HalbjahrConfig(number: 4, title: "4. Halbjahr", subtitle: "Anwenden & Bewerten", icon: "4.circle.fill", color: .orange, levelRange: 16...20, unlockHint: "Commis-Pr\u{00FC}fung bestehen"),
        HalbjahrConfig(number: 5, title: "5. Halbjahr", subtitle: "Pr\u{00FC}fungsvorbereitung", icon: "5.circle.fill", color: .cyan, levelRange: 21...25, unlockHint: "Level 20 abschlie\u{00DF}en", isComingSoon: true),
        HalbjahrConfig(number: 6, title: "6. Halbjahr", subtitle: "Meisterklasse", icon: "6.circle.fill", color: .red, levelRange: 26...30, unlockHint: "Level 25 abschlie\u{00DF}en", isComingSoon: true),
    ]

    private var availableLevels: Set<Int> {
        QuestionLoader.availableLevels(in: allQuestions)
    }

    private var totalAvailableRange: ClosedRange<Int> {
        guard let minLevel = availableLevels.min(), let maxLevel = availableLevels.max() else {
            return 1...1
        }
        return minLevel...maxLevel
    }

    private var unlockedHalbjahrCount: Int {
        halbjahre.filter { progressManager.isHalbjahrUnlocked($0.number) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [Color.blue.opacity(0.5), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 8) {
                            Text("\u{1F41F}")
                                .font(.system(size: 50))
                                .shadow(color: .blue.opacity(flameGlow ? 0.8 : 0.3), radius: flameGlow ? 20 : 8)
                                .scaleEffect(flameGlow ? 1.08 : 1.0)
                                .accessibilityHidden(true)

                            Text("Matjes")
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(.white)

                            Text("der kleine Hering")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)

                            Text("Das Ausbildungsspiel der K\u{00FC}che")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                        .padding(.top, 50)
                        .opacity(headerVisible ? 1 : 0)
                        .offset(y: headerVisible ? 0 : -20)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Matjes, der kleine Hering, Das Ausbildungsspiel der K\u{00FC}che")

                        // Halbjahr-Auswahl + Pr\u{00FC}fungen
                        VStack(spacing: 12) {
                            Text("W\u{00E4}hle dein Halbjahr")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top, 30)
                                .padding(.bottom, 8)

                            // Halbjahr 1
                            halbjahrRow(halbjahre[0])

                            // Halbjahr 2
                            halbjahrRow(halbjahre[1])

                            // Halbjahr 3
                            halbjahrRow(halbjahre[2])

                            // Commis-Pr\u{00FC}fung (nach Halbjahr 3)
                            examRow(ExamConfig.commisPruefung)

                            // Halbjahr 4
                            halbjahrRow(halbjahre[3])

                            // Halbjahr 5 (Coming Soon)
                            halbjahrRow(halbjahre[4])

                            // Halbjahr 6 (Coming Soon)
                            halbjahrRow(halbjahre[5])

                            // Bossfight (nach Halbjahr 6)
                            examRow(ExamConfig.bossfight)
                        }
                        .padding(.horizontal, 20)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 30)

                        // Alle Level Button (nur wenn mindestens 2 Halbjahre freigeschaltet)
                        if unlockedHalbjahrCount > 1 {
                            NavigationLink(destination: LevelGridView(
                                halbjahr: 0,
                                levelRange: totalAvailableRange,
                                allQuestions: allQuestions
                            )) {
                                HStack {
                                    Image(systemName: "square.grid.3x3.fill")
                                        .font(.title3)
                                    Text("Alle Level")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.orange)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange, lineWidth: 2)
                                        .shadow(color: .orange.opacity(0.3), radius: 5)
                                )
                            }
                            .accessibilityLabel("Alle Level anzeigen")
                            .padding(.top, 20)
                            .opacity(contentVisible ? 1 : 0)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            // iMOPS Wasserzeichen + Signatur
            .overlay(alignment: .bottom) {
                ZStack {
                    // iMOPS Wasserzeichen - mittig unten
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 50, height: 4)
                        Text("\u{2303}")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.06))
                            .offset(y: -4)
                        Text("iMOPS")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.06))
                            .offset(y: -6)
                    }
                    .padding(.bottom, 30)

                    // ;=)_ Signatur unten links
                    HStack {
                        HStack(spacing: 0) {
                            Text(";=)")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.green.opacity(0.4))
                            Text("_")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.green.opacity(cursorVisible ? 0.6 : 0.0))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
            .alert("Kommt bald! \u{1F41F}", isPresented: $showComingSoonAlert) {
                Button("Alles klar!", role: .cancel) { }
            } message: {
                Text("Dieses Halbjahr wird mit einem der n\u{00E4}chsten Updates freigeschaltet. Matjes arbeitet daran!")
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    headerVisible = true
                }

                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    flameGlow = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        contentVisible = true
                    }
                }

                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    cursorVisible.toggle()
                }
            }
        }
    }

    // MARK: - Halbjahr Row

    @ViewBuilder
    private func halbjahrRow(_ config: HalbjahrConfig) -> some View {
        if config.isComingSoon {
            Button {
                showComingSoonAlert = true
            } label: {
                HalbjahrButtonContent(
                    title: config.title,
                    subtitle: config.subtitle,
                    icon: config.icon,
                    color: config.color,
                    locked: false,
                    unlockHint: "",
                    isComingSoon: true
                )
            }
        } else {
            let hasQuestions = config.levelRange.contains(where: { availableLevels.contains($0) })
            let isUnlocked = progressManager.isHalbjahrUnlocked(config.number)

            if hasQuestions {
                if isUnlocked {
                    NavigationLink(destination: LevelGridView(
                        halbjahr: config.number,
                        levelRange: config.levelRange,
                        allQuestions: allQuestions
                    )) {
                        HalbjahrButtonContent(
                            title: config.title,
                            subtitle: config.subtitle,
                            icon: config.icon,
                            color: config.color,
                            locked: false,
                            unlockHint: ""
                        )
                    }
                } else {
                    HalbjahrButtonContent(
                        title: config.title,
                        subtitle: config.subtitle,
                        icon: config.icon,
                        color: config.color,
                        locked: true,
                        unlockHint: config.unlockHint
                    )
                }
            }
        }
    }

    // MARK: - Exam Row

    @ViewBuilder
    private func examRow(_ exam: ExamConfig) -> some View {
        let isUnlocked = progressManager.isExamUnlocked(exam)
        let bestResult = progressManager.examResult(for: exam.id)

        if isUnlocked {
            NavigationLink(destination: ExamGameView(
                config: exam,
                allQuestions: allQuestions
            )) {
                ExamButton(exam: exam, bestResult: bestResult)
            }
        } else {
            ExamButton(exam: exam, bestResult: nil, locked: true)
        }
    }
}

// MARK: - Halbjahr Button
struct HalbjahrButtonContent: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let locked: Bool
    let unlockHint: String
    var isComingSoon: Bool = false

    private var titleColor: Color {
        if isComingSoon { return color.opacity(0.5) }
        if locked { return .gray }
        return .white
    }

    private var subtitleText: String {
        if isComingSoon { return "Kommt im n\u{00E4}chsten Update" }
        if locked { return unlockHint }
        return subtitle
    }

    private var subtitleColor: Color {
        if isComingSoon { return color.opacity(0.3) }
        return .gray
    }

    private var fillColor: Color {
        if isComingSoon { return color.opacity(0.03) }
        if locked { return Color.gray.opacity(0.05) }
        return Color.white.opacity(0.08)
    }

    private var strokeColor: Color {
        if isComingSoon { return color.opacity(0.15) }
        if locked { return Color.gray.opacity(0.15) }
        return color.opacity(0.3)
    }

    var body: some View {
        HStack(spacing: 16) {
            iconView
            labelView
            Spacer()
            trailingView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(backgroundView)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var iconView: some View {
        if isComingSoon {
            Image(systemName: "clock.badge")
                .font(.system(size: 28))
                .foregroundColor(color.opacity(0.5))
                .frame(width: 50)
        } else {
            Image(systemName: locked ? "lock.fill" : icon)
                .font(.system(size: 32))
                .foregroundColor(locked ? .gray : color)
                .frame(width: 50)
        }
    }

    @ViewBuilder
    private var labelView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(titleColor)

                if isComingSoon {
                    Text("BALD")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(color.opacity(0.4)))
                }
            }
            Text(subtitleText)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(subtitleColor)
        }
    }

    @ViewBuilder
    private var trailingView: some View {
        if isComingSoon {
            Image(systemName: "info.circle")
                .foregroundColor(color.opacity(0.4))
                .font(.system(size: 16))
        } else if !locked {
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .bold))
        }
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }

    private var accessibilityText: String {
        if isComingSoon { return "\(title), \(subtitle), kommt bald" }
        if locked { return "\(title), gesperrt, \(unlockHint)" }
        return "\(title), \(subtitle)"
    }
}

// MARK: - Pr\u{00FC}fungs-Button
struct ExamButton: View {
    let exam: ExamConfig
    let bestResult: ExamResult?
    var locked: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: locked ? "lock.fill" : exam.icon)
                .font(.system(size: 28))
                .foregroundColor(locked ? .gray : exam.color)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 2) {
                Text(exam.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(locked ? .gray : .white)

                if locked {
                    Text("Level \(exam.unlockLevel) abschlie\u{00DF}en")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                } else if let result = bestResult {
                    HStack(spacing: 6) {
                        Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(result.passed ? .green : .red)
                            .font(.caption)
                        Text("Bestes: \(Int(result.percentage))%")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(result.passed ? .green : .red)
                    }
                } else {
                    Text("\(exam.fragenAnzahl) Fragen \u{00B7} \(exam.dauerMinuten) Min.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if !locked {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .bold))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(locked ? Color.gray.opacity(0.05) : exam.color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            locked ? Color.gray.opacity(0.15) : exam.color.opacity(0.3),
                            lineWidth: locked ? 1 : 2
                        )
                )
        )
        .accessibilityLabel(locked ? "\(exam.name), gesperrt" : "\(exam.name), \(exam.subtitle)")
    }
}
