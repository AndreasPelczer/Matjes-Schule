//
//  GameViewModel.swift
//  MatjesSchule
//
//  Level-basierte Quiz-Logik (portiert aus V1/V2)
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var errors: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var answerState: AnswerState = .waiting
    @Published var isLevelComplete: Bool = false
    @Published var shuffledAnswers: [(text: String, originalIndex: Int)] = []

    let level: Int
    private let allQuestions: [Question]
    private let questionsPerLevel = 10

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

    var starsEarned: Int {
        LevelProgress.starsForErrors(errors)
    }

    init(level: Int, allQuestions: [Question]) {
        self.level = level
        self.allQuestions = allQuestions
        _questions = Published(wrappedValue: [])
        _currentIndex = Published(wrappedValue: 0)
        _errors = Published(wrappedValue: 0)
        _selectedAnswer = Published(wrappedValue: nil)
        _answerState = Published(wrappedValue: .waiting)
        _isLevelComplete = Published(wrappedValue: false)
        _shuffledAnswers = Published(wrappedValue: [])
        startLevel()
    }

    func startLevel() {
        let pool = allQuestions.filter { $0.level == level }.shuffled()
        questions = Array(pool.prefix(questionsPerLevel))

        if questions.count < questionsPerLevel && !pool.isEmpty {
            var filled = questions
            while filled.count < questionsPerLevel {
                if let extra = pool.randomElement() {
                    filled.append(extra)
                }
            }
            questions = filled
        }

        currentIndex = 0
        errors = 0
        selectedAnswer = nil
        answerState = .waiting
        isLevelComplete = false
        shuffleCurrentAnswers()
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
        selectedAnswer = shuffledIndex

        if originalIndex == currentQuestion?.correctIndex {
            answerState = .correct(selected: shuffledIndex)
            SoundManager.instance.playSound(sound: .correct)
            SoundManager.instance.triggerNotificationHaptic(type: .success)
        } else {
            errors += 1
            let correctShuffled = shuffledAnswers.firstIndex { $0.originalIndex == currentQuestion?.correctIndex } ?? 0
            answerState = .wrong(selected: shuffledIndex, correctShuffledIndex: correctShuffled)
            SoundManager.instance.playSound(sound: .wrong)
            SoundManager.instance.triggerNotificationHaptic(type: .error)
        }
    }

    func nextQuestion() {
        if currentIndex + 1 >= questions.count {
            isLevelComplete = true
            ProgressManager.shared.updateLevel(level, errors: errors)
            if starsEarned == 3 {
                SoundManager.instance.playSound(sound: .applaus)
            }
        } else {
            currentIndex += 1
            selectedAnswer = nil
            answerState = .waiting
            shuffleCurrentAnswers()
        }
    }
}
