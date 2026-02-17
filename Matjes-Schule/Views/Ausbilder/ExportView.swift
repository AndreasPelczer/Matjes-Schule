//
//  ExportView.swift
//  MatjesSchule
//
//  Export-View fuer Fortschrittsberichte und Zertifikate (Phase 5).
//  Ausbilder koennen hier PDF-Berichte generieren und per Share-Sheet teilen.
//

import SwiftUI
import PDFKit

struct ExportView: View {
    let klasse: Klasse
    @EnvironmentObject var dataStore: DataStore

    @State private var generiertePDF: Data?
    @State private var pdfURL: URL?
    @State private var zeigeShare = false
    @State private var exportTyp: ExportTyp = .klassenuebersicht
    @State private var ausgewaehlterSchueler: Schueler?
    @State private var zeigePDFVorschau = false

    enum ExportTyp: String, CaseIterable {
        case klassenuebersicht = "Klassen\u{00FC}bersicht"
        case schuelerBericht = "Sch\u{00FC}ler-Bericht"
        case zertifikat = "Zertifikat"
    }

    private var schuelerInKlasse: [Schueler] {
        dataStore.schuelerInKlasse(klasse.id)
    }

    private var fortschritteDict: [UUID: SchuelerFortschritt] {
        var dict: [UUID: SchuelerFortschritt] = [:]
        for s in schuelerInKlasse {
            if let f = dataStore.fortschrittFuer(schuelerId: s.id) {
                dict[s.id] = f
            }
        }
        return dict
    }

    var body: some View {
        List {
            // Export-Typ Auswahl
            Section {
                Picker("Bericht-Typ", selection: $exportTyp) {
                    ForEach(ExportTyp.allCases, id: \.self) { typ in
                        Text(typ.rawValue).tag(typ)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Export-Typ")
            }

            // Typ-spezifische Optionen
            switch exportTyp {
            case .klassenuebersicht:
                klassenUebersichtSection

            case .schuelerBericht:
                schuelerAuswahlSection

            case .zertifikat:
                zertifikatSection
            }

            // PDF-Vorschau
            if let pdfData = generiertePDF {
                Section {
                    pdfVorschauView(data: pdfData)
                        .frame(height: 400)
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text("Vorschau")
                }

                // Teilen-Button
                Section {
                    if let url = pdfURL {
                        ShareLink(item: url) {
                            Label("PDF teilen", systemImage: "square.and.arrow.up")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Klassenuebersicht

    private var klassenUebersichtSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Klasse: \(klasse.name)")
                Text("Sch\u{00FC}ler: \(schuelerInKlasse.count)")
                    .foregroundColor(.secondary)
            }

            Button {
                generiereKlassenPDF()
            } label: {
                Label("Klassen\u{00FC}bersicht generieren", systemImage: "doc.text")
                    .foregroundColor(.orange)
            }
        } header: {
            Text("Klassen\u{00FC}bersicht als PDF")
        } footer: {
            Text("Erstellt eine \u{00DC}bersicht aller Sch\u{00FC}ler mit Fortschritt, Sternen und Schwachstellen.")
        }
    }

    // MARK: - Schueler-Bericht

    private var schuelerAuswahlSection: some View {
        Section {
            if schuelerInKlasse.isEmpty {
                Text("Keine Sch\u{00FC}ler in dieser Klasse")
                    .foregroundColor(.secondary)
            } else {
                ForEach(schuelerInKlasse.sorted { $0.nachname < $1.nachname }) { s in
                    Button {
                        ausgewaehlterSchueler = s
                        generiereSchuelerPDF(schueler: s)
                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text(s.vollstaendigerName)
                                    .foregroundColor(.primary)
                                if let f = fortschritteDict[s.id] {
                                    Text("\(String(format: "%.0f", f.fortschrittProzent))% \u{00B7} \(f.gesamtSterne) Sterne")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            if ausgewaehlterSchueler?.id == s.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
        } header: {
            Text("Sch\u{00FC}ler ausw\u{00E4}hlen")
        } footer: {
            Text("W\u{00E4}hle einen Sch\u{00FC}ler, um dessen Fortschrittsbericht als PDF zu generieren.")
        }
    }

    // MARK: - Zertifikat

    private var zertifikatSection: some View {
        Section {
            let schuelerMitPruefung = schuelerInKlasse.filter { s in
                guard let f = fortschritteDict[s.id] else { return false }
                return f.pruefungsErgebnisse.values.contains { $0.passed }
            }.sorted { $0.nachname < $1.nachname }

            if schuelerMitPruefung.isEmpty {
                Text("Noch kein Sch\u{00FC}ler hat eine Pr\u{00FC}fung bestanden.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(schuelerMitPruefung) { s in
                    let fortschritt = fortschritteDict[s.id]
                    VStack(alignment: .leading, spacing: 6) {
                        Text(s.vollstaendigerName)
                            .font(.headline)

                        if let commis = fortschritt?.pruefungsErgebnisse["commis"], commis.passed {
                            Button {
                                generiereZertifikat(schueler: s, typ: "commis", ergebnis: commis)
                            } label: {
                                Label("Commis-Zertifikat", systemImage: "rosette")
                                    .foregroundColor(.orange)
                            }
                        }

                        if let boss = fortschritt?.pruefungsErgebnisse["bossfight"], boss.passed {
                            Button {
                                generiereZertifikat(schueler: s, typ: "bossfight", ergebnis: boss)
                            } label: {
                                Label("Abschluss-Zertifikat", systemImage: "star.circle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        } header: {
            Text("Zertifikate f\u{00FC}r bestandene Pr\u{00FC}fungen")
        } footer: {
            Text("Erstellt ein druckbares Zertifikat f\u{00FC}r Sch\u{00FC}ler, die eine Pr\u{00FC}fung bestanden haben.")
        }
    }

    // MARK: - PDF Vorschau

    private func pdfVorschauView(data: Data) -> some View {
        PDFKitPreview(data: data)
    }

    // MARK: - Generierung

    private func generiereKlassenPDF() {
        let data = FortschrittsExporter.generiereKlassenUebersichtPDF(
            klasse: klasse,
            schueler: schuelerInKlasse,
            fortschritte: fortschritteDict
        )
        generiertePDF = data
        pdfURL = FortschrittsExporter.speicherePDFTemp(
            data: data,
            dateiname: "Klassenuebersicht_\(klasse.name).pdf"
        )
    }

    private func generiereSchuelerPDF(schueler: Schueler) {
        guard let fortschritt = fortschritteDict[schueler.id] else { return }
        let data = FortschrittsExporter.generiereSchuelerBerichtPDF(
            schueler: schueler,
            fortschritt: fortschritt,
            klasse: klasse
        )
        generiertePDF = data
        pdfURL = FortschrittsExporter.speicherePDFTemp(
            data: data,
            dateiname: "Bericht_\(schueler.vollstaendigerName).pdf"
        )
    }

    private func generiereZertifikat(schueler: Schueler, typ: String, ergebnis: ExamResult) {
        guard let data = FortschrittsExporter.generiereZertifikatPDF(
            schueler: schueler,
            klasse: klasse,
            pruefungsTyp: typ,
            ergebnis: ergebnis
        ) else { return }
        generiertePDF = data
        let typName = typ == "bossfight" ? "Abschluss" : "Commis"
        pdfURL = FortschrittsExporter.speicherePDFTemp(
            data: data,
            dateiname: "Zertifikat_\(typName)_\(schueler.vollstaendigerName).pdf"
        )
    }
}

// MARK: - PDFKit Vorschau (inline, aus Data)

struct PDFKitPreview: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = PDFDocument(data: data)
    }
}
