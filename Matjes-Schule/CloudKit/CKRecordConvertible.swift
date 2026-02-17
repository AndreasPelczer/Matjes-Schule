//
//  CKRecordConvertible.swift
//  MatjesSchule
//
//  Protocol und Extensions fuer CKRecord-Konvertierung aller Models.
//  Jedes Model kann sich in einen CKRecord umwandeln und aus einem CKRecord erstellt werden.
//

import Foundation
import CloudKit

// MARK: - Protocol

protocol CKRecordConvertible {
    static var recordType: String { get }
    var recordID: CKRecord.ID { get }
    func toCKRecord() -> CKRecord
    static func fromCKRecord(_ record: CKRecord) -> Self?
}

// MARK: - Ausbilder + CKRecord

extension Ausbilder: CKRecordConvertible {
    static var recordType: String { "Ausbilder" }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        record["name"] = name as CKRecordValue
        record["email"] = email as CKRecordValue
        record["schule"] = schule as CKRecordValue
        record["pinHash"] = pinHash as CKRecordValue
        record["erstelltAm"] = erstelltAm as CKRecordValue
        if let letzterLogin = letzterLogin {
            record["letzterLogin"] = letzterLogin as CKRecordValue
        }
        return record
    }

    static func fromCKRecord(_ record: CKRecord) -> Ausbilder? {
        guard record.recordType == recordType,
              let id = UUID(uuidString: record.recordID.recordName),
              let name = record["name"] as? String,
              let email = record["email"] as? String,
              let schule = record["schule"] as? String,
              let pinHash = record["pinHash"] as? String,
              let erstelltAm = record["erstelltAm"] as? Date
        else { return nil }

        return Ausbilder(
            id: id,
            name: name,
            email: email,
            schule: schule,
            pinHash: pinHash,
            erstelltAm: erstelltAm,
            letzterLogin: record["letzterLogin"] as? Date
        )
    }
}

// MARK: - Klasse + CKRecord

extension Klasse: CKRecordConvertible {
    static var recordType: String { "Klasse" }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        record["name"] = name as CKRecordValue
        record["ausbilderId"] = ausbilderId.uuidString as CKRecordValue
        record["lehrjahr"] = lehrjahr as CKRecordValue
        record["schuljahr"] = schuljahr as CKRecordValue
        record["erstelltAm"] = erstelltAm as CKRecordValue
        record["istAktiv"] = (istAktiv ? 1 : 0) as CKRecordValue
        return record
    }

    static func fromCKRecord(_ record: CKRecord) -> Klasse? {
        guard record.recordType == recordType,
              let id = UUID(uuidString: record.recordID.recordName),
              let name = record["name"] as? String,
              let ausbilderIdStr = record["ausbilderId"] as? String,
              let ausbilderId = UUID(uuidString: ausbilderIdStr),
              let lehrjahr = record["lehrjahr"] as? Int,
              let schuljahr = record["schuljahr"] as? String,
              let erstelltAm = record["erstelltAm"] as? Date
        else { return nil }

        let istAktiv = (record["istAktiv"] as? Int) == 1

        return Klasse(
            id: id,
            name: name,
            ausbilderId: ausbilderId,
            lehrjahr: lehrjahr,
            schuljahr: schuljahr,
            erstelltAm: erstelltAm,
            istAktiv: istAktiv
        )
    }
}

// MARK: - Schueler + CKRecord

