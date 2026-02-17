//
//  DataStore.swift
//  MatjesSchule
//
//  Zentrale Persistenz fuer Ausbilder, Klassen, Schueler und Fortschritte.
//  Speichert als JSON in UserDefaults (lokal).
//  CloudKit-Sync: Lokal speichern, dann im Hintergrund zu CloudKit pushen.
//  Offline-faehig: Bei fehlender Verbindung werden Aenderungen gequeued.
//

import Foundation
import Combine

class DataStore: ObservableObject {
    static let shared = DataStore()

    // MARK: - Published Data

    @Published var ausbilder: Ausbilder?
    @Published var klassen: [Klasse] = []
    @Published var schueler: [Schueler] = []
    @Published var fortschritte: [SchuelerFortschritt] = []
    @Published var fragenkataloge: [Fragenkatalog] = []
    @Published var ausbilderFragen: [AusbilderFrage] = []

    // Schueler-Modus: Welcher Schueler ist auf diesem Geraet aktiv?
    @Published var aktuellerSchueler: Schueler?

    // CloudKit Sync Status
    @Published var isSyncing: Bool = false

    // MARK: - CloudKit

    private let cloudKit = CloudKitManager.shared
    private let syncState = SyncState.shared

    // MARK: - Storage Keys

    private enum Keys {
        static let ausbilder = "MatjesSchule_Ausbilder"
        static let klassen = "MatjesSchule_Klassen"
        static let schueler = "MatjesSchule_Schueler"
        static let fortschritte = "MatjesSchule_Fortschritte"
        static let fragenkataloge = "MatjesSchule_Fragenkataloge"
        static let ausbilderFragen = "MatjesSchule_AusbilderFragen"
        static let aktuellerSchuelerId = "MatjesSchule_AktuellerSchuelerId"
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Init

    init() {
        ladeAlles()
    }

    // MARK: - Laden

    func ladeAlles() {
        ausbilder = lade(key: Keys.ausbilder)
        klassen = lade(key: Keys.klassen) ?? []
        schueler = lade(key: Keys.schueler) ?? []
        fortschritte = lade(key: Keys.fortschritte) ?? []
        fragenkataloge = lade(key: Keys.fragenkataloge) ?? []
        ausbilderFragen = lade(key: Keys.ausbilderFragen) ?? []

        // Aktuellen Schueler wiederherstellen
        if let schuelerId = UserDefaults.standard.string(forKey: Keys.aktuellerSchuelerId),
           let uuid = UUID(uuidString: schuelerId) {
            aktuellerSchueler = schueler.first { $0.id == uuid }
        }
    }

    private func lade<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? decoder.decode(T.self, from: data)
        else { return nil }
        return decoded
    }

    private func speichere<T: Codable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: - CloudKit Sync Helper

    /// Startet einen CloudKit-Sync im Hintergrund. Fehlschlaege werden still gequeued.
    private func syncImHintergrund<T: CKRecordConvertible>(_ item: T) {
        Task {
            try? await cloudKit.save(item)
        }
    }

    private func deleteImHintergrund<T: CKRecordConvertible>(_ item: T) {
        Task {
            try? await cloudKit.delete(item)
        }
    }

    // MARK: - Ausbilder

    func registriereAusbilder(name: String, email: String, schule: String, pin: String) -> Ausbilder {
        let pinHash = AusbilderAuthentication.hashPIN(pin)
        let neuerAusbilder = Ausbilder(name: name, email: email, schule: schule, pinHash: pinHash)
        ausbilder = neuerAusbilder
        speichere(neuerAusbilder, key: Keys.ausbilder)
        syncImHintergrund(neuerAusbilder)
        return neuerAusbilder
    }

