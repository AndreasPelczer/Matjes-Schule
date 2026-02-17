//
//  IntegrityView.swift
//  iMOPS-Gastro-Grid
//
//  Created by Andreas Pelczer on 07.02.26.
//


//
//  IntegrityView.swift
//  iMOPS-Gastro-Grid
//
//  Phase 1 Audit-Ready: Integritätsprüfung UI.
//  Button zum Auslösen, Ergebnis persistiert, nach Neustart sichtbar.
//
//  Keine Panik-UI:
//  "Integritätsprüfung: Abweichung gefunden." statt "KRITISCHER FEHLER!"
//

import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct IntegrityView: View {
    let auditTrail: AuditTrail?
    let journal: Journal?

    @State private var isChecking = false
    @State private var lastCheckDate: Date?
    @State private var lastCheckValid: Bool = true
    @State private var lastCheckDetails: String = ""
    @State private var lastCheckFailedEventId: String?
    @State private var auditEntryCount: Int = 0
    @State private var lastChainHash: String?

    var body: some View {
        List {
            // Status Section
            Section {
                if let date = lastCheckDate {
                    HStack {
                        Image(systemName: lastCheckValid ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                            .foregroundStyle(lastCheckValid
                                ? Color(red: 0.30, green: 0.69, blue: 0.31)
                                : Color(red: 0.91, green: 0.35, blue: 0.24))
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(lastCheckValid
                                ? "Integrität bestätigt"
                                : "Abweichung gefunden")
                                .font(.headline)

                            Text("Letzter Check: \(date, style: .relative) ago")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !lastCheckValid, let failedId = lastCheckFailedEventId {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundStyle(.secondary)
                            Text("Abweichung bei Event: \(String(failedId.prefix(8)))…")
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !lastCheckDetails.isEmpty {
                        Text(lastCheckDetails)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text("Noch keine Prüfung durchgeführt")
                                .font(.headline)
                            Text("Starte die erste Integritätsprüfung")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Integritätsstatus")
            }

            // Stats Section
            Section {
                LabeledContent("Audit-Einträge", value: "\(auditEntryCount)")
                if let hash = lastChainHash {
                    LabeledContent("Letzter Chain-Hash") {
                        Text(ExportSeal.shortened(hash))
                            .font(.caption.monospaced())
                    }
                }
            } header: {
                Text("Audit-Chain")
            }

            // Action Section
            Section {
                Button {
                    runCheck()
                } label: {
                    HStack {
                        if isChecking {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "checkmark.shield")
                        }
                        Text("Integritätsprüfung ausführen")
                    }
                }
                .disabled(isChecking || auditTrail == nil || journal == nil)
            } footer: {
                Text("Prüft die Audit-Chain (SHA-256 Hash-Kette) und die Journal-Konsistenz. Das Ergebnis wird als AuditEvent protokolliert.")
                    .font(.caption2)
            }
        }
        .navigationTitle("Integrität")
        .onAppear {
            loadPersistedResult()
            loadChainStats()
        }
    }

    private func runCheck() {
        guard let auditTrail = auditTrail, let journal = journal else { return }
        isChecking = true

        DispatchQueue.global(qos: .userInitiated).async {
            let result = IntegrityVerifier.runIntegrityCheck(
                auditTrail: auditTrail,
                journal: journal
            )

            DispatchQueue.main.async {
                lastCheckDate = result.timestamp
                lastCheckValid = result.isValid
                lastCheckDetails = result.details
                lastCheckFailedEventId = result.failedEventId?.uuidString
                auditEntryCount = result.auditEntryCount
                isChecking = false
            }
        }
    }

    private func loadPersistedResult() {
        if let persisted = IntegrityVerifier.loadLastCheckResult() {
            lastCheckDate = persisted.date
            lastCheckValid = persisted.isValid
            lastCheckDetails = persisted.details
            lastCheckFailedEventId = persisted.failedEventId
        }
    }

    private func loadChainStats() {
        guard let trail = auditTrail else { return }
        auditEntryCount = trail.entryCount
        if let lastEntry = trail.fetchAllEntries().last {
            lastChainHash = lastEntry.chainHash
        }
    }
}