//
//  LevelGameView.swift
//  MatjesSchule
//
//  Quiz-Gameplay pro Level
//

import SwiftUI

struct LevelGameView: View {
    @StateObject private var viewModel: GameViewModel
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) private var dismiss

    let level: Int
    private let answerLabels = ["A", "B", "C", "D"]

    init(level: Int, allQuestions: [Question]) {
        self.level = level
        _viewModel = StateObject(wrappedValue: GameViewModel(level: level, allQuestions: allQuestions))
    }

    var body: some View {
        ZStack {
            // Hintergrund
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color.blue.opacity(0.5), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if viewModel.isLevelComplete {
                // Ergebnis-Anzeige
                ResultView(
                    level: level,
                    errors: viewModel.errors,
                    totalQuestions: viewModel.questions.count,
                    stars: viewModel.starsEarned,
                    onReplay: { viewModel.startLevel() },
                    onBackToGrid: { dismiss() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if let question = viewModel.currentQuestion {
                // Quiz-Gameplay
                VStack(spacing: 0) {
                    // Kopfzeile
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("LEVEL \(level)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            Text("Frage \(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        // Fehler-Anzeige
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(viewModel.errors > 0 ? .red : .gray.opacity(0.3))
                            Text("\(viewModel.errors)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(viewModel.errors > 0 ? .red : .gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * viewModel.progressFraction, height: 6)
                                .animation(.easeInOut(duration: 0.4), value: viewModel.progressFraction)
                                .shadow(color: .orange.opacity(0.4), radius: 3, y: 0)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Frage + Antworten mit Übergangs-Animation
                    ScrollView {
                        VStack(spacing: 20) {
                            Text(question.text)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 24)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.blue.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 20)

                            // Antworten
                            VStack(spacing: 10) {
                                ForEach(0..<viewModel.shuffledAnswers.count, id: \.self) { idx in
                                    AnswerButton(
                                        label: answerLabels[idx],
                                        text: viewModel.shuffledAnswers[idx].text,
                                        state: buttonState(for: idx),
                                        action: {
                                            SoundManager.instance.triggerHaptic(style: .light)
                                            viewModel.submitAnswer(shuffledIndex: idx)
                                        }
                                    )
                                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                                }
                            }

                            // Erklärung bei falscher Antwort
                            if case .wrong(_, _) = viewModel.answerState {
                                VStack(spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                        Text("Erklärung")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(.yellow)
                                    }

                                    Text(question.erklaerung)
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.orange.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 16)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            // Weiter-Button (nach Antwort)
                            if viewModel.answerState != .waiting {
                                Button(action: {
                                    SoundManager.instance.triggerHaptic(style: .medium)
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.nextQuestion()
                                    }
                                }) {
                                    HStack {
                                        Text("Weiter")
                                            .font(.system(size: 17, weight: .bold, design: .rounded))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .foregroundColor(.black)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.orange)
                                            .shadow(color: .orange.opacity(0.4), radius: 8)
                                    )
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 30)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .id(viewModel.currentIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.3), value: viewModel.answerState)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isLevelComplete)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
    }

    private func buttonState(for shuffledIndex: Int) -> AnswerButton.ButtonState {
        switch viewModel.answerState {
        case .waiting:
            return .normal
        case .correct(let selected):
            if shuffledIndex == selected { return .correct }
            return .dimmed
        case .wrong(let selected, let correctIdx):
            if shuffledIndex == selected { return .wrong }
            if shuffledIndex == correctIdx { return .correct }
            return .dimmed
        }
    }
}
