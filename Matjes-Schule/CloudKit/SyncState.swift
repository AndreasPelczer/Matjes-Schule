//
//  SyncState.swift
//  MatjesSchule
//
//  Verwaltet den Sync-Zustand zwischen lokaler Datenhaltung und CloudKit.
//  Trackt ausstehende Aenderungen fuer Offline-Faehigkeit.
//

import Foundation
import Combine

// MARK: - Sync Status

enum SyncStatus: String, Codable {
    case idle               // Kein Sync aktiv
    case syncing            // Sync laeuft gerade
    case success            // Letzter Sync erfolgreich
    case error              // Letzter Sync fehlgeschlagen
    case offline            // Kein Netzwerk
    case noAccount          // Kein iCloud-Account
}

// MARK: - Pending Operation

struct SyncOperation: Codable, Identifiable {
    let id: UUID
    let recordType: String
    let recordId: String
    let operationType: OperationType
    let timestamp: Date

    enum OperationType: String, Codable {
        case save
        case delete
    }

    init(recordType: String, recordId: String, operationType: OperationType) {
        self.id = UUID()
        self.recordType = recordType
        self.recordId = recordId
        self.operationType = operationType
        self.timestamp = Date()
    }
}

// MARK: - Sync State

class SyncState: ObservableObject {
    static let shared = SyncState()

    @Published var status: SyncStatus = .idle
    @Published var letzterSync: Date?
    @Published var pendingOperations: [SyncOperation] = []
    @Published var letzterFehler: String?

    private let pendingKey = "MatjesSchule_PendingOps"
    private let lastSyncKey = "MatjesSchule_LastSync"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        ladePending()
        if let interval = UserDefaults.standard.object(forKey: lastSyncKey) as? Double {
            letzterSync = Date(timeIntervalSince1970: interval)
        }
    }

    // MARK: - Pending Operations

    func addPending(_ operation: SyncOperation) {
        // Doppelte Operationen fuer gleichen Record entfernen
        pendingOperations.removeAll {
            $0.recordType == operation.recordType && $0.recordId == operation.recordId
        }
        pendingOperations.append(operation)
        speicherePending()
    }

    func removePending(_ operation: SyncOperation) {
        pendingOperations.removeAll { $0.id == operation.id }
        speicherePending()
    }

    func removePending(recordType: String, recordId: String) {
        pendingOperations.removeAll {
            $0.recordType == recordType && $0.recordId == recordId
        }
        speicherePending()
    }

    func clearAllPending() {
        pendingOperations.removeAll()
        speicherePending()
    }

    var hasPendingOperations: Bool {
        !pendingOperations.isEmpty
    }

    // MARK: - Sync Tracking

    func markSyncSuccess() {
        status = .success
        letzterSync = Date()
        letzterFehler = nil
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastSyncKey)
    }

    func markSyncError(_ error: String) {
        status = .error
        letzterFehler = error
    }

    // MARK: - Persistence

    private func ladePending() {
        guard let data = UserDefaults.standard.data(forKey: pendingKey),
              let decoded = try? decoder.decode([SyncOperation].self, from: data)
        else { return }
        pendingOperations = decoded
    }

    private func speicherePending() {
        guard let data = try? encoder.encode(pendingOperations) else { return }
        UserDefaults.standard.set(data, forKey: pendingKey)
    }
}
