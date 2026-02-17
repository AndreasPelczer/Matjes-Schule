//
//  CloudKitManager.swift
//  MatjesSchule
//
//  CloudKit-Integration fuer Schueler-Fortschritte und Klassen-Sync.
//  Verwendet publicDB fuer alle geteilten Daten.
//  Offline-faehig: Speichert lokal und synct bei Verbindung.
//

import Foundation
import CloudKit
import Combine

class CloudKitManager: ObservableObject {

    static let shared = CloudKitManager()

    private let container = CKContainer.default()
    private let publicDB: CKDatabase

    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published var isAvailable: Bool = false

    private let syncState = SyncState.shared

    init() {
        publicDB = container.publicCloudDatabase
    }

    // MARK: - Account Status

    func pruefeAccount() async {
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                self.accountStatus = status
                self.isAvailable = (status == .available)
                if status != .available {
                    self.syncState.status = .noAccount
                }
            }
        } catch {
            await MainActor.run {
                self.isAvailable = false
                self.syncState.status = .noAccount
            }
        }
    }

    // MARK: - Generic Save

    func save<T: CKRecordConvertible>(_ item: T) async throws {
        guard isAvailable else {
            syncState.addPending(SyncOperation(
                recordType: T.recordType,
                recordId: item.recordID.recordName,
                operationType: .save
            ))
            return
        }

        let record = item.toCKRecord()
        do {
            // Erst versuchen, existierenden Record zu holen (fuer Update)
            if let existing = try? await publicDB.record(for: item.recordID) {
                // Felder vom neuen Record auf den existierenden uebertragen
                for key in record.allKeys() {
                    existing[key] = record[key]
                }
                try await publicDB.save(existing)
            } else {
                try await publicDB.save(record)
            }
            syncState.removePending(recordType: T.recordType, recordId: item.recordID.recordName)
        } catch let error as CKError where error.code == .serverRecordChanged {
            // Konflikt: Server-Version hat sich geaendert
            // Server-Record holen und merge versuchen
            if let serverRecord = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord {
                for key in record.allKeys() {
                    serverRecord[key] = record[key]
                }
                try await publicDB.save(serverRecord)
                syncState.removePending(recordType: T.recordType, recordId: item.recordID.recordName)
            }
        }
    }

    // MARK: - Generic Delete

    func delete<T: CKRecordConvertible>(_ item: T) async throws {
        guard isAvailable else {
            syncState.addPending(SyncOperation(
                recordType: T.recordType,
                recordId: item.recordID.recordName,
                operationType: .delete
            ))
            return
        }

        do {
            try await publicDB.deleteRecord(withID: item.recordID)
            syncState.removePending(recordType: T.recordType, recordId: item.recordID.recordName)
        } catch let error as CKError where error.code == .unknownItem {
            // Record existiert nicht mehr auf dem Server - kein Problem
            syncState.removePending(recordType: T.recordType, recordId: item.recordID.recordName)
        }
    }

    // MARK: - Generic Fetch

    func fetchAll<T: CKRecordConvertible>(_ type: T.Type) async throws -> [T] {
        let query = CKQuery(recordType: T.recordType, predicate: NSPredicate(value: true))
        return try await fetchWithQuery(query, type: type)
    }

    func fetch<T: CKRecordConvertible>(_ type: T.Type, predicate: NSPredicate) async throws -> [T] {
        let query = CKQuery(recordType: T.recordType, predicate: predicate)
        return try await fetchWithQuery(query, type: type)
    }

    func fetchSingle<T: CKRecordConvertible>(_ type: T.Type, id: UUID) async throws -> T? {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        do {
            let record = try await publicDB.record(for: recordID)
            return T.fromCKRecord(record)
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        }
    }

    private func fetchWithQuery<T: CKRecordConvertible>(_ query: CKQuery, type: T.Type) async throws -> [T] {
        var results: [T] = []
        var cursor: CKQueryOperation.Cursor?

        let (matchResults, queryCursor) = try await publicDB.records(matching: query)
        for (_, result) in matchResults {
            if let record = try? result.get(),
               let item = T.fromCKRecord(record) {
                results.append(item)
            }
        }
        cursor = queryCursor

        // Weitere Seiten laden falls vorhanden
        while let currentCursor = cursor {
            let (moreResults, nextCursor) = try await publicDB.records(continuingMatchFrom: currentCursor)
            for (_, result) in moreResults {
                if let record = try? result.get(),
                   let item = T.fromCKRecord(record) {
                    results.append(item)
                }
            }
            cursor = nextCursor
        }

        return results
    }

    // MARK: - Ausbilder-spezifische Queries

    func fetchKlassen(fuerAusbilder ausbilderId: UUID) async throws -> [Klasse] {
        let predicate = NSPredicate(format: "ausbilderId == %@", ausbilderId.uuidString)
        return try await fetch(Klasse.self, predicate: predicate)
    }

    func fetchSchueler(fuerKlasse klasseId: UUID) async throws -> [Schueler] {
        let predicate = NSPredicate(format: "klasseId == %@", klasseId.uuidString)
        return try await fetch(Schueler.self, predicate: predicate)
    }

    func fetchSchueler(fuerAusbilder ausbilderId: UUID, klassenIds: [UUID]) async throws -> [Schueler] {
        var alleSchueler: [Schueler] = []
        for klasseId in klassenIds {
            let schueler = try await fetchSchueler(fuerKlasse: klasseId)
            alleSchueler.append(contentsOf: schueler)
        }
        return alleSchueler
    }

    func fetchFortschritte(fuerSchuelerIds schuelerIds: [UUID]) async throws -> [SchuelerFortschritt] {
        var alleFortschritte: [SchuelerFortschritt] = []
        // CloudKit erlaubt max ~250 Elemente in IN-Queries, batchweise verarbeiten
        let batches = stride(from: 0, to: schuelerIds.count, by: 50).map {
            Array(schuelerIds[$0..<min($0 + 50, schuelerIds.count)])
        }
        for batch in batches {
            let idStrings = batch.map { $0.uuidString }
            let predicate = NSPredicate(format: "schuelerId IN %@", idStrings)
            let fortschritte = try await fetch(SchuelerFortschritt.self, predicate: predicate)
            alleFortschritte.append(contentsOf: fortschritte)
        }
        return alleFortschritte
    }

    func fetchFragenkataloge(fuerAusbilder ausbilderId: UUID) async throws -> [Fragenkatalog] {
        let predicate = NSPredicate(format: "ausbilderId == %@", ausbilderId.uuidString)
        return try await fetch(Fragenkatalog.self, predicate: predicate)
    }

    func fetchAusbilderFragen(fuerKatalog katalogId: UUID) async throws -> [AusbilderFrage] {
        let predicate = NSPredicate(format: "katalogId == %@", katalogId.uuidString)
        return try await fetch(AusbilderFrage.self, predicate: predicate)
    }

    // MARK: - Einladungscode suchen (Schueler tritt Klasse bei)

    func schuelerMitCode(_ code: String) async throws -> Schueler? {
        let predicate = NSPredicate(format: "einladungsCode == %@", code.uppercased())
        let results = try await fetch(Schueler.self, predicate: predicate)
        return results.first { $0.istAktiv }
    }

    // MARK: - Fortschritt mit Merge-Strategie speichern

    func saveFortschrittMitMerge(_ localFortschritt: SchuelerFortschritt) async throws -> SchuelerFortschritt {
        // Remote-Version holen
        if let remoteFortschritt = try await fetchSingle(SchuelerFortschritt.self, id: localFortschritt.id) {
            // Merge: Beste Ergebnisse behalten
            let merged = localFortschritt.merged(with: remoteFortschritt)
            try await save(merged)
            return merged
        } else {
            // Kein Remote-Record vorhanden, einfach speichern
            try await save(localFortschritt)
            return localFortschritt
        }
    }

    // MARK: - Batch Save (fuer mehrere Records auf einmal)

    func batchSave<T: CKRecordConvertible>(_ items: [T]) async throws {
        guard isAvailable else {
            for item in items {
                syncState.addPending(SyncOperation(
                    recordType: T.recordType,
                    recordId: item.recordID.recordName,
                    operationType: .save
                ))
            }
            return
        }

        let records = items.map { $0.toCKRecord() }
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    for item in items {
                        self.syncState.removePending(
                            recordType: T.recordType,
                            recordId: item.recordID.recordName
                        )
                    }
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            self.publicDB.add(operation)
        }
    }

    // MARK: - Vollstaendiger Sync (Ausbilder)

    /// Synct alle Daten eines Ausbilders: Klassen, Schueler, Fortschritte, Fragenkataloge.
    func syncAllesAusbilder(
        ausbilder: Ausbilder,
        klassen: [Klasse],
        schueler: [Schueler],
        fortschritte: [SchuelerFortschritt],
        fragenkataloge: [Fragenkatalog],
        ausbilderFragen: [AusbilderFrage]
    ) async throws -> SyncErgebnis {
        await MainActor.run { syncState.status = .syncing }

        var ergebnis = SyncErgebnis()

        do {
            // 1. Ausbilder speichern
            try await save(ausbilder)
            ergebnis.gespeichert += 1

            // 2. Klassen speichern
            try await batchSave(klassen)
            ergebnis.gespeichert += klassen.count

            // 3. Schueler speichern
            try await batchSave(schueler)
            ergebnis.gespeichert += schueler.count

            // 4. Fortschritte mit Merge speichern
            for fortschritt in fortschritte {
                let merged = try await saveFortschrittMitMerge(fortschritt)
                ergebnis.gemergteRecords.append(merged)
                ergebnis.gespeichert += 1
            }

            // 5. Fragenkataloge speichern
            try await batchSave(fragenkataloge)
            ergebnis.gespeichert += fragenkataloge.count

            // 6. Ausbilder-Fragen speichern
            try await batchSave(ausbilderFragen)
            ergebnis.gespeichert += ausbilderFragen.count

            // 7. Remote-Daten holen (Schueler-Fortschritte koennten sich geaendert haben)
            let klassenIds = klassen.map { $0.id }
            let remoteSchueler = try await fetchSchueler(fuerAusbilder: ausbilder.id, klassenIds: klassenIds)
            let remoteSchuelerIds = remoteSchueler.map { $0.id }
            let remoteFortschritte = try await fetchFortschritte(fuerSchuelerIds: remoteSchuelerIds)
            ergebnis.remoteFortschritte = remoteFortschritte
            ergebnis.remoteSchueler = remoteSchueler
            ergebnis.geladen += remoteFortschritte.count + remoteSchueler.count

            await MainActor.run { syncState.markSyncSuccess() }
            return ergebnis

        } catch {
            await MainActor.run { syncState.markSyncError(error.localizedDescription) }
            throw error
        }
    }

    // MARK: - Vollstaendiger Sync (Schueler)

    /// Synct den Fortschritt eines einzelnen Schuelers.
    func syncSchuelerFortschritt(
        schueler: Schueler,
        fortschritt: SchuelerFortschritt
    ) async throws -> SchuelerFortschritt {
        await MainActor.run { syncState.status = .syncing }

        do {
            let merged = try await saveFortschrittMitMerge(fortschritt)
            await MainActor.run { syncState.markSyncSuccess() }
            return merged
        } catch {
            await MainActor.run { syncState.markSyncError(error.localizedDescription) }
            throw error
        }
    }

    // MARK: - Pending Operations verarbeiten

    func verarbeitePending(dataStore: DataStore) async {
        guard isAvailable else { return }

        let pending = syncState.pendingOperations
        guard !pending.isEmpty else { return }

        for operation in pending {
            do {
                switch operation.operationType {
                case .save:
                    try await verarbeitePendingSave(operation, dataStore: dataStore)
                case .delete:
                    try await verarbeitePendingDelete(operation)
                }
            } catch {
                // Bei Fehler: Operation bleibt in der Queue
                continue
            }
        }
    }

    private func verarbeitePendingSave(_ operation: SyncOperation, dataStore: DataStore) async throws {
        guard let uuid = UUID(uuidString: operation.recordId) else { return }

        switch operation.recordType {
        case Ausbilder.recordType:
            if let item = dataStore.ausbilder, item.id == uuid {
                try await save(item)
            }
        case Klasse.recordType:
            if let item = dataStore.klassen.first(where: { $0.id == uuid }) {
                try await save(item)
            }
        case Schueler.recordType:
            if let item = dataStore.schueler.first(where: { $0.id == uuid }) {
                try await save(item)
            }
        case SchuelerFortschritt.recordType:
            if let item = dataStore.fortschritte.first(where: { $0.id == uuid }) {
                _ = try await saveFortschrittMitMerge(item)
            }
        case Fragenkatalog.recordType:
            if let item = dataStore.fragenkataloge.first(where: { $0.id == uuid }) {
                try await save(item)
            }
        case AusbilderFrage.recordType:
            if let item = dataStore.ausbilderFragen.first(where: { $0.id == uuid }) {
                try await save(item)
            }
        default:
            break
        }
    }

    private func verarbeitePendingDelete(_ operation: SyncOperation) async throws {
        let recordID = CKRecord.ID(recordName: operation.recordId)
        do {
            try await publicDB.deleteRecord(withID: recordID)
        } catch let error as CKError where error.code == .unknownItem {
            // Bereits geloescht
        }
        syncState.removePending(operation)
    }
}

// MARK: - Sync-Ergebnis

struct SyncErgebnis {
    var gespeichert: Int = 0
    var geladen: Int = 0
    var gemergteRecords: [SchuelerFortschritt] = []
    var remoteFortschritte: [SchuelerFortschritt] = []
    var remoteSchueler: [Schueler] = []
}
