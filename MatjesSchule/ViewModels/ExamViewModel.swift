//
//  ExamViewModel.swift
//  MatjesSchule
//
//  Pruefungs-Logik: Timer, gemischte Fragen, Bestanden/Durchgefallen (portiert aus V1/V2)
//

import Foundation
import SwiftUI
import Combine

class ExamViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var correctCount: Int = 0
    @Published var answerState: AnswerState = .waiting
    @Published var shuffledAnswers: [(text: String, originalIndex: Int)] = []
    @Published var isExamComplete: Bool = false
    @Published var timeRemaining: Int
    @Published var isTimeUp: Bool = false

    let config: ExamConfig
    private let allQuestions: [Question]
    private var timer: AnyCancellable?
    private var startTime: Date?
    var timeUsedSeconds: Int = 0

    enum AnswerState: Equatable {
        case waiting
        case correct(selected: Int)
        case wrong(selected: Int, correctShuffledIndex: Int)

        static func == (lhs: AnswerState, rhs: AnswerState) -> Bool {
            switch (lhs, rhs) {
            case (.waiting, .waiting): return true
            case (.correct(let a), .correct(let b)): return a == b
            case (.wrong(let s1, let c1), .wrong(let s2, let c2)): return s1 == s2 && c1 == c2
            default: return false
            }
        }
    }

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progressFraction: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(questions.count)
    }

    var errorCount: Int {
        (currentIndex < questions.count ? currentIndex : questions.count) - correctCount
    }

    var percentage: Double {
        guard questions.count > 0 else { return 0 }
        let answered = isExamComplete ? questions.count : currentIndex
        guard answered > 0 else { return 0 }
        return Double(correctCount) / Double(answered) * 100
    }

    var passed: Bool {
        percentage >= Double(config.bestehensgrenzeProzent)
    }

    var timerText: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    init(config: ExamConfig, allQuestions: [Question]) {
        self.config = config
        self.allQuestions = allQuestions
        self.timeRemaining = config.dauerSekunden
        startExam()
    }

    func startExam() {
        var pool: [Question] = []
        for level in config.levelRange {
            let levelQuestions = allQuestions.filter { $0.level == level }
            pool.append(contentsOf: levelQuestions)
        }

        pool.shuffle()
        questions = Array(pool.prefix(config.fragenAnzahl))

        if questions.count < config.fragenAnzahl && !pool.isEmpty {
            var filled = questions
            while filled.count < config.fragenAnzahl {
                if let extra = pool.randomElement() {
                    filled.append(extra)
                }
            }
            questions = filled.shuffled()
        }

        currentIndex = 0
        correctCount = 0
        answerState = .waiting
        isExamComplete = false
        isTimeUp = false
        timeRemaining = config.dauerSekunden
        timeUsedSeconds = 0
        startTime = Date()

        shuffleCurrentAnswers()
        startTimer()
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isExamComplete else {
                    self?.timer?.cancel()
                    return
                }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timeUp()
                }
            }
    }

    private func timeUp() {
        timer?.cancel()
        isTimeUp = true
        finishExam()
    }

    func shuffleCurrentAnswers() {
        guard let q = currentQuestion else { return }
        shuffledAnswers = q.answers.enumerated()
            .map { (text: $0.element, originalIndex: $0.offset) }
            .shuffled()
    }

    func submitAnswer(shuffledIndex: Int) {
        guard case .waiting = answerState else { return }

        let (_, originalIndex) = shuffledAnswers[shuffledIndex]

        if originalIndex == currentQuestion?.correctIndex {
            correctCount += 1
            answerState = .correct(selected: shuffledIndex)
            SoundManager.instance.triggerNotificationHaptic(type: .success)
        } else {
            let correctShuffled = shuffledAnswers.firstIndex { $0.originalIndex == currentQuestion?.correctIndex } ?? 0
            answerState = .wrong(selected: shuffledIndex, correctShuffledIndex: correctShuffled)
            SoundManager.instance.triggerNotificationHaptic(type: .error)
        }
    }

    func nextQuestion() {
        if currentIndex + 1 >= questions.count {
            finishExam()
        } else {
            currentIndex += 1
            answerState = .waiting
            shuffleCurrentAnswers()
        }
    }

    private func finishExam() {
        timer?.cancel()
        if let start = startTime {
            timeUsedSeconds = Int(Date().timeIntervalSince(start))
        }
        isExamComplete = true

        let result = ExamResult(
            passed: passed,
            percentage: percentage,
            correctAnswers: correctCount,
            totalQuestions: questions.count,
            timeUsedSeconds: timeUsedSeconds,
            date: Date()
        )
        ProgressManager.shared.saveExamResult(examId: config.id, result: result)

        if passed {
            SoundManager.instance.playSound(sound: .applaus)
        }
    }

    deinit {
        timer?.cancel()
    }
}
