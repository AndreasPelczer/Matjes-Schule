//
//  SchuelerCodeView.swift
//  MatjesSchule
//
//  Code-Eingabe fuer Schueler. Einmalig den 6-stelligen Code eingeben,
//  danach wird der Fortschritt dem Schueler zugeordnet.
//

import SwiftUI

struct SchuelerCodeView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var code = ""
    @State private var showError = false
    @State private var showErfolg = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [Color.blue.opacity(0.2), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    if let schueler = dataStore.aktuellerSchueler {
                        // Bereits angemeldet
                        angemeldetAnsicht(schueler: schueler)
                    } else {
                        // Code eingeben
                        codeEingabeAnsicht
                    }

                    Spacer()
                    Spacer()
                }
            }
            .navigationTitle("Mein Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func angemeldetAnsicht(schueler: Schueler) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Hallo, \(schueler.vorname)!")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)

            if let fortschritt = dataStore.fortschrittFuer(schuelerId: schueler.id) {
                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        StatBadge(wert: "\(fortschritt.gesamtSterne)", label: "Sterne", icon: "star.fill", farbe: .yellow)
                        StatBadge(wert: "Level \(fortschritt.hoechstesLevel)", label: "Erreicht", icon: "flag.fill", farbe: .blue)
                    }

                    Text("\(Int(fortschritt.fortschrittProzent))% Gesamtfortschritt")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 10)
            }

            Button(action: {
                dataStore.schuelerAbmelden()
            }) {
                Text("Abmelden")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.red.opacity(0.8))
            }
            .padding(.top, 20)
        }
    }

    private var codeEingabeAnsicht: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Einladungscode")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text("Gib den 6-stelligen Code ein, den du von deinem Ausbilder bekommen hast.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            TextField("Code eingeben", text: $code)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 220)
                .multilineTextAlignment(.center)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .onChange(of: code) { _, newValue in
                    code = String(newValue.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(6))
                }

            Button(action: codeEinloesen) {
                Text("Code best\u{00E4}tigen")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: 220, minHeight: 50)
                    .background(code.count == 6 ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(code.count != 6)

            if showError {
                Text("Code nicht gefunden. Frag deinen Ausbilder.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.red)
            }

            if showErfolg {
                Text("Willkommen! Dein Fortschritt wird jetzt gespeichert.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.green)
            }
        }
    }

    private func codeEinloesen() {
        showError = false
        showErfolg = false

        if dataStore.schuelerAnmelden(code: code) != nil {
            showErfolg = true
        } else {
            showError = true
            code = ""
        }
    }
}

struct StatBadge: View {
    let wert: String
    let label: String
    let icon: String
    let farbe: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(farbe)
            Text(wert)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(width: 100, height: 90)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
    }
}
