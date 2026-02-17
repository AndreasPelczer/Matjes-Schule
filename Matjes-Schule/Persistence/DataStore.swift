//
//  DataStore.swift
//  MatjesSchule
//
//  Zentrale Persistenz fuer Ausbilder, Klassen, Schueler und Fortschritte.
//  Speichert als JSON in UserDefaults (Phase 3).
//  Wird in Phase 4 durch CloudKit-Sync ergaenzt.
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

    // MARK: - Ausbilder

    func registriereAusbilder(name: String, email: String, schule: String, pin: String) -> Ausbilder {
        let pinHash = AusbilderAuthentication.hashPIN(pin)
        let neuerAusbilder = Ausbilder(name: name, email: email, schule: schule, pinHash: pinHash)
        ausbilder = neuerAusbilder
        speichere(neuerAusbilder, key: Keys.ausbilder)
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
        return aktualisiert
    }

    func ausbilderBiometricLogin() -> Ausbilder? {
        guard var gespeicherterAusbilder = ausbilder else { return nil }
        gespeicherterAusbilder.letzterLogin = Date()
        ausbilder = gespeicherterAusbilder
        speichere(gespeicherterAusbilder, key: Keys.ausbilder)
        return gespeicherterAusbilder
    }

    func aktualisiereAusbilder(_ aktualisiert: Ausbilder) {
        ausbilder = aktualisiert
        speichere(aktualisiert, key: Keys.ausbilder)
    }

    // MARK: - Klassen

    func erstelleKlasse(name: String, lehrjahr: Int, schuljahr: String) -> Klasse? {
        guard let ausbilderId = ausbilder?.id else { return nil }
        let klasse = Klasse(name: name, ausbilderId: ausbilderId, lehrjahr: lehrjahr, schuljahr: schuljahr)
        klassen.append(klasse)
        speichere(klassen, key: Keys.klassen)
        return klasse
    }

    func loescheKlasse(_ klasse: Klasse) {
        // Schueler dieser Klasse auch entfernen
        schueler.removeAll { $0.klasseId == klasse.id }
        fortschritte.removeAll { fortschritt in
            schueler.contains { $0.id == fortschritt.schuelerId }
        }
        klassen.removeAll { $0.id == klasse.id }
        speichere(klassen, key: Keys.klassen)
        speichere(schueler, key: Keys.schueler)
        speichere(fortschritte, key: Keys.fortschritte)
    }

    func aktualisiereKlasse(_ aktualisiert: Klasse) {
        if let index = klassen.firstIndex(where: { $0.id == aktualisiert.id }) {
            klassen[index] = aktualisiert
            speichere(klassen, key: Keys.klassen)
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

        return neuerSchueler
    }

    func loescheSchueler(_ zuLoeschen: Schueler) {
        fortschritte.removeAll { $0.schuelerId == zuLoeschen.id }
        schueler.removeAll { $0.id == zuLoeschen.id }
        speichere(schueler, key: Keys.schueler)
        speichere(fortschritte, key: Keys.fortschritte)
    }

    func schuelerInKlasse(_ klasseId: UUID) -> [Schueler] {
        schueler.filter { $0.klasseId == klasseId && $0.istAktiv }
    }

    func schuelerMitCode(_ code: String) -> Schueler? {
        schueler.first { $0.einladungsCode.uppercased() == code.uppercased() && $0.istAktiv }
    }

    // MARK: - Schueler-Geraet (Code-Eingabe)

    func schuelerAnmelden(code: String) -> Schueler? {
        guard let gefunden = schuelerMitCode(code) else { return nil }
        aktuellerSchueler = gefunden
        UserDefaults.standard.set(gefunden.id.uuidString, forKey: Keys.aktuellerSchuelerId)
        return gefunden
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
    }

    // MARK: - Fragenkataloge

    func erstelleKatalog(name: String, beschreibung: String) -> Fragenkatalog? {
        guard let ausbilderId = ausbilder?.id else { return nil }
        let katalog = Fragenkatalog(name: name, beschreibung: beschreibung, ausbilderId: ausbilderId)
        fragenkataloge.append(katalog)
        speichere(fragenkataloge, key: Keys.fragenkataloge)
        return katalog
    }

    func loescheKatalog(_ katalog: Fragenkatalog) {
        ausbilderFragen.removeAll { $0.katalogId == katalog.id }
        fragenkataloge.removeAll { $0.id == katalog.id }
        speichere(fragenkataloge, key: Keys.fragenkataloge)
        speichere(ausbilderFragen, key: Keys.ausbilderFragen)
    }

    func fragenInKatalog(_ katalogId: UUID) -> [AusbilderFrage] {
        ausbilderFragen.filter { $0.katalogId == katalogId }
    }

    func erstelleFrage(katalogId: UUID, text: String, antworten: [String], korrekterIndex: Int, erklaerung: String, level: Int? = nil) -> AusbilderFrage {
        let frage = AusbilderFrage(katalogId: katalogId, text: text, antworten: antworten, korrekterIndex: korrekterIndex, erklaerung: erklaerung, level: level)
        ausbilderFragen.append(frage)
        speichere(ausbilderFragen, key: Keys.ausbilderFragen)
        return frage
    }

    func loescheFrage(_ frage: AusbilderFrage) {
        ausbilderFragen.removeAll { $0.id == frage.id }
        speichere(ausbilderFragen, key: Keys.ausbilderFragen)
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
}