    func ausbilderLogin(pin: String) -> Ausbilder? {
        guard let gespeicherterAusbilder = ausbilder else { return nil }
        let pinHash = AusbilderAuthentication.hashPIN(pin)
        guard pinHash == gespeicherterAusbilder.pinHash else { return nil }
        var aktualisiert = gespeicherterAusbilder
        aktualisiert.letzterLogin = Date()
        ausbilder = aktualisiert
        speichere(aktualisiert, key: Keys.ausbilder)
        syncImHintergrund(aktualisiert)
        return aktualisiert
    }

    func ausbilderBiometricLogin() -> Ausbilder? {
        guard var gespeicherterAusbilder = ausbilder else { return nil }
        gespeicherterAusbilder.letzterLogin = Date()
        ausbilder = gespeicherterAusbilder
        speichere(gespeicherterAusbilder, key: Keys.ausbilder)
        syncImHintergrund(gespeicherterAusbilder)
        return gespeicherterAusbilder
    }

    func aktualisiereAusbilder(_ aktualisiert: Ausbilder) {
        ausbilder = aktualisiert
        speichere(aktualisiert, key: Keys.ausbilder)
        syncImHintergrund(aktualisiert)
    }

    // MARK: - Klassen

    func erstelleKlasse(name: String, lehrjahr: Int, schuljahr: String) -> Klasse? {
        guard let ausbilderId = ausbilder?.id else { return nil }
        let klasse = Klasse(name: name, ausbilderId: ausbilderId, lehrjahr: lehrjahr, schuljahr: schuljahr)
        klassen.append(klasse)
        speichere(klassen, key: Keys.klassen)
        syncImHintergrund(klasse)
        return klasse
    }

    func loescheKlasse(_ klasse: Klasse) {
        // Schueler und Fortschritte dieser Klasse sammeln fuer CloudKit-Delete
        let zuLoeschendeSchueler = schueler.filter { $0.klasseId == klasse.id }
        let zuLoeschendeFortschritte = fortschritte.filter { fortschritt in
            zuLoeschendeSchueler.contains { $0.id == fortschritt.schuelerId }
        }

        // Lokal loeschen
        schueler.removeAll { $0.klasseId == klasse.id }
        fortschritte.removeAll { fortschritt in
            zuLoeschendeSchueler.contains { $0.id == fortschritt.schuelerId }
        }
        klassen.removeAll { $0.id == klasse.id }
        speichere(klassen, key: Keys.klassen)
        speichere(schueler, key: Keys.schueler)
        speichere(fortschritte, key: Keys.fortschritte)

        // CloudKit: Loeschen im Hintergrund
        for s in zuLoeschendeSchueler { deleteImHintergrund(s) }
        for f in zuLoeschendeFortschritte { deleteImHintergrund(f) }
        deleteImHintergrund(klasse)
    }

    func aktualisiereKlasse(_ aktualisiert: Klasse) {
        if let index = klassen.firstIndex(where: { $0.id == aktualisiert.id }) {
            klassen[index] = aktualisiert
            speichere(klassen, key: Keys.klassen)
            syncImHintergrund(aktualisiert)
        }
    }

    func klassenFuerAusbilder() -> [Klasse] {
        guard let ausbilderId = ausbilder?.id else { return [] }
        return klassen.filter { $0.ausbilderId == ausbilderId && $0.istAktiv }
    }

    // MARK: - Schueler

    func erstelleSchueler(vorname: String, nachname: String, klasseId: UUID) -> Schueler {
        let neuerSchueler = Schueler(vorname: vorname, nachname: nachname, klasseId: klasseId)
        schueler.append(neuerSchueler)
        speichere(schueler, key: Keys.schueler)

        // Fortschritt anlegen
        let fortschritt = SchuelerFortschritt(schuelerId: neuerSchueler.id)
        fortschritte.append(fortschritt)
        speichere(fortschritte, key: Keys.fortschritte)

        // CloudKit
        syncImHintergrund(neuerSchueler)
        syncImHintergrund(fortschritt)

        return neuerSchueler
    }

