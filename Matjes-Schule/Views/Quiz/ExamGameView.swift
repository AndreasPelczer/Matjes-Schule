//
//  ExamGameView.swift
//  MatjesSchule
//
//  Prüfungs-Spielansicht mit Timer
//

import SwiftUI

struct ExamGameView: View {
    @StateObject private var viewModel: ExamViewModel
    @Environment(\.dismiss) private var dismiss

    let config: ExamConfig
    private let answerLabels = ["A", "B", "C", "D"]

    init(config: ExamConfig, allQuestions: [Question]) {
        self.config = config
        _viewModel = StateObject(wrappedValue: ExamViewModel(config: config, allQuestions: allQuestions))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [config.color.opacity(0.4), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if viewModel.isExamComplete {
                ExamResultView(
                    config: config,
                    passed: viewModel.passed,
                    percentage: viewModel.percentage,
                    correctCount: viewModel.correctCount,
                    totalQuestions: viewModel.questions.count,
                    timeUsedSeconds: viewModel.timeUsedSeconds,
                    isTimeUp: viewModel.isTimeUp,
                    onRetry: { viewModel.startExam() },
                    onBack: { dismiss() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if let question = viewModel.currentQuestion {
                VStack(spacing: 0) {
                    // Kopfzeile: Prüfungsname + Timer
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(config.name.uppercased())
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            Text("Frage \(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        // Timer
                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                                .foregroundColor(timerColor)
                            Text(viewModel.timerText)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(timerColor)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(timerColor.opacity(0.15))
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Fortschrittsbalken
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [config.color, config.color.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * viewModel.progressFraction, height: 6)
                                .animation(.easeInOut(duration: 0.4), value: viewModel.progressFraction)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Score-Anzeige
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("\(viewModel.correctCount)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("\(viewModel.errorCount)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 8)

                    // Frage + Antworten
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
                                        .fill(config.color.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 16)
                                .padding(.top, 12)

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
                                }
                            }

                            // Weiter-Button (nach Antwort, keine Erklärung in Prüfung)
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
                                            .fill(config.color)
                                            .shadow(color: config.color.opacity(0.4), radius: 8)
                                    )
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 30)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .id(viewModel.currentIndex)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.3), value: viewModel.answerState)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isExamComplete)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
    }

    private var timerColor: Color {
        if viewModel.timeRemaining <= 60 { return .red }
        if viewModel.timeRemaining <= 180 { return .orange }
        return .white
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
