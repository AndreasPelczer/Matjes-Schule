//
//  QuestionLoader.swift
//  MatjesSchule
//
//  JSON-Parser fuer Kuechenfachkunde-Fragen (portiert aus V1/V2)
//

import Foundation

class QuestionLoader {

    /// Gecachte Fragen (JSON + generierte), werden nur einmal pro Session geladen
    private static var cachedQuestions: [Question]?

    static func loadFromJSON() -> [Question] {
        if let cached = cachedQuestions {
            return cached
        }

        // 1. JSON-Fragen laden (Level 1-11)
        var questions: [Question] = []
        if let url = Bundle.main.url(forResource: "Matjes_Fragen_Level1-11", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                questions = try JSONDecoder().decode([Question].self, from: data)
            } catch {
                #if DEBUG
                print("JSON-Ladefehler: \(error)")
                #endif
            }
        } else {
            #if DEBUG
            print("JSON-Datei nicht gefunden!")
            #endif
        }

        // 2. Generierte Fragen aus Lexikon-Daten (Level 12-20)
        for level in LexikonQuizGenerator.generatedLevels.sorted() {
            let generated = LexikonQuizGenerator.generateQuestions(forLevel: level)
            questions.append(contentsOf: generated)
            #if DEBUG
            print("Level \(level): \(generated.count) Fragen generiert")
            #endif
        }

        cachedQuestions = questions
        return questions
    }

    static func availableLevels(in questions: [Question]) -> Set<Int> {
        Set(questions.map { $0.level })
    }
}
