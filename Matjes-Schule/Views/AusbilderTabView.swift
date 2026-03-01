//
//  AusbilderTabView.swift
//  Matjes
//
//  Haupt-Navigation fuer Ausbilder.
//  Tabs: Dashboard, Klassen, Fragen, Quiz (zum Testen), Einstellungen
//

import SwiftUI

struct AusbilderTabView: View {
    @State private var selectedTab = 0
    @State private var showPaywall = false
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    var roleManager: RoleManager = .shared
    var subscriptionManager: SubscriptionManager = .shared

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                AusbilderDashboardView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Dashboard")
                    }
                    .tag(0)

                KlassenListView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Klassen")
                    }
                    .tag(1)

                FragenkatalogView()
                    .tabItem {
                        Image(systemName: "questionmark.circle.fill")
                        Text("Fragen")
                    }
                    .tag(2)

                StartScreenView()
                    .tabItem {
                        Image(systemName: "gamecontroller.fill")
                        Text("Quiz")
                    }
                    .tag(3)

                EinstellungenView(
                    roleManager: roleManager,
                    subscriptionManager: subscriptionManager
                )
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Einstellungen")
                }
                .tag(4)
            }
            .tint(.orange)

            // Trial Banner
            if subscriptionManager.isInTrial && !subscriptionManager.isSubscribed {
                TrialBannerView(
                    daysRemaining: subscriptionManager.trialDaysRemaining,
                    onTap: { showPaywall = true }
                )
                .padding(.top, 4)
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
