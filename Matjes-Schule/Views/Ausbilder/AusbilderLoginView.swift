//
//  AusbilderLoginView.swift
//  MatjesSchule
//
//  Login-Screen fuer Ausbilder (PIN + Biometrie)
//  Enthalt auch Erstregistrierung.
//

import SwiftUI

struct AusbilderLoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @State private var pin: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showRegistrierung = false

    private var hatGespeichertenAusbilder: Bool {
        dataStore.ausbilder != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)

                    Text("Ausbilder-Login")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text(hatGespeichertenAusbilder
                         ? "Melde dich an, um Klassen und Fortschritte zu verwalten."
                         : "Erstelle dein Ausbilder-Profil, um loszulegen.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    if hatGespeichertenAusbilder {
                        // Login-Ansicht
                        loginAnsicht
                    } else {
                        // Registrierungs-Button
                        Button(action: { showRegistrierung = true }) {
                            Label("Profil erstellen", systemImage: "person.crop.circle.badge.plus")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: 280, minHeight: 50)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }

                    if showError {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                            .padding(.horizontal, 40)
                    }

                    Spacer()
                    Spacer()
                }
            }
            .navigationTitle("Ausbilder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showRegistrierung) {
                AusbilderRegistrierungView()
                    .environmentObject(appState)
                    .environmentObject(dataStore)
            }
        }
    }

    private var loginAnsicht: some View {
        VStack(spacing: 16) {
            if let ausbilder = dataStore.ausbilder {
                Text(ausbilder.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }

            SecureField("4-stellige PIN", text: $pin)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .onChange(of: pin) { _, newValue in
                    // Nur Ziffern, max 4
                    pin = String(newValue.filter { $0.isNumber }.prefix(4))
                }

            Button(action: loginMitPIN) {
                Text("Anmelden")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: 200, minHeight: 50)
                    .background(pin.count == 4 ? Color.orange : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(pin.count != 4)

            if AusbilderAuthentication.isBiometricAvailable {
                Button(action: loginMitBiometrie) {
                    Label("Mit Face ID / Touch ID", systemImage: "faceid")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.top, 20)
    }

    private func loginMitPIN() {
        showError = false
        guard let ausbilder = dataStore.ausbilderLogin(pin: pin) else {
            errorMessage = "PIN stimmt nicht ueberein"
            showError = true
            pin = ""
            return
        }
        appState.ausbilderAnmelden(ausbilder)
    }

    private func loginMitBiometrie() {
        Task {
            do {
                let ausbilderId = dataStore.ausbilder?.id.uuidString ?? "unknown"
                _ = try await AusbilderAuthentication.authenticate(ausbilderId: ausbilderId)
                await MainActor.run {
                    guard let ausbilder = dataStore.ausbilderBiometricLogin() else {
                        errorMessage = "Ausbilder-Profil nicht gefunden"
                        showError = true
                        return
                    }
                    appState.ausbilderAnmelden(ausbilder)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Registrierungs-Sheet

struct AusbilderRegistrierungView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var schule = ""
    @State private var pin = ""
    @State private var pinBestaetigung = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .padding(.top, 20)

                        Text("Ausbilder-Profil erstellen")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        VStack(spacing: 16) {
                            profilFeld(titel: "Name", text: $name, placeholder: "Max Mustermann")
                            profilFeld(titel: "E-Mail", text: $email, placeholder: "max@berufsschule.de")
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            profilFeld(titel: "Schule / Betrieb", text: $schule, placeholder: "Berufsschule Musterstadt")
                        }

                        Divider().background(Color.white.opacity(0.2))

                        VStack(spacing: 16) {
                            Text("4-stellige PIN festlegen")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            SecureField("PIN", text: $pin)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 200)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .onChange(of: pin) { _, newValue in
                                    pin = String(newValue.filter { $0.isNumber }.prefix(4))
                                }

                            SecureField("PIN wiederholen", text: $pinBestaetigung)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 200)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .onChange(of: pinBestaetigung) { _, newValue in
                                    pinBestaetigung = String(newValue.filter { $0.isNumber }.prefix(4))
                                }
                        }

                        if showError {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                        }

                        Button(action: registrieren) {
                            Text("Profil erstellen")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: 280, minHeight: 50)
                                .background(formIstGueltig ? Color.orange : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(!formIstGueltig)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationTitle("Registrierung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
        }
    }

    private var formIstGueltig: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !schule.trimmingCharacters(in: .whitespaces).isEmpty &&
        pin.count == 4 &&
        pin == pinBestaetigung
    }

    private func profilFeld(titel: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titel)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 16, design: .rounded))
        }
    }

    private func registrieren() {
        guard pin == pinBestaetigung else {
            errorMessage = "PINs stimmen nicht ueberein"
            showError = true
            return
        }

        let ausbilder = dataStore.registriereAusbilder(
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            schule: schule.trimmingCharacters(in: .whitespaces),
            pin: pin
        )
        appState.ausbilderAnmelden(ausbilder)
        dismiss()
    }
}
