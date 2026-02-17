//
//  Garmethode.swift
//  MatjesSchule
//
//  Datenmodell fuer Garmethoden / Lexikon (portiert aus V1/V2)
//

import Foundation

struct Garmethode: Identifiable, Codable {
    let id: String
    let name: String
    let typ: String
    let temperatur: String
    let medium: String
    let beschreibung: String
    let beispiele: String
    let praxistipps: String
    let geeignet_fuer: [String]
    let nicht_geeignet_fuer: [String]
}