    func loescheSchueler(_ zuLoeschen: Schueler) {
        let zuLoeschendeFortschritte = fortschritte.filter { $0.schuelerId == zuLoeschen.id }

        fortschritte.removeAll { $0.schuelerId == zuLoeschen.id }
        schueler.removeAll { $0.id == zuLoeschen.id }
        speichere(schueler, key: Keys.schueler)
        speichere(fortschritte, key: Keys.fortschritte)

        // CloudKit
        for f in zuLoeschendeFortschritte { deleteImHintergrund(f) }
        deleteImHintergrund(zuLoeschen)
    }

    func schuelerInKlasse(_ klasseId: UUID) -> [Schueler] {
        schueler.filter { $0.klasseId == klasseId && $0.istAktiv }
    }

    func schuelerMitCode(_ code: String) -> Schueler? {
        schueler.first { $0.einladungsCode.uppercased() == code.uppercased() && $0.istAktiv }
    }

    // MARK: - Schueler-Geraet (Code-Eingabe)

    func schuelerAnmelden(code: String) -> Schueler? {
        // Erst lokal suchen
        if let gefunden = schuelerMitCode(code) {
            aktuellerSchueler = gefunden
            UserDefaults.standard.set(gefunden.id.uuidString, forKey: Keys.aktuellerSchuelerId)
            return gefunden
        }
        return nil
    }

    /// Schueler-Anmeldung mit CloudKit-Suche falls lokal nicht gefunden.
    func schuelerAnmeldenMitCloudKit(code: String) async -> Schueler? {
        // Erst lokal suchen
        if let gefunden = schuelerMitCode(code) {
            await MainActor.run {
                aktuellerSchueler = gefunden
                UserDefaults.standard.set(gefunden.id.uuidString, forKey: Keys.aktuellerSchuelerId)
            }
            return gefunden
        }

        // Dann in CloudKit suchen
        guard let remote = try? await cloudKit.schuelerMitCode(code) else { return nil }

        // Remote-Schueler lokal speichern
        await MainActor.run {
            if !schueler.contains(where: { $0.id == remote.id }) {
                schueler.append(remote)
                speichere(schueler, key: Keys.schueler)
            }

            // Fortschritt anlegen falls nicht vorhanden
            if !fortschritte.contains(where: { $0.schuelerId == remote.id }) {
                let fortschritt = SchuelerFortschritt(schuelerId: remote.id)
                fortschritte.append(fortschritt)
                speichere(fortschritte, key: Keys.fortschritte)
            }

            aktuellerSchueler = remote
            UserDefaults.standard.set(remote.id.uuidString, forKey: Keys.aktuellerSchuelerId)
        }

        return remote
    }

    func schuelerAbmelden() {
        aktuellerSchueler = nil
        UserDefaults.standard.removeObject(forKey: Keys.aktuellerSchuelerId)
    }

    // MARK: - Fortschritte

    func fortschrittFuer(schuelerId: UUID) -> SchuelerFortschritt? {
        fortschritte.first { $0.schuelerId == schuelerId }
    }

    func aktualisiereFortschritt(schuelerId: UUID, level: Int, errors: Int) {
        guard let index = fortschritte.firstIndex(where: { $0.schuelerId == schuelerId }) else { return }

        let newStars = LevelProgress.starsForErrors(errors)
        let existing = fortschritte[index].levelFortschritte[level]

        if let existing = existing {
            if newStars > existing.stars || errors < existing.bestErrors {
                fortschritte[index].levelFortschritte[level] = LevelProgress(
                    stars: max(newStars, existing.stars),
                    bestErrors: min(errors, existing.bestErrors),
                    lastPlayed: Date()
                )
            } else {
                fortschritte[index].levelFortschritte[level]?.lastPlayed = Date()
            }
        } else {
            fortschritte[index].levelFortschritte[level] = LevelProgress(
                stars: newStars,
                bestErrors: errors,
                lastPlayed: Date()
            )
        }

        fortschritte[index].aktualisiertAm = Date()
        speichere(fortschritte, key: Keys.fortschritte)

        // Schueler-Aktivitaet aktualisieren
        if let sIndex = schueler.firstIndex(where: { $0.id == schuelerId }) {
            schueler[sIndex].letzteAktivitaet = Date()
            speichere(schueler, key: Keys.schueler)
        }

        // CloudKit: Fortschritt mit Merge-Strategie syncen
        let fortschritt = fortschritte[index]
        Task {
            if let merged = try? await cloudKit.saveFortschrittMitMerge(fortschritt) {
                await MainActor.run {
                    if let idx = self.fortschritte.firstIndex(where: { $0.id == merged.id }) {
                        self.fortschritte[idx] = merged
                        self.speichere(self.fortschritte, key: Keys.fortschritte)
                    }
                }
            }
        }
    }

