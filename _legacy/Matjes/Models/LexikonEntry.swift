import Foundation
import SwiftData

@Model
class LexikonEntry: ObservableObject { // <--- Auch hier für den Refresh
    var code: String = ""
    var name: String = ""
    var kategorie: String?
    var beschreibung: String?
    var details: String?
    
    init(code: String = "", name: String = "", kategorie: String? = nil, beschreibung: String? = nil, details: String? = nil) {
        self.code = code
        self.name = name
        self.kategorie = kategorie
        self.beschreibung = beschreibung
        self.details = details
    }
}
