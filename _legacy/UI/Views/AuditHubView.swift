//
//  AuditHubView.swift
//  iMOPS-Gastro-Grid
//
//  Created by Andreas Pelczer on 07.02.26.
//


//
//  AuditHubView.swift
//  iMOPS-Gastro-Grid
//
//  Phase 1 Audit-Ready: Einstiegsseite für Audit, Integrität und Export.
//  Bündelt AuditLogView, IntegrityView und ExportView in einer NavigationStack.
//

import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct AuditHubView: View {
    let brain = TheBrain.shared

    var body: some View {
        List {
            Section {
                NavigationLink {
                    AuditLogView(auditTrail: brain.auditTrail)
                } label: {
                    Label("Audit-Log", systemImage: "list.bullet.rectangle")
                }

                NavigationLink {
                    IntegrityView(
                        auditTrail: brain.auditTrail,
                        journal: brain.journal
                    )
                } label: {
                    Label("Integritätsprüfung", systemImage: "checkmark.shield")
                }

                NavigationLink {
                    ExportView(
                        auditTrail: brain.auditTrail,
                        journal: brain.journal,
                        brain: brain
                    )
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            } header: {
                Text("HACCP Compliance")
            } footer: {
                Text("Audit-fähiges System für IFS Food 8 / FSSC 22000. Alle Aktionen werden revisionssicher protokolliert.")
                    .font(.caption2)
            }

            // Quick Stats
            Section {
                LabeledContent("iMOPS Version") {
                    Text(HACCPExporter.iMOPSVersion)
                        .font(.caption.monospaced())
                }

                LabeledContent("Audit-Einträge") {
                    Text("\(brain.auditTrail?.entryCount ?? 0)")
                        .font(.caption.monospaced())
                }

                if let lastCheck = IntegrityVerifier.loadLastCheckResult() {
                    LabeledContent("Letzter Check") {
                        HStack(spacing: 4) {
                            Image(systemName: lastCheck.isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundStyle(lastCheck.isValid
                                    ? Color(red: 0.30, green: 0.69, blue: 0.31)
                                    : Color(red: 0.91, green: 0.35, blue: 0.24))
                            Text(lastCheck.date, style: .relative)
                                .font(.caption)
                        }
                    }
                }
            } header: {
                Text("Status")
            }
        }
        .navigationTitle("Audit")
    }
}