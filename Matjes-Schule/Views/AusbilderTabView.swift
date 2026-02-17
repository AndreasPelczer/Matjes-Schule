//
//  AusbilderTabView.swift
//  MatjesSchule
//
//  Haupt-Navigation fuer Ausbilder (Dashboard + Klassen + Fragen + Einstellungen)
//

import SwiftUI

struct AusbilderTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var appState: AppState

    var body: some View {
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

            AusbilderSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Einstellungen")
                }
                .tag(3)
        }
        .tint(.orange)
    }
}