    func speicherePruefungsergebnis(schuelerId: UUID, examId: String, result: ExamResult) {
        guard let index = fortschritte.firstIndex(where: { $0.schuelerId == schuelerId }) else { return }

        if let existing = fortschritte[index].pruefungsErgebnisse[examId] {
            if result.percentage > existing.percentage {
                fortschritte[index].pruefungsErgebnisse[examId] = result
            }
        } else {
            fortschritte[index].pruefungsErgebnisse[examId] = result
        }

        fortschritte[index].aktualisiertAm = Date()
        speichere(fortschritte, key: Keys.fortschritte)

        // CloudKit: Fortschritt syncen
        let fortschritt = fortschritte[index]
        Task {
            if let merged = try? await cloudKit.saveFortschrittMitMerge(fortschritt) {
                await MainActor.run {
                    if let idx = self.fortschritte.firstIndex(where: { $0.id == merged.id }) {
                        self.fortschritte[idx] = merged
                        self.speichere(self.fortschritte, key: Keys.fortschritte)
                    }
                }
            }
        }
    }

    // MARK: - Fragenkataloge

    func erstelleKatalog(name: String, beschreibung: String) -> Fragenkatalog? {
        guard let ausbilderId = ausbilder?.id else { return nil }
        let katalog = Fragenkatalog(name: name, beschreibung: beschreibung, ausbilderId: ausbilderId)
        fragenkataloge.append(katalog)
        speichere(fragenkataloge, key: Keys.fragenkataloge)
        syncImHintergrund(katalog)
        return katalog
    }

    func loescheKatalog(_ katalog: Fragenkatalog) {
        let zuLoeschendeFragen = ausbilderFragen.filter { $0.katalogId == katalog.id }

        ausbilderFragen.removeAll { $0.katalogId == katalog.id }
        fragenkataloge.removeAll { $0.id == katalog.id }
        speichere(fragenkataloge, key: Keys.fragenkataloge)
        speichere(ausbilderFragen, key: Keys.ausbilderFragen)

        // CloudKit
        for f in zuLoeschendeFragen { deleteImHintergrund(f) }
        deleteImHintergrund(katalog)
    }

    func fragenInKatalog(_ katalogId: UUID) -> [AusbilderFrage] {
        ausbilderFragen.filter { $0.katalogId == katalogId }
    }

    func erstelleFrage(katalogId: UUID, text: String, antworten: [String], korrekterIndex: Int, erklaerung: String, level: Int? = nil) -> AusbilderFrage {
        let frage = AusbilderFrage(katalogId: katalogId, text: text, antworten: antworten, korrekterIndex: korrekterIndex, erklaerung: erklaerung, level: level)
        ausbilderFragen.append(frage)
        speichere(ausbilderFragen, key: Keys.ausbilderFragen)
        syncImHintergrund(frage)
        return frage
    }

    func loescheFrage(_ frage: AusbilderFrage) {
        ausbilderFragen.removeAll { $0.id == frage.id }
        speichere(ausbilderFragen, key: Keys.ausbilderFragen)
        deleteImHintergrund(frage)
    }

    // MARK: - Dashboard-Statistiken

