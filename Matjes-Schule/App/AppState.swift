//
//  AppState.swift
//  MatjesSchule
//
//  Globaler App-Zustand: Unterscheidet Schueler- und Ausbilder-Modus.
//  Persistent: Login ueberlebt App-Neustart.
//

import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var istAusbilderAngemeldet: Bool = false
    @Published var aktuellerAusbilder: Ausbilder? = nil

    private let loginKey = "MatjesSchule_AusbilderEingeloggt"

    init() {
        if UserDefaults.standard.bool(forKey: loginKey) {
            let store = DataStore.shared
            if let ausbilder = store.ausbilder {
                aktuellerAusbilder = ausbilder
                istAusbilderAngemeldet = true
            } else {
                UserDefaults.standard.set(false, forKey: loginKey)
            }
        }
    }

    func ausbilderAnmelden(_ ausbilder: Ausbilder) {
        aktuellerAusbilder = ausbilder
        istAusbilderAngemeldet = true
        UserDefaults.standard.set(true, forKey: loginKey)
    }

    func abmelden() {
        aktuellerAusbilder = nil
        istAusbilderAngemeldet = false
        UserDefaults.standard.set(false, forKey: loginKey)
    }
}
