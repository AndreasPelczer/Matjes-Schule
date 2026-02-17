//
//  SOPMapping.swift
//  iMOPS-Gastro-Grid
//
//  Created by Andreas Pelczer on 07.02.26.
//


//
//  SOPMapping.swift
//  iMOPS-Gastro-Grid
//
//  Phase 1 Audit-Ready: Mapping von HACCP-Regeln zu SOPs.
//  Kritische AuditEvents können eine SOP-Referenz tragen.
//
//  Die SOP-Referenz bleibt stabil, auch wenn die SOP später archiviert wird,
//  weil sopId + sopVersion als Snapshot im Event gespeichert werden.
//

import Foundation
import SwiftData

/// Maps HACCP rule IDs to their governing SOP documents.
@available(iOS 17.0, *)
struct SOPMapping {

    /// Static mapping: ruleId → (sopId, defaultVersion)
    /// Falls die SOPRegistry eine aktive Version hat, wird die bevorzugt.
    /// Sonst wird die defaultVersion als Fallback verwendet.
    private static let ruleToSOP: [String: (sopId: String, defaultVersion: String)] = [
        "HACCP-R01": (sopId: "SOP-KERNEL-01", defaultVersion: "1.0"),
        "HACCP-R02": (sopId: "SOP-TASK-01", defaultVersion: "1.0"),
        "HACCP-R03": (sopId: "SOP-TASK-01", defaultVersion: "1.0"),
        "HACCP-R04": (sopId: "SOP-ARCHIVE-01", defaultVersion: "1.0"),
        "HACCP-CCP-01": (sopId: "SOP-TEMP-01", defaultVersion: "1.0"),
        "HACCP-CCP-02": (sopId: "SOP-TEMP-01", defaultVersion: "1.0"),
    ]

    /// Resolve the SOP reference for a given ruleId.
    /// Tries the SOPRegistry first, falls back to the static mapping.
    static func resolve(ruleId: String, context: ModelContext? = nil) -> (sopId: String, sopVersion: String)? {
        guard let mapping = ruleToSOP[ruleId] else { return nil }

        // Try live registry
        if let ctx = context,
           let activeSOP = SOPRegistry.getActiveSOP(sopId: mapping.sopId, context: ctx) {
            return (sopId: activeSOP.sopId, sopVersion: activeSOP.version)
        }

        // Fallback to static default
        return (sopId: mapping.sopId, sopVersion: mapping.defaultVersion)
    }

    /// Convenience: enrich an AuditTrail log call with SOP info based on ruleId.
    /// Returns the resolved sopId and sopVersion (or nil if no mapping exists).
    static func enrichWithSOP(ruleId: String?, context: ModelContext? = nil) -> (sopId: String?, sopVersion: String?) {
        guard let ruleId = ruleId else { return (nil, nil) }
        guard let resolved = resolve(ruleId: ruleId, context: context) else { return (nil, nil) }
        return (resolved.sopId, resolved.sopVersion)
    }
}