    func gesamtSchuelerAnzahl() -> Int {
        guard let ausbilderId = ausbilder?.id else { return 0 }
        let meineKlassenIds = klassen.filter { $0.ausbilderId == ausbilderId && $0.istAktiv }.map { $0.id }
        return schueler.filter { meineKlassenIds.contains($0.klasseId) && $0.istAktiv }.count
    }

    func durchschnittsFortschritt() -> Double {
        guard let ausbilderId = ausbilder?.id else { return 0 }
        let meineKlassenIds = klassen.filter { $0.ausbilderId == ausbilderId && $0.istAktiv }.map { $0.id }
        let meineSchuelerIds = schueler.filter { meineKlassenIds.contains($0.klasseId) && $0.istAktiv }.map { $0.id }
        let meineFortschritte = fortschritte.filter { meineSchuelerIds.contains($0.schuelerId) }
        guard !meineFortschritte.isEmpty else { return 0 }
        let summe = meineFortschritte.reduce(0.0) { $0 + $1.fortschrittProzent }
        return summe / Double(meineFortschritte.count)
    }

    // MARK: - CloudKit Sync

    /// Vollstaendiger Sync: Pusht lokale Daten und holt Remote-Aenderungen.
    /// Wird beim App-Start und manuell aufgerufen.
    func syncMitCloudKit() async {
        await MainActor.run { isSyncing = true }

        // Account pruefen
        await cloudKit.pruefeAccount()
        guard cloudKit.isAvailable else {
            await MainActor.run { isSyncing = false }
            return
        }

        // Ausstehende Operationen verarbeiten
        await cloudKit.verarbeitePending(dataStore: self)

        // Modus-abhaengiger Sync
        if let ausbilder = ausbilder {
            await syncAusbilderDaten(ausbilder)
        } else if let schueler = aktuellerSchueler {
            await syncSchuelerDaten(schueler)
        }

        await MainActor.run { isSyncing = false }
    }

    private func syncAusbilderDaten(_ ausbilder: Ausbilder) async {
        do {
            let ergebnis = try await cloudKit.syncAllesAusbilder(
                ausbilder: ausbilder,
                klassen: klassen,
                schueler: schueler,
                fortschritte: fortschritte,
                fragenkataloge: fragenkataloge,
                ausbilderFragen: ausbilderFragen
            )

            // Remote-Fortschritte lokal mergen
            await MainActor.run {
                for remoteFortschritt in ergebnis.remoteFortschritte {
                    if let index = fortschritte.firstIndex(where: { $0.schuelerId == remoteFortschritt.schuelerId }) {
                        let merged = fortschritte[index].merged(with: remoteFortschritt)
                        fortschritte[index] = merged
                    } else {
                        fortschritte.append(remoteFortschritt)
                    }
                }
                speichere(fortschritte, key: Keys.fortschritte)

                // Remote-Schueler lokal mergen (falls neue Schueler ueber andere Geraete hinzugefuegt)
                for remoteSchueler in ergebnis.remoteSchueler {
                    if !schueler.contains(where: { $0.id == remoteSchueler.id }) {
                        schueler.append(remoteSchueler)
                    }
                }
                speichere(schueler, key: Keys.schueler)
            }
        } catch {
            // Sync-Fehler werden in SyncState getrackt, App funktioniert weiter lokal
        }
    }

    private func syncSchuelerDaten(_ schueler: Schueler) async {
        guard let fortschritt = fortschrittFuer(schuelerId: schueler.id) else { return }
        do {
            let merged = try await cloudKit.syncSchuelerFortschritt(
                schueler: schueler,
                fortschritt: fortschritt
            )
            await MainActor.run {
                if let index = self.fortschritte.firstIndex(where: { $0.id == merged.id }) {
                    self.fortschritte[index] = merged
                    self.speichere(self.fortschritte, key: Keys.fortschritte)
                }
            }
        } catch {
            // Sync-Fehler werden in SyncState getrackt
        }
    }
}