extension Schueler: CKRecordConvertible {
    static var recordType: String { "Schueler" }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        record["vorname"] = vorname as CKRecordValue
        record["nachname"] = nachname as CKRecordValue
        record["klasseId"] = klasseId.uuidString as CKRecordValue
        record["einladungsCode"] = einladungsCode as CKRecordValue
        record["istAktiv"] = (istAktiv ? 1 : 0) as CKRecordValue
        record["erstelltAm"] = erstelltAm as CKRecordValue
        if let letzteAktivitaet = letzteAktivitaet {
            record["letzteAktivitaet"] = letzteAktivitaet as CKRecordValue
        }
        return record
    }

    static func fromCKRecord(_ record: CKRecord) -> Schueler? {
        guard record.recordType == recordType,
              let id = UUID(uuidString: record.recordID.recordName),
              let vorname = record["vorname"] as? String,
              let nachname = record["nachname"] as? String,
              let klasseIdStr = record["klasseId"] as? String,
              let klasseId = UUID(uuidString: klasseIdStr),
              let einladungsCode = record["einladungsCode"] as? String,
              let erstelltAm = record["erstelltAm"] as? Date
        else { return nil }

        let istAktiv = (record["istAktiv"] as? Int) == 1

        return Schueler(
            id: id,
            vorname: vorname,
            nachname: nachname,
            klasseId: klasseId,
            einladungsCode: einladungsCode,
            istAktiv: istAktiv,
            erstelltAm: erstelltAm,
            letzteAktivitaet: record["letzteAktivitaet"] as? Date
        )
    }
}

// MARK: - SchuelerFortschritt + CKRecord

extension SchuelerFortschritt: CKRecordConvertible {
    static var recordType: String { "SchuelerFortschritt" }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        let encoder = JSONEncoder()
        record["schuelerId"] = schuelerId.uuidString as CKRecordValue
        record["aktualisiertAm"] = aktualisiertAm as CKRecordValue

        // Dictionaries als JSON-Strings
        if let levelData = try? encoder.encode(levelFortschritte),
           let levelString = String(data: levelData, encoding: .utf8) {
            record["levelFortschritte"] = levelString as CKRecordValue
        }

        if let pruefData = try? encoder.encode(pruefungsErgebnisse),
           let pruefString = String(data: pruefData, encoding: .utf8) {
            record["pruefungsErgebnisse"] = pruefString as CKRecordValue
        }

        return record
    }

    static func fromCKRecord(_ record: CKRecord) -> SchuelerFortschritt? {
        guard record.recordType == recordType,
              let id = UUID(uuidString: record.recordID.recordName),
              let schuelerIdStr = record["schuelerId"] as? String,
              let schuelerId = UUID(uuidString: schuelerIdStr),
              let aktualisiertAm = record["aktualisiertAm"] as? Date
        else { return nil }

        let decoder = JSONDecoder()

        var levelFortschritte: [Int: LevelProgress] = [:]
        if let levelString = record["levelFortschritte"] as? String,
           let levelData = levelString.data(using: .utf8),
           let decoded = try? decoder.decode([Int: LevelProgress].self, from: levelData) {
            levelFortschritte = decoded
        }

        var pruefungsErgebnisse: [String: ExamResult] = [:]
        if let pruefString = record["pruefungsErgebnisse"] as? String,
           let pruefData = pruefString.data(using: .utf8),
           let decoded = try? decoder.decode([String: ExamResult].self, from: pruefData) {
            pruefungsErgebnisse = decoded
        }

        return SchuelerFortschritt(
            id: id,
            schuelerId: schuelerId,
            levelFortschritte: levelFortschritte,
            pruefungsErgebnisse: pruefungsErgebnisse,
            aktualisiertAm: aktualisiertAm
        )
    }

    /// Merge-Strategie: Behaelt die besten Ergebnisse aus beiden Versionen.
    func merged(with remote: SchuelerFortschritt) -> SchuelerFortschritt {
        var merged = self

        // Level-Fortschritte: Bestes Ergebnis behalten
        for (level, remoteProgress) in remote.levelFortschritte {
            if let localProgress = merged.levelFortschritte[level] {
                merged.levelFortschritte[level] = LevelProgress(
                    stars: max(localProgress.stars, remoteProgress.stars),
                    bestErrors: min(localProgress.bestErrors, remoteProgress.bestErrors),
                    lastPlayed: max(localProgress.lastPlayed ?? .distantPast,
                                    remoteProgress.lastPlayed ?? .distantPast)
                )
            } else {
                merged.levelFortschritte[level] = remoteProgress
            }
        }

        // Pruefungsergebnisse: Bestes Ergebnis behalten
        for (examId, remoteResult) in remote.pruefungsErgebnisse {
            if let localResult = merged.pruefungsErgebnisse[examId] {
                if remoteResult.percentage > localResult.percentage {
                    merged.pruefungsErgebnisse[examId] = remoteResult
                }
            } else {
                merged.pruefungsErgebnisse[examId] = remoteResult
            }
        }

        merged.aktualisiertAm = max(self.aktualisiertAm, remote.aktualisiertAm)
        return merged
    }
}

