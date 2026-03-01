//
//  OnboardingView.swift
//  Matjes
//
//  Onboarding-Screen beim ersten App-Start.
//  Der Nutzer waehlt seine Rolle: Azubi oder Ausbilder.
//

import SwiftUI

struct OnboardingView: View {
    var onRoleSelected: (UserRole) -> Void

    @State private var animateIn = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [Color.orange.opacity(0.25), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo & Titel
                VStack(spacing: 16) {
                    Text("\u{1F41F}")
                        .font(.system(size: 80))
                        .scaleEffect(animateIn ? 1.0 : 0.5)
                        .opacity(animateIn ? 1 : 0)

                    Text("Willkommen bei Matjes!")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateIn ? 1 : 0)

                    Text("Das Ausbildungsspiel der K\u{00FC}che")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(animateIn ? 1 : 0)
                }

                Spacer()
                    .frame(height: 50)

                // Frage
                Text("Wie m\u{00F6}chtest du Matjes nutzen?")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(animateIn ? 1 : 0)
                    .padding(.bottom, 24)

                // Rollenauswahl
                VStack(spacing: 16) {
                    roleButton(
                        role: .azubi,
                        icon: "graduationcap.fill",
                        title: "Ich bin Azubi",
                        subtitle: "Quiz spielen, lernen und Fortschritt verfolgen",
                        color: .blue
                    )

                    roleButton(
                        role: .ausbilder,
                        icon: "person.badge.key.fill",
                        title: "Ich bin Ausbilder",
                        subtitle: "Klassen verwalten und Azubis begleiten",
                        color: .orange
                    )
                }
                .padding(.horizontal, 30)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 30)

                Spacer()

                Text("Du kannst deine Rolle sp\u{00E4}ter in den Einstellungen \u{00E4}ndern.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                    .opacity(animateIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateIn = true
            }
        }
    }

    private func roleButton(role: UserRole, icon: String, title: String, subtitle: String, color: Color) -> some View {
        Button(action: { onRoleSelected(role) }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                    .frame(width: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(20)
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
