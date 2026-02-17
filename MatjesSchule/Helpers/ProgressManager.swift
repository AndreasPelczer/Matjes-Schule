//
//  ProgressManager.swift
//  MatjesSchule
//
//  Fortschrittsverwaltung (portiert aus V1/V2)
//  V3: Wird spaeter um CloudKit-Sync erweitert, damit Ausbilder
//  den Fortschritt der Schueler sehen koennen.
//

import Foundation
import Combine

class ProgressManager: ObservableObject {
    static let shared = ProgressManager()

    @Published var progress: [Int: LevelProgress] = [:]
    @Published var examResults: [String: ExamResult] = [:]

    private let storageKey = "MatjesSchule_LevelProgress"
    private let examStorageKey = "MatjesSchule_ExamResults"

    init() {
        load()
        loadExamResults()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: LevelProgress].self, from: data)
        else { return }
        progress = Dictionary(uniqueKeysWithValues: decoded.compactMap { key, value in
            guard let intKey = Int(key) else { return nil }
            return (intKey, value)
        })
    }

    func loadExamResults() {
        guard let data = UserDefaults.standard.data(forKey: examStorageKey),
              let decoded = try? JSONDecoder().decode([String: ExamResult].self, from: data)
        else { return }
        examResults = decoded
    }

    func save() {
        let stringKeyed = Dictionary(uniqueKeysWithValues: progress.map { ("\($0.key)", $0.value) })
        guard let data = try? JSONEncoder().encode(stringKeyed) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func updateLevel(_ level: Int, errors: Int) {
        let newStars = LevelProgress.starsForErrors(errors)
        let existing = progress[level]

        if let existing = existing {
            if newStars > existing.stars || errors < existing.bestErrors {
                progress[level] = LevelProgress(
                    stars: max(newStars, existing.stars),
                    bestErrors: min(errors, existing.bestErrors),
                    lastPlayed: Date()
                )
            } else {
                progress[level]?.lastPlayed = Date()
            }
        } else {
            progress[level] = LevelProgress(
                stars: newStars,
                bestErrors: errors,
                lastPlayed: Date()
            )
        }
        save()
    }

    func starsForLevel(_ level: Int) -> Int {
        progress[level]?.stars ?? -1
    }

    func isLevelUnlocked(_ level: Int, in range: ClosedRange<Int>) -> Bool {
        if level == range.lowerBound { return true }
        let previous = level - 1
        guard previous >= range.lowerBound else { return true }
        return starsForLevel(previous) >= 1
    }

    func saveExamResult(examId: String, result: ExamResult) {
        if let existing = examResults[examId] {
            if result.percentage > existing.percentage {
                examResults[examId] = result
            }
        } else {
            examResults[examId] = result
        }
        guard let data = try? JSONEncoder().encode(examResults) else { return }
        UserDefaults.standard.set(data, forKey: examStorageKey)
    }

    func examResult(for examId: String) -> ExamResult? {
        examResults[examId]
    }

    func isExamUnlocked(_ exam: ExamConfig) -> Bool {
        starsForLevel(exam.unlockLevel) >= 1
    }

    func isHalbjahrUnlocked(_ halbjahr: Int) -> Bool {
        switch halbjahr {
        case 1: return true
        case 2: return starsForLevel(5) >= 1
        case 3: return starsForLevel(10) >= 1
        case 4:
            if let result = examResults[ExamConfig.commisPruefung.id] {
                return result.passed
            }
            return false
        case 5: return starsForLevel(20) >= 1
        case 6: return starsForLevel(25) >= 1
        default: return false
        }
    }

    func resetAllProgress() {
        progress = [:]
        examResults = [:]
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: examStorageKey)
    }
}
