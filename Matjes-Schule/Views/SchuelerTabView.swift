//
//  SchuelerTabView.swift
//  MatjesSchule
//
//  Haupt-Navigation fuer Schueler (Quiz + Lexikon + Buch + Ausbilder-Login)
//

import SwiftUI

struct SchuelerTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var appState: AppState

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

            BuchReaderView()
                .tabItem {
                    Image(systemName: "text.book.closed.fill")
                    Text("Buch")
                }
                .tag(2)

            AusbilderLoginView()
                .tabItem {
                    Image(systemName: "person.badge.key.fill")
                    Text("Ausbilder")
                }
                .tag(3)
        }
        .tint(.orange)
    }
}
