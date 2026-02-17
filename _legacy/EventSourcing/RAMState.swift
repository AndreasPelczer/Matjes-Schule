//
//  RAMState.swift
//  iMOPS-Gastro-Grid
//
//  Source: iMOPS-Haccp (einziges Vorkommen)
//
//  Lightweight RAM representation of the iMOPS key-value store.
//  Used for replay operations without touching TheBrain's live storage.
//  "Die Thermodynamik der Küche" – State als Funktion der Events.
//
//  Hinweis: RAMState speichert ValueCoder-kodierte Strings ("S:hello"),
//  nicht die dekodierten Any-Werte. Das ist Absicht (Forensik-Diffs).
//

import Foundation

final class RAMState {
    private(set) var storage: [String: String] = [:]

    func set(path: String, value: String) {
        storage[path] = value
    }

    func get(path: String) -> String? {
        storage[path]
    }

    func kill(path: String) {
        storage.removeValue(forKey: path)
    }

    func killTree(prefix: String) {
        storage.keys
            .filter { $0 == prefix || $0.hasPrefix(prefix + ".") }
            .forEach { storage.removeValue(forKey: $0) }
    }

    func removeAll() {
        storage.removeAll()
    }

    /// All keys currently in state
    var allKeys: [String] {
        Array(storage.keys)
    }

    /// Number of entries
    var count: Int {
        storage.count
    }
}
