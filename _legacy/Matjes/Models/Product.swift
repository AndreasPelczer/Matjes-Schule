import Foundation
import SwiftData

@Model
final class Product: ObservableObject { // <--- Das sorgt für den Refresh
    var id: String = ""
    var name: String = ""
    var category: String = ""
    var dataSource: String = ""
    var beschreibung: String = ""
    var stockQuantity: Double = 0.0
    var stockUnit: String = "Stk."
    var allergene: String = ""
    var zusatzstoffe: String = ""
    var kcal: String = ""
    var fett: String = ""
    var zucker: String = ""
    var zusatzInfos: [String: String] = [:]
    
    @Relationship(deleteRule: .cascade, inverse: \Recipe.product)
    var rezept: Recipe?
    
    init(id: String = "", name: String = "", category: String = "", dataSource: String = "") {
        self.id = id
        self.name = name
        self.category = category
        self.dataSource = dataSource
    }
}

@Model
final class Recipe {
    var portionen: String = "1"
    var algorithmus: [String] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    var komponenten: [Ingredient]? = []
    
    var product: Product?
    
    init(portionen: String = "1", algorithmus: [String] = [], komponenten: [Ingredient] = []) {
        self.portionen = portionen
        self.algorithmus = algorithmus
        self.komponenten = komponenten
    }
}

@Model
final class Ingredient {
    var name: String = ""
    var menge: String = ""
    var einheit: String = ""
    var recipe: Recipe?
    
    init(name: String = "", menge: String = "", einheit: String = "") {
        self.name = name
        self.menge = menge
        self.einheit = einheit
    }
}