// MARK: - Fragenkatalog + CKRecord

extension Fragenkatalog: CKRecordConvertible {
    static var recordType: String { "Fragenkatalog" }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        record["name"] = name as CKRecordValue
        record["beschreibung"] = beschreibung as CKRecordValue
        record["ausbilderId"] = ausbilderId.uuidString as CKRecordValue
        record["erstelltAm"] = erstelltAm as CKRecordValue
        record["aktualisiertAm"] = aktualisiertAm as CKRecordValue
        record["istVeroeffentlicht"] = (istVeroeffentlicht ? 1 : 0) as CKRecordValue
        return record
    }

    static func fromCKRecord(_ record: CKRecord) -> Fragenkatalog? {
        guard record.recordType == recordType,
              let id = UUID(uuidString: record.recordID.recordName),
              let name = record["name"] as? String,
              let beschreibung = record["beschreibung"] as? String,
              let ausbilderIdStr = record["ausbilderId"] as? String,
              let ausbilderId = UUID(uuidString: ausbilderIdStr),
              let erstelltAm = record["erstelltAm"] as? Date,
              let aktualisiertAm = record["aktualisiertAm"] as? Date
        else { return nil }

        let istVeroeffentlicht = (record["istVeroeffentlicht"] as? Int) == 1

        return Fragenkatalog(
            id: id,
            name: name,
            beschreibung: beschreibung,
            ausbilderId: ausbilderId,
            erstelltAm: erstelltAm,
            aktualisiertAm: aktualisiertAm,
            istVeroeffentlicht: istVeroeffentlicht
        )
    }
}

// MARK: - AusbilderFrage + CKRecord

extension AusbilderFrage: CKRecordConvertible {
    static var recordType: String { "AusbilderFrage" }

    var recordID: CKRecord.ID {
        CKRecord.ID(recordName: id.uuidString)
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        record["katalogId"] = katalogId.uuidString as CKRecordValue
        record["text"] = text as CKRecordValue
        record["antworten"] = antworten as CKRecordValue
        record["korrekterIndex"] = korrekterIndex as CKRecordValue
        record["erklaerung"] = erklaerung as CKRecordValue
        record["erstelltAm"] = erstelltAm as CKRecordValue
        record["aktualisiertAm"] = aktualisiertAm as CKRecordValue
        if let level = level {
            record["level"] = level as CKRecordValue
        }
        return record
    }

    static func fromCKRecord(_ record: CKRecord) -> AusbilderFrage? {
        guard record.recordType == recordType,
              let id = UUID(uuidString: record.recordID.recordName),
              let katalogIdStr = record["katalogId"] as? String,
              let katalogId = UUID(uuidString: katalogIdStr),
              let text = record["text"] as? String,
              let antworten = record["antworten"] as? [String],
              let korrekterIndex = record["korrekterIndex"] as? Int,
              let erklaerung = record["erklaerung"] as? String,
              let erstelltAm = record["erstelltAm"] as? Date,
              let aktualisiertAm = record["aktualisiertAm"] as? Date
        else { return nil }

        return AusbilderFrage(
            id: id,
            katalogId: katalogId,
            text: text,
            antworten: antworten,
            korrekterIndex: korrekterIndex,
            erklaerung: erklaerung,
            level: record["level"] as? Int,
            erstelltAm: erstelltAm,
            aktualisiertAm: aktualisiertAm
        )
    }
}

// MARK: - Date max Helper

private func max(_ a: Date, _ b: Date) -> Date {
    a > b ? a : b
}
