//
//  ExamResultView.swift
//  MatjesSchule
//
//  Prüfungsergebnis: Bestanden / Durchgefallen
//

import SwiftUI

struct ExamResultView: View {
    let config: ExamConfig
    let passed: Bool
    let percentage: Double
    let correctCount: Int
    let totalQuestions: Int
    let timeUsedSeconds: Int
    let isTimeUp: Bool
    let onRetry: () -> Void
    let onBack: () -> Void

    @State private var showIcon = false
    @State private var showScore = false
    @State private var showDetails = false
    @State private var showButtons = false
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var confettiActive = false
    @State private var ringProgress: CGFloat = 0

    private var errorCount: Int { totalQuestions - correctCount }

    private var timeText: String {
        let min = timeUsedSeconds / 60
        let sec = timeUsedSeconds % 60
        return String(format: "%d:%02d Min.", min, sec)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                // Icon
                Image(systemName: passed ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: 70))
                    .foregroundColor(passed ? .green : .red)
                    .shadow(color: (passed ? Color.green : Color.red).opacity(0.5), radius: 15)
                    .scaleEffect(showIcon ? 1.0 : 0.3)
                    .opacity(showIcon ? 1 : 0)
                    .padding(.bottom, 12)

                // Bestanden / Durchgefallen
                Text(config.name)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .opacity(showIcon ? 1 : 0)

                Text(passed ? "Bestanden!" : "Durchgefallen")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 4)
                    .opacity(showIcon ? 1 : 0)

                if isTimeUp && !passed {
                    Text("Zeit abgelaufen!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .padding(.top, 4)
                        .opacity(showIcon ? 1 : 0)
                }

                // Prozent-Ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 10)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            passed ? Color.green : Color.red,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(Int(percentage))%")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text("\(config.bestehensgrenzeProzent)% nötig")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 24)
                .opacity(showScore ? 1 : 0)

                // Detail-Stats
                HStack(spacing: 16) {
                    StatBox(icon: "checkmark.circle.fill", value: "\(correctCount)", label: "Richtig", color: .green)
                    StatBox(icon: "xmark.circle.fill", value: "\(errorCount)", label: "Falsch", color: .red)
                    StatBox(icon: "clock.fill", value: timeText, label: "Zeit", color: .blue)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .opacity(showDetails ? 1 : 0)
                .offset(y: showDetails ? 0 : 20)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        SoundManager.instance.triggerHaptic(style: .medium)
                        onRetry()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Nochmal versuchen")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(config.color)
                        )
                    }

                    Button(action: {
                        SoundManager.instance.triggerHaptic(style: .light)
                        onBack()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Zurück")
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

            // Konfetti bei Bestanden
            if passed {
                ConfettiOverlay(particles: confettiParticles, active: confettiActive)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .onAppear { triggerEntrance() }
    }

    private func triggerEntrance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            showIcon = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                showScore = true
            }
            withAnimation(.easeOut(duration: 1.0)) {
                ringProgress = CGFloat(percentage / 100)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.4)) {
                showDetails = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.4)) {
                showButtons = true
            }
        }

        if passed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                confettiParticles = (0..<50).map { _ in ConfettiParticle() }
                withAnimation(.easeOut(duration: 2.5)) {
                    confettiActive = true
                }
            }
        }
    }
}

// MARK: - Stat Box
private struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
