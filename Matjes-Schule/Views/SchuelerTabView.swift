//
//  SchuelerTabView.swift
//  Matjes
//
//  Haupt-Navigation fuer Azubis.
//  Tabs: Quiz, Lexikon, Fortschritt, Einstellungen
//

import SwiftUI

struct SchuelerTabView: View {
    @State private var selectedTab = 0
    @State private var showPaywall = false
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    var roleManager: RoleManager = .shared
    var subscriptionManager: SubscriptionManager = .shared

    var body: some View {
        TabView(selection: $selectedTab) {
            StartScreenView()
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Quiz")
                }
                .tag(0)

            LexikonHomeView(
                produkte: LexikonLoader.loadProdukte(),
                garmethoden: LexikonLoader.loadGarmethoden(),
                saucen: LexikonLoader.loadSaucen()
            )
            .tabItem {
                Image(systemName: "book.fill")
                Text("Lexikon")
            }
            .tag(1)

            SchuelerCodeView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Fortschritt")
                }
                .tag(2)

            EinstellungenView(
                roleManager: roleManager,
                subscriptionManager: subscriptionManager
            )
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Einstellungen")
            }
            .tag(3)
        }
        .tint(.orange)
        .safeAreaInset(edge: .top) {
            if subscriptionManager.isInTrial && !subscriptionManager.isSubscribed {
                TrialBannerView(
                    daysRemaining: subscriptionManager.trialDaysRemaining,
                    onTap: { showPaywall = true }
                )
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
        .fullScreenCover(isPresented: .init(
            get: { !subscriptionManager.hasFullAccess },
            set: { _ in }
        )) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
    }
}
