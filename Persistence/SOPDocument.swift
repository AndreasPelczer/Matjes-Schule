//
//  SOPDocument.swift
//  iMOPS-Gastro-Grid
//
//  Created by Andreas Pelczer on 07.02.26.
//


//
//  SOPDocument.swift
//  iMOPS-Gastro-Grid
//
//  Phase 1 Audit-Ready: SOP Dokumentenlenkung (minimal).
//  Versionierte Standard Operating Procedures mit Lifecycle.
//
//  Ersetzt die bisherige Enum-basierte AuftragTemplate NICHT,
//  sondern ergänzt sie als versionierbare, persistierte Referenz.
//
//  Je SOP gibt es genau eine aktive Version.
//  Ältere Versionen werden archiviert, bleiben aber für Rückverfolgung erhalten.
//

import Foundation
import SwiftData

/// A versioned Standard Operating Procedure document.
@available(iOS 17.0, *)
@Model
class SOPDocument {
    var id: UUID
    var sopId: String               // z.B. "SOP-03" (stabil über Versionen)
    var title: String               // z.B. "Temperaturkontrolle Kühlraum"
    var version: String             // z.B. "1.4" (SemVer oder einfach Major.Minor)
    var status: String              // "active" | "archived"
    var validFrom: Date
    var approvedBy: String?         // Wer hat die Version freigegeben
    var checksum: String?           // Optional: SHA-256 über den Inhalt (für spätere Verifikation)
    var createdAt: Date

    init(id: UUID = UUID(),
         sopId: String,
         title: String,
         version: String,
         status: String = "active",
         validFrom: Date = Date(),
         approvedBy: String? = nil,
         checksum: String? = nil) {
        self.id = id
        self.sopId = sopId
        self.title = title
        self.version = version
        self.status = status
        self.validFrom = validFrom
        self.approvedBy = approvedBy
        self.checksum = checksum
        self.createdAt = Date()
    }
}

// MARK: - SOP Registry

/// In-memory registry for managing SOP documents.
/// Provides lookup and lifecycle management.
@available(iOS 17.0, *)
struct SOPRegistry {

    /// Fetch all SOPs from the given ModelContext.
    static func listSOPs(context: ModelContext) -> [SOPDocument] {
        let descriptor = FetchDescriptor<SOPDocument>(
            sortBy: [SortDescriptor(\.sopId), SortDescriptor(\.version)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetch the active version of a specific SOP.
    static func getActiveSOP(sopId: String, context: ModelContext) -> SOPDocument? {
        let predicate = #Predicate<SOPDocument> { doc in
            doc.sopId == sopId && doc.status == "active"
        }
        var descriptor = FetchDescriptor<SOPDocument>(predicate: predicate)
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    /// Fetch a specific version of a SOP.
    static func getSOP(sopId: String, version: String, context: ModelContext) -> SOPDocument? {
        let predicate = #Predicate<SOPDocument> { doc in
            doc.sopId == sopId && doc.version == version
        }
        var descriptor = FetchDescriptor<SOPDocument>(predicate: predicate)
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    /// Archive all active versions of a SOP (before activating a new one).
    static func archiveAllVersions(sopId: String, context: ModelContext) {
        let predicate = #Predicate<SOPDocument> { doc in
            doc.sopId == sopId && doc.status == "active"
        }
        let descriptor = FetchDescriptor<SOPDocument>(predicate: predicate)
        let active = (try? context.fetch(descriptor)) ?? []
        for doc in active {
            doc.status = "archived"
        }
    }

    /// Create and activate a new SOP version, archiving previous active versions.
    static func createNewVersion(
        sopId: String,
        title: String,
        version: String,
        approvedBy: String? = nil,
        validFrom: Date = Date(),
        context: ModelContext
    ) -> SOPDocument {
        archiveAllVersions(sopId: sopId, context: context)

        let doc = SOPDocument(
            sopId: sopId,
            title: title,
            version: version,
            status: "active",
            validFrom: validFrom,
            approvedBy: approvedBy
        )
        context.insert(doc)
        return doc
    }
}