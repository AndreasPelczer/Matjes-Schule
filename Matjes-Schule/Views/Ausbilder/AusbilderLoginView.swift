//
//  AusbilderLoginView.swift
//  MatjesSchule
//
//  Login-Screen fuer Ausbilder (PIN + Biometrie)
//

import SwiftUI

struct AusbilderLoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var pin: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

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

                    // Logo/Icon
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)

                    Text("Ausbilder-Login")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Melde dich an, um Klassen und Fortschritte zu verwalten.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // PIN-Eingabe
                    VStack(spacing: 16) {
                        SecureField("4-stellige PIN", text: $pin)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 200)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))

                        Button(action: loginMitPIN) {
                            Text("Anmelden")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: 200, minHeight: 50)
                                .background(Color.orange)
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
        }
    }

    private func loginMitPIN() {
        // TODO: Implementierung mit gespeichertem Ausbilder-Profil
        // Vorlaeufig: Demo-Login
        let demoAusbilder = Ausbilder(
            name: "Demo Ausbilder",
            email: "demo@matjes.app",
            schule: "Berufsschule",
            pinHash: AusbilderAuthentication.hashPIN(pin)
        )
        appState.ausbilderAnmelden(demoAusbilder)
    }

    private func loginMitBiometrie() {
        Task {
            do {
                _ = try await AusbilderAuthentication.authenticate(ausbilderId: "demo")
                await MainActor.run {
                    let demoAusbilder = Ausbilder(
                        name: "Demo Ausbilder",
                        email: "demo@matjes.app",
                        schule: "Berufsschule",
                        pinHash: ""
                    )
                    appState.ausbilderAnmelden(demoAusbilder)
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
