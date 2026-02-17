//
//  Exam.swift
//  MatjesSchule
//
//  Pruefungskonfiguration und -ergebnis (portiert aus V1/V2)
//

import Foundation
import SwiftUI

struct ExamConfig: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
    let fragenAnzahl: Int
    let dauerMinuten: Int
    let bestehensgrenzeProzent: Int
    let levelRange: ClosedRange<Int>
    let unlockLevel: Int

    var dauerSekunden: Int { dauerMinuten * 60 }

    static let commisPruefung = ExamConfig(
        id: "commis",
        name: "Commis-Pr\u{00FC}fung",
        subtitle: "Zwischenpr\u{00FC}fung",
        icon: "shield.checkered",
        color: .orange,
        fragenAnzahl: 30,
        dauerMinuten: 20,
        bestehensgrenzeProzent: 70,
        levelRange: 1...15,
        unlockLevel: 15
    )

    static let bossfight = ExamConfig(
        id: "bossfight",
        name: "Bossfight",
        subtitle: "Abschlusspr\u{00FC}fung",
        icon: "trophy.fill",
        color: .red,
        fragenAnzahl: 50,
        dauerMinuten: 40,
        bestehensgrenzeProzent: 70,
        levelRange: 1...20,
        unlockLevel: 20
    )

    static let allExams: [ExamConfig] = [commisPruefung, bossfight]
}

struct ExamResult: Codable {
    let passed: Bool
    let percentage: Double
    let correctAnswers: Int
    let totalQuestions: Int
    let timeUsedSeconds: Int
    let date: Date
}
