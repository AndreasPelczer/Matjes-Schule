// Models/Auftrag.swift (BEREINIGT)
// Source: test25B (einziges Vorkommen)

import Foundation

extension Auftrag {

    /// Master-Status für die UI (AuftragStatus)
    var status: AuftragStatus {
        get {
            AuftragStatus(rawValue: statusRawValue ?? AuftragStatus.pending.rawValue) ?? .pending
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }

    /// Kompatibilität: falls irgendwo noch JobStatus verwendet wird
    var jobStatus: JobStatus {
        get { status }              // JobStatus ist typealias auf AuftragStatus
        set { status = newValue }
    }
}
