//
//  GastroColors.swift
//  iMOPS-Gastro-Grid
//
//  Created by Andreas Pelczer on 07.02.26.
//


//
//  AuditLogView.swift
//  iMOPS-Gastro-Grid
//
//  Phase 1 Audit-Ready: Audit-Log Ansicht.
//  Zeigt alle AuditLogEntry mit ruleId, reason, SOP-Referenz.
//  Gastro-Look: Anthrazit Hintergrund, Terrakotta Akzente, keine Panik-UI.
//

import SwiftUI
import SwiftData

// MARK: - Gastro Design Tokens

private enum GastroColors {
    static let background = Color(red: 0.10, green: 0.10, blue: 0.12)    // #1A1A1E Anthrazit
    static let accent = Color(red: 0.91, green: 0.35, blue: 0.24)        // #E85A3C Terrakotta
    static let success = Color(red: 0.30, green: 0.69, blue: 0.31)       // #4CAF50 Kräuter-Grün
    static let warning = Color(red: 1.00, green: 0.65, blue: 0.15)       // #FFA726 Butter-Amber
    static let cardBackground = Color(red: 0.14, green: 0.14, blue: 0.16) // Leicht heller als BG
}

// MARK: - AuditLogView

@available(iOS 17.0, *)
struct AuditLogView: View {
    let auditTrail: AuditTrail?

    @State private var entries: [AuditLogEntry] = []
    @State private var filterAction: String? = nil

    private var filteredEntries: [AuditLogEntry] {
        guard let filter = filterAction else { return entries }
        return entries.filter { $0.action == filter }
    }

    private var uniqueActions: [String] {
        Array(Set(entries.map(\.action))).sorted()
    }

    var body: some View {
        List {
            // Filter
            Section {
                Picker("Filter", selection: $filterAction) {
                    Text("Alle Aktionen").tag(nil as String?)
                    ForEach(uniqueActions, id: \.self) { action in
                        Text(action).tag(action as String?)
                    }
                }
                .pickerStyle(.menu)
            }

            // Stats
            Section {
                HStack {
                    Label("\(entries.count) Einträge", systemImage: "list.bullet")
                    Spacer()
                    if let first = entries.first {
                        Text("seit \(first.timestamp, style: .date)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Entries
            Section {
                ForEach(filteredEntries, id: \.id) { entry in
                    AuditEventRow(entry: entry)
                }
            }
        }
        .navigationTitle("Audit-Log")
        .onAppear {
            entries = auditTrail?.fetchAllEntries().reversed() ?? []
        }
        .refreshable {
            entries = auditTrail?.fetchAllEntries().reversed() ?? []
        }
    }
}

// MARK: - AuditEventRow

@available(iOS 17.0, *)
struct AuditEventRow: View {
    let entry: AuditLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Zeile 1: Zeit + Actor + Action + Result
            HStack(spacing: 4) {
                Text(entry.timestamp, style: .time)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)

                Text("·")
                    .foregroundStyle(.secondary)

                Text(actorLabel)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)

                Text("·")
                    .foregroundStyle(.secondary)

                Text(entry.action)
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(actionColor)

                Spacer()

                if let result = entry.result {
                    Text(result)
                        .font(.caption2.monospaced())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(resultColor.opacity(0.15))
                        .foregroundStyle(resultColor)
                        .clipShape(Capsule())
                }
            }

            // Zeile 2: Reason
            if let reason = entry.reason {
                Text(reason)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Zeile 3: Key/Object
            if let key = entry.key {
                Text(key)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            // Badges: Rule + SOP
            if entry.ruleId != nil || entry.sopId != nil {
                HStack(spacing: 6) {
                    if let ruleId = entry.ruleId {
                        RuleBadge(ruleId: ruleId)
                    }
                    if let sopId = entry.sopId {
                        SOPBadge(sopId: sopId, version: entry.sopVersion)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 2)
    }

    private var actorLabel: String {
        if entry.actorType == "system" { return "SYS" }
        return entry.actorId ?? entry.userId
    }

    private var actionColor: Color {
        switch entry.action {
        case "SAVE_DENIED": return GastroColors.accent
        case "INTEGRITY_CHECK": return GastroColors.warning
        case "EXPORT_CREATED": return GastroColors.success
        default: return .primary
        }
    }

    private var resultColor: Color {
        switch entry.result {
        case "OK": return GastroColors.success
        case "DENIED": return GastroColors.accent
        case "FAIL": return GastroColors.accent
        default: return .secondary
        }
    }
}

// MARK: - Badges

private struct RuleBadge: View {
    let ruleId: String

    var body: some View {
        Text("Rule: \(ruleId)")
            .font(.caption2.monospaced())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(GastroColors.warning.opacity(0.15))
            .foregroundStyle(GastroColors.warning)
            .clipShape(Capsule())
    }
}

private struct SOPBadge: View {
    let sopId: String
    let version: String?

    var body: some View {
        let label = version != nil ? "\(sopId) v\(version!)" : sopId
        Text(label)
            .font(.caption2.monospaced())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.15))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }
}