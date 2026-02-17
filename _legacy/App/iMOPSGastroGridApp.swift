//
//  iMOPSGastroGridApp.swift
//  iMOPS-Gastro-Grid
//
//  Source: test25B/test25BApp.swift
//  Status: Kopiert 1:1 – Struct-Name angepasst
//
//  TODO bei Xcode-Projekt-Setup:
//  - ModelContainer für SwiftData konfigurieren (TheBrain.configure())
//  - CoreData PersistenceController bleibt vorerst für test25B-Models
//

import SwiftUI
import CoreData

@main
struct iMOPSGastroGridApp: App {
    let persistenceController = PersistenceController.shared
    let brain = TheBrain.shared  // iMOPS Kernel (dormant, kein seed())

    @StateObject private var eventListVM: EventListViewModel
    @State private var session = AppSession()

    init() {
        let ctx = PersistenceController.shared.container.viewContext
        _eventListVM = StateObject(wrappedValue: EventListViewModel(context: ctx))

        // Phase 3: Warm-Start – aktive Aufträge in Kernel laden (Meier-Score)
        KernelBridge.shared.syncAllActiveJobs(from: ctx)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(eventListVM)
                .environment(session)
        }
    }
}
