//
//  ResultView.swift
//  MatjesSchule
//
//  Level-Ergebnis mit Sterne-Bewertung
//

import SwiftUI

struct ResultView: View {
    let level: Int
    let errors: Int
    let totalQuestions: Int
    let stars: Int
    let onReplay: () -> Void
    let onBackToGrid: () -> Void

    @State private var showIcon = false
    @State private var showStars: [Bool] = [false, false, false]
    @State private var showScore = false
    @State private var showButtons = false
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var confettiActive = false

    private var correctAnswers: Int {
        totalQuestions - errors
    }

    private var resultMessage: String {
        switch stars {
        case 3: return "Meisterhaft!"
        case 2: return "Gut gemacht!"
        case 1: return "Bestanden!"
        default: return "Nochmal versuchen!"
        }
    }

    private var resultEmoji: String {
        switch stars {
        case 3: return "trophy.fill"
        case 2: return "hand.thumbsup.fill"
        case 1: return "checkmark.circle.fill"
        default: return "arrow.counterclockwise.circle.fill"
        }
    }

    private var resultColor: Color {
        switch stars {
        case 3: return .yellow
        case 2: return .green
        case 1: return .blue
        default: return .orange
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                // Icon mit Bounce
                Image(systemName: resultEmoji)
                    .font(.system(size: 70))
                    .foregroundColor(resultColor)
                    .shadow(color: resultColor.opacity(0.5), radius: 15)
                    .scaleEffect(showIcon ? 1.0 : 0.3)
                    .opacity(showIcon ? 1 : 0)
                    .padding(.bottom, 16)

                // Titel
                Text("Level \(level)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .opacity(showIcon ? 1 : 0)

                Text(resultMessage)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 4)
                    .opacity(showIcon ? 1 : 0)

                // Sterne - sequentiell animiert
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(i < stars && showStars[i] ? .yellow : .gray.opacity(0.3))
                            .shadow(color: i < stars && showStars[i] ? .yellow.opacity(0.5) : .clear, radius: 5)
                            .scaleEffect(showStars[i] ? 1.0 : 0.5)
                            .rotationEffect(.degrees(showStars[i] ? 0 : -30))
                    }
                }
                .padding(.top, 24)

                // Score
                VStack(spacing: 8) {
                    HStack(spacing: 20) {
                        ScoreBadge(
                            icon: "checkmark.circle.fill",
                            value: "\(correctAnswers)",
                            label: "Richtig",
                            color: .green
                        )
                        ScoreBadge(
                            icon: "xmark.circle.fill",
                            value: "\(errors)",
                            label: "Fehler",
                            color: .red
                        )
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 40)
                .opacity(showScore ? 1 : 0)
                .offset(y: showScore ? 0 : 20)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        SoundManager.instance.triggerHaptic(style: .medium)
                        onReplay()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Nochmal spielen")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.orange)
                        )
                    }

                    Button(action: {
                        SoundManager.instance.triggerHaptic(style: .light)
                        onBackToGrid()
                    }) {
                        HStack {
                            Image(systemName: "square.grid.3x3")
                            Text("Zum Level-Grid")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                .opacity(showButtons ? 1 : 0)
                .offset(y: showButtons ? 0 : 30)
            }

            // Konfetti für 3 Sterne
            if stars == 3 {
                ConfettiOverlay(particles: confettiParticles, active: confettiActive)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            triggerEntrance()
        }
    }

    private func triggerEntrance() {
        // Icon bounce
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            showIcon = true
        }

        // Sterne sequentiell
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.25) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                    showStars[i] = true
                }
                if i < stars {
                    SoundManager.instance.triggerHaptic(style: .light)
                }
            }
        }

        // Score einblenden
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.4)) {
                showScore = true
            }
        }

        // Buttons einblenden
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.4)) {
                showButtons = true
            }
        }

        // Konfetti bei 3 Sternen
        if stars == 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                confettiParticles = (0..<40).map { _ in
                    ConfettiParticle()
                }
                withAnimation(.easeOut(duration: 2.5)) {
                    confettiActive = true
                }
            }
        }
    }
}

// MARK: - Konfetti
struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let startX: CGFloat
    let endX: CGFloat
    let size: CGFloat
    let rotation: Double

    init() {
        let colors: [Color] = [.yellow, .orange, .red, .green, .blue, .purple, .pink]
        self.color = colors.randomElement() ?? .yellow
        self.startX = CGFloat.random(in: 0.1...0.9)
        self.endX = startX + CGFloat.random(in: -0.15...0.15)
        self.size = CGFloat.random(in: 6...12)
        self.rotation = Double.random(in: 180...720)
    }
}

struct ConfettiOverlay: View {
    let particles: [ConfettiParticle]
    let active: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: p.size, height: p.size * 0.6)
                        .position(
                            x: (active ? p.endX : p.startX) * geo.size.width,
                            y: active ? geo.size.height + 20 : geo.size.height * 0.15
                        )
                        .rotationEffect(.degrees(active ? p.rotation : 0))
                        .opacity(active ? 0 : 1)
                }
            }
        }
    }
}

// MARK: - Score Badge
struct ScoreBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 28, weight: .black, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
