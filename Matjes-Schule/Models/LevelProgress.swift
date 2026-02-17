//
//  LevelProgress.swift
//  MatjesSchule
//
//  Fortschritt pro Level (portiert aus V1/V2)
//

import Foundation

struct LevelProgress: Codable {
    var stars: Int
    var bestErrors: Int
    var lastPlayed: Date?

    static func starsForErrors(_ errors: Int) -> Int {
        switch errors {
        case 0...1: return 3
        case 2...3: return 2
        case 4...5: return 1
        default: return 0
        }
    }
}
