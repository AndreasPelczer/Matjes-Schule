//
//  Question.swift
//  MatjesSchule
//
//  Fragen-Datenmodell (portiert aus V1/V2)
//

import Foundation

struct Question: Identifiable, Codable {
    let id: UUID
    let level: Int
    let text: String
    let answers: [String]
    let correctIndex: Int
    let erklaerung: String

    init(level: Int, text: String, answers: [String], correctIndex: Int, erklaerung: String) {
        self.id = UUID()
        self.level = level
        self.text = text
        self.answers = answers
        self.correctIndex = correctIndex
        self.erklaerung = erklaerung
    }

    enum CodingKeys: String, CodingKey {
        case level, text, answers, correctIndex, erklaerung
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.level = try container.decode(Int.self, forKey: .level)
        self.text = try container.decode(String.self, forKey: .text)
        self.answers = try container.decode([String].self, forKey: .answers)
        self.correctIndex = try container.decode(Int.self, forKey: .correctIndex)
        self.erklaerung = try container.decode(String.self, forKey: .erklaerung)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(level, forKey: .level)
        try container.encode(text, forKey: .text)
        try container.encode(answers, forKey: .answers)
        try container.encode(correctIndex, forKey: .correctIndex)
        try container.encode(erklaerung, forKey: .erklaerung)
    }
}
