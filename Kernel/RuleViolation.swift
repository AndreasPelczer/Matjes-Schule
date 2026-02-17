//
//  RuleViolation.swift
//  iMOPS-Gastro-Grid
//
//  Created by Andreas Pelczer on 07.02.26.
//


//
//  RuleViolation.swift
//  iMOPS-Gastro-Grid
//
//  Phase 1 Audit-Ready: Regel-IDs (HACCP-Rxx) als First-Class Bürger.
//  Validierungsfunktionen liefern Result<Void, RuleViolation> statt Bool.
//  Kein "silent fail" ohne AuditEvent.
//
//  Regel-ID Format: "HACCP-Rxx" (allgemein) oder "HACCP-CCP-xx" (für CCPs)
//

import Foundation

// MARK: - RuleViolation

/// A structured validation failure with a traceable rule ID.
struct RuleViolation: Error {
    let ruleId: String              // z.B. "HACCP-R01", "HACCP-CCP-02"
    let reason: String              // Human-readable, max 120 chars
    let fields: [String]?           // Betroffene Felder (optional)

    init(ruleId: String, reason: String, fields: [String]? = nil) {
        self.ruleId = ruleId
        self.reason = String(reason.prefix(120))
        self.fields = fields
    }
}

// MARK: - Validation Result Typealias

typealias ValidationResult = Result<Void, RuleViolation>

// MARK: - KernelValidator

/// Validates kernel operations before execution.
/// Returns RuleViolation with ruleId + reason instead of silent failure.
@available(iOS 17.0, *)
struct KernelValidator {

    // MARK: - Path Validation

    /// Validate a kernel path. Returns RuleViolation if invalid.
    /// Replaces TheBrain.validate() silent Bool check.
    static func validatePath(_ path: String) -> ValidationResult {
        guard !path.isEmpty else {
            return .failure(RuleViolation(
                ruleId: "HACCP-R01",
                reason: "Leerer Pfad ist nicht erlaubt",
                fields: ["path"]
            ))
        }

        guard path.hasPrefix("^") else {
            return .failure(RuleViolation(
                ruleId: "HACCP-R01",
                reason: "Pfad muss mit ^ beginnen: \(String(path.prefix(20)))",
                fields: ["path"]
            ))
        }

        guard !path.contains(" ") else {
            return .failure(RuleViolation(
                ruleId: "HACCP-R01",
                reason: "Pfad darf keine Leerzeichen enthalten",
                fields: ["path"]
            ))
        }

        return .success(())
    }

    // MARK: - Task Validation

    /// Validate a task before creation.
    static func validateTaskCreation(id: String, title: String, weight: Int) -> ValidationResult {
        guard !id.isEmpty else {
            return .failure(RuleViolation(
                ruleId: "HACCP-R02",
                reason: "Task-ID darf nicht leer sein",
                fields: ["id"]
            ))
        }

        guard !title.isEmpty else {
            return .failure(RuleViolation(
                ruleId: "HACCP-R02",
                reason: "Task-Titel darf nicht leer sein",
                fields: ["title"]
            ))
        }

        guard weight > 0 && weight <= 100 else {
            return .failure(RuleViolation(
                ruleId: "HACCP-R03",
                reason: "Gewichtung muss zwischen 1 und 100 liegen: \(weight)",
                fields: ["weight"]
            ))
        }

        return .success(())
    }

    // MARK: - Temperature Validation (CCP)

    /// Validate a temperature reading against HACCP CCP limits.
    static func validateTemperature(_ temperature: Double, maxAllowed: Double = 7.0, context: String = "Kühllagerung") -> ValidationResult {
        guard temperature <= maxAllowed else {
            return .failure(RuleViolation(
                ruleId: "HACCP-CCP-02",
                reason: "\(context): Temperatur \(String(format: "%.1f", temperature))°C über Grenzwert \(String(format: "%.1f", maxAllowed))°C",
                fields: ["temperature"]
            ))
        }

        return .success(())
    }

    /// Validate core temperature for cooking (must be >= threshold).
    static func validateCoreTemperature(_ temperature: Double, minRequired: Double = 72.0) -> ValidationResult {
        guard temperature >= minRequired else {
            return .failure(RuleViolation(
                ruleId: "HACCP-CCP-01",
                reason: "Kerntemperatur \(String(format: "%.1f", temperature))°C unter Mindestgrenze \(String(format: "%.1f", minRequired))°C",
                fields: ["coreTemperature"]
            ))
        }

        return .success(())
    }

    // MARK: - Archive Validation

    /// Validate that a task can be completed (all required fields present).
    static func validateTaskCompletion(id: String) -> ValidationResult {
        let title: String? = iMOPS.GET(.task(id, "TITLE"))
        guard title != nil && !(title?.isEmpty ?? true) else {
            return .failure(RuleViolation(
                ruleId: "HACCP-R04",
                reason: "Task \(id) hat keinen Titel — Archivierung nicht möglich",
                fields: ["title"]
            ))
        }

        let status: String? = iMOPS.GET(.task(id, "STATUS"))
        guard status == "OPEN" else {
            return .failure(RuleViolation(
                ruleId: "HACCP-R04",
                reason: "Task \(id) ist nicht offen (Status: \(status ?? "nil"))",
                fields: ["status"]
            ))
        }

        return .success(())
    }

    // MARK: - Rule ID Format Validation

    /// Checks that a ruleId matches the expected format (HACCP-Rxx or HACCP-CCP-xx).
    static func isValidRuleIdFormat(_ ruleId: String) -> Bool {
        let pattern = #"^HACCP-(R\d{2}|CCP-\d{2})$"#
        return ruleId.range(of: pattern, options: .regularExpression) != nil
    }
}