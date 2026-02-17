//
//  AppState.swift
//  MatjesSchule
//
//  Globaler App-Zustand: Unterscheidet Schueler- und Ausbilder-Modus.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var istAusbilderAngemeldet: Bool = false
    @Published var aktuellerAusbilder: Ausbilder? = nil

    func ausbilderAnmelden(_ ausbilder: Ausbilder) {
        aktuellerAusbilder = ausbilder
        istAusbilderAngemeldet = true
    }

    func abmelden() {
        aktuellerAusbilder = nil
        istAusbilderAngemeldet = false
    }
}
