//
//  LexikonQuizGenerator.swift
//  MatjesSchule
//
//  Automatische Fragen-Generierung aus Lexikon-Daten (portiert aus V1/V2)
//  Bloom-Taxonomie: Erkennen → Zuordnen → Wissen → Anwenden → Bewerten
//
//  Level 12-13: ERKENNEN  - Produkte, Garmethoden, Saucen identifizieren
//  Level 14-15: ZUORDNEN  - Kategorien und Typen zuweisen
//  Level 16-17: WISSEN    - Fakten abrufen (Lagerung, Temperatur, Allergene)
//  Level 18-19: ANWENDEN  - Praxissituationen loesen
//  Level 20:    BEWERTEN  - Aussagen beurteilen, Fehler erkennen
//

import Foundation

class LexikonQuizGenerator {

    // MARK: - Oeffentliche API

    static let generatedLevels: Set<Int> = Set(12...20)

    static func generateQuestions(forLevel level: Int) -> [Question] {
        let produkte = LexikonLoader.loadProdukte()
        let garmethoden = LexikonLoader.loadGarmethoden()
        let saucen = LexikonLoader.loadSaucen()

        switch level {
        case 12: return erkennenProdukte(level: level, produkte: produkte)
        case 13: return erkennenGarmethodenSaucen(level: level, garmethoden: garmethoden, saucen: saucen)
        case 14: return zuordnenProdukte(level: level, produkte: produkte)
        case 15: return zuordnenGarmethodenSaucen(level: level, garmethoden: garmethoden, saucen: saucen)
        case 16: return wissenProdukte(level: level, produkte: produkte)
        case 17: return wissenGarmethodenSaucen(level: level, garmethoden: garmethoden, saucen: saucen)
        case 18: return anwendenPraxis(level: level, produkte: produkte, garmethoden: garmethoden, saucen: saucen)
        case 19: return anwendenCrossDomain(level: level, garmethoden: garmethoden, saucen: saucen)
        case 20: return bewerten(level: level, produkte: produkte, garmethoden: garmethoden, saucen: saucen)
        default: return []
        }
    }

    // MARK: - Level 12: ERKENNEN - Produkte

    private static func erkennenProdukte(level: Int, produkte: [Produkt]) -> [Question] {
        var questions: [Question] = []
        let kategorien = Array(Set(produkte.map { $0.kategorie })).sorted()
        let alleNamen = produkte.map { $0.name }

        for kategorie in kategorien {
            let richtige = produkte.filter { $0.kategorie == kategorie }
            let falsche = produkte.filter { $0.kategorie != kategorie }
            guard let produkt = richtige.randomElement(), falsche.count >= 3 else { continue }

            let wrong = pickRandom(from: falsche.map { $0.name }, count: 3)
            questions.append(makeQ(
                level: level,
                text: "Welches dieser Lebensmittel geh\u{00F6}rt zur Kategorie \u{201E}\(kategorie)\u{201C}?",
                correct: produkt.name,
                wrong: wrong,
                erklaerung: "\(produkt.name) geh\u{00F6}rt zur Kategorie \(kategorie). \(firstSentence(produkt.beschreibung))"
            ))
        }

        for produkt in produkte.shuffled().prefix(20) {
            let beschr = firstSentence(produkt.beschreibung)
            guard !beschr.isEmpty else { continue }
            let wrong = pickRandom(from: alleNamen, not: produkt.name, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Um welches Produkt handelt es sich?\n\u{201E}\(beschr)\u{201C}",
                correct: produkt.name,
                wrong: wrong,
                erklaerung: "\(produkt.name): \(beschr)"
            ))
        }

        return questions
    }

    // MARK: - Level 13: ERKENNEN - Garmethoden & Saucen

    private static func erkennenGarmethodenSaucen(level: Int, garmethoden: [Garmethode], saucen: [Sauce]) -> [Question] {
        var questions: [Question] = []
        let alleMethoden = garmethoden.map { $0.name }
        let alleSaucen = saucen.map { $0.name }

        for methode in garmethoden {
            let wrong = pickRandom(from: alleMethoden, not: methode.name, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Welche Garmethode verwendet \u{201E}\(methode.medium)\u{201C} als Garmedium?",
                correct: methode.name,
                wrong: wrong,
                erklaerung: "\(methode.name) arbeitet mit \(methode.medium) bei \(methode.temperatur)."
            ))
        }

        for methode in garmethoden.shuffled().prefix(10) {
            let beschr = firstSentence(methode.beschreibung)
            guard !beschr.isEmpty else { continue }
            let wrong = pickRandom(from: alleMethoden, not: methode.name, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Welche Garmethode wird hier beschrieben?\n\u{201E}\(beschr)\u{201C}",
                correct: methode.name,
                wrong: wrong,
                erklaerung: "\(methode.name): \(beschr)"
            ))
        }

        for sauce in saucen {
            let wrong = pickRandom(from: alleSaucen, not: sauce.name, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Welche Sauce hat diese Basis?\n\u{201E}\(sauce.basis)\u{201C}",
                correct: sauce.name,
                wrong: wrong,
                erklaerung: "\(sauce.name) basiert auf: \(sauce.basis)."
            ))
        }

        return questions
    }

    // MARK: - Level 14: ZUORDNEN - Produkte

    private static func zuordnenProdukte(level: Int, produkte: [Produkt]) -> [Question] {
        var questions: [Question] = []
        let kategorien = Array(Set(produkte.map { $0.kategorie })).sorted()

        for produkt in produkte.shuffled().prefix(25) {
            let wrong = pickRandom(from: kategorien, not: produkt.kategorie, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Zu welcher Warenkunde-Kategorie geh\u{00F6}rt \u{201E}\(produkt.name)\u{201C}?",
                correct: produkt.kategorie,
                wrong: wrong,
                erklaerung: "\(produkt.name) geh\u{00F6}rt zur Kategorie \(produkt.kategorie)."
            ))
        }

        for kategorie in kategorien {
            let richtige = produkte.filter { $0.kategorie == kategorie }
            let falsche = produkte.filter { $0.kategorie != kategorie }
            guard richtige.count >= 3, let intruder = falsche.randomElement() else { continue }

            let korrektInKategorie = Array(richtige.shuffled().prefix(3)).map { $0.name }
            questions.append(makeQ(
                level: level,
                text: "Welches Produkt geh\u{00F6}rt NICHT in die Kategorie \u{201E}\(kategorie)\u{201C}?",
                correct: intruder.name,
                wrong: korrektInKategorie,
                erklaerung: "\(intruder.name) geh\u{00F6}rt zur Kategorie \(intruder.kategorie), nicht zu \(kategorie)."
            ))
        }

        return questions
    }

    // MARK: - Level 15: ZUORDNEN - Garmethoden & Saucen

    private static func zuordnenGarmethodenSaucen(level: Int, garmethoden: [Garmethode], saucen: [Sauce]) -> [Question] {
        var questions: [Question] = []
        let hauptTypen = ["Feuchte Garmethode", "Trockene Garmethode", "Kombinierte Garmethode", "Kalte Garmethode", "Konservierung"]

        for methode in garmethoden {
            let vereinfacht = simplifyGarmethodenTyp(methode.typ)
            var wrong = pickRandom(from: hauptTypen, not: vereinfacht, count: 3)
            if wrong.count < 3 {
                for extra in ["Chemische Garmethode", "Dampfgarmethode", "Induktionsgaren"] where wrong.count < 3 && extra != vereinfacht {
                    wrong.append(extra)
                }
            }
            guard wrong.count >= 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Welcher Typ Garmethode ist \u{201E}\(methode.name)\u{201C}?",
                correct: vereinfacht,
                wrong: Array(wrong.prefix(3)),
                erklaerung: "\(methode.name) ist eine \(methode.typ). Sie arbeitet mit \(methode.medium) bei \(methode.temperatur)."
            ))
        }

        let saucenTypen = Array(Set(saucen.map { $0.typ })).sorted()
        for sauce in saucen {
            let wrong = pickRandom(from: saucenTypen, not: sauce.typ, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Welcher Typ Sauce ist \u{201E}\(sauce.name)\u{201C}?",
                correct: sauce.typ,
                wrong: wrong,
                erklaerung: "\(sauce.name) ist vom Typ \u{201E}\(sauce.typ)\u{201C}. Basis: \(sauce.basis)."
            ))
        }

        let alleMethoden = garmethoden.map { $0.name }
        for methode in garmethoden.shuffled().prefix(10) {
            guard !methode.beispiele.isEmpty else { continue }
            let wrong = pickRandom(from: alleMethoden, not: methode.name, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "F\u{00FC}r welche Garmethode sind diese Beispiele typisch?\n\u{201E}\(methode.beispiele)\u{201C}",
                correct: methode.name,
                wrong: wrong,
                erklaerung: "Typische Beispiele f\u{00FC}r \(methode.name): \(methode.beispiele)."
            ))
        }

        return questions
    }

    // MARK: - Level 16: WISSEN - Produkte

    private static func wissenProdukte(level: Int, produkte: [Produkt]) -> [Question] {
        var questions: [Question] = []
        let alleLagerungen = Array(Set(produkte.map { $0.lagerung })).filter { !$0.isEmpty }

        for produkt in produkte.shuffled().prefix(15) {
            guard !produkt.lagerung.isEmpty else { continue }
            let wrong = pickRandom(from: alleLagerungen, not: produkt.lagerung, count: 3)
                .map { shortenText($0, maxLength: 80) }
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Wie wird \u{201E}\(produkt.name)\u{201C} richtig gelagert?",
                correct: shortenText(produkt.lagerung, maxLength: 80),
                wrong: wrong,
                erklaerung: "Lagerung von \(produkt.name): \(produkt.lagerung)"
            ))
        }

        let mitAllergenen = produkte.filter { !$0.allergene.isEmpty }
        let alleAllergene = Array(Set(mitAllergenen.map { $0.allergene }))
        let extraAllergene = [
            "Gluten (Hauptallergen Nr. 1)", "Erdnuss (Hauptallergen Nr. 5)",
            "Soja (Hauptallergen Nr. 6)", "Schalenf\u{00FC}chte (Hauptallergen Nr. 8)",
            "Lupine (Hauptallergen Nr. 12)", "Sesam (Hauptallergen Nr. 11)"
        ]
        for produkt in mitAllergenen.shuffled().prefix(10) {
            var wrong = pickRandom(from: alleAllergene, not: produkt.allergene, count: 3)
            for extra in extraAllergene where wrong.count < 3 && extra != produkt.allergene {
                wrong.append(extra)
            }
            guard wrong.count >= 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Welches Allergen enth\u{00E4}lt \u{201E}\(produkt.name)\u{201C}?",
                correct: produkt.allergene,
                wrong: Array(wrong.prefix(3)),
                erklaerung: "\(produkt.name) enth\u{00E4}lt: \(produkt.allergene). Die 14 Hauptallergene m\u{00FC}ssen laut EU-Verordnung gekennzeichnet werden."
            ))
        }

        for produkt in produkte.shuffled().prefix(10) {
            let korrekt = "\(produkt.naehrwerte.kcal) kcal pro 100g"
            let falscheWerte = [
                produkt.naehrwerte.kcal + 120,
                max(produkt.naehrwerte.kcal - 40, 5),
                produkt.naehrwerte.kcal + 250
            ].map { "\($0) kcal pro 100g" }

            questions.append(makeQ(
                level: level,
                text: "Wie viel Energie hat \u{201E}\(produkt.name)\u{201C} ungef\u{00E4}hr pro 100g?",
                correct: korrekt,
                wrong: falscheWerte,
                erklaerung: "\(produkt.name) hat \(produkt.naehrwerte.kcal) kcal, \(produkt.naehrwerte.fett)g Fett, \(produkt.naehrwerte.eiweiss)g Eiwei\u{00DF} und \(produkt.naehrwerte.kohlenhydrate)g Kohlenhydrate pro 100g."
            ))
        }

        return questions
    }

    // MARK: - Level 17: WISSEN - Garmethoden & Saucen

    private static func wissenGarmethodenSaucen(level: Int, garmethoden: [Garmethode], saucen: [Sauce]) -> [Question] {
        var questions: [Question] = []
        let alleTemperaturen = garmethoden.map { $0.temperatur }
        let alleMedien = Array(Set(garmethoden.map { $0.medium }))
        let alleBasen = saucen.map { $0.basis }

        for methode in garmethoden {
            let wrong = pickRandom(from: alleTemperaturen, not: methode.temperatur, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Bei welcher Temperatur wird \u{201E}\(methode.name)\u{201C} durchgef\u{00FC}hrt?",
                correct: methode.temperatur,
                wrong: wrong,
                erklaerung: "\(methode.name) arbeitet bei \(methode.temperatur) mit \(methode.medium) als Garmedium."
            ))
        }

        for methode in garmethoden {
            let wrong = pickRandom(from: alleMedien, not: methode.medium, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Welches Garmedium verwendet \u{201E}\(methode.name)\u{201C}?",
                correct: methode.medium,
                wrong: wrong,
                erklaerung: "\(methode.name) verwendet \(methode.medium) als Garmedium bei \(methode.temperatur)."
            ))
        }

        for sauce in saucen {
            let wrong = pickRandom(from: alleBasen, not: sauce.basis, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Was ist die Basis von \u{201E}\(sauce.name)\u{201C}?",
                correct: sauce.basis,
                wrong: wrong,
                erklaerung: "\(sauce.name) (\(sauce.typ)) basiert auf: \(sauce.basis)."
            ))
        }

        let alleVerwendungen = saucen.map { $0.verwendung }
        for sauce in saucen.shuffled().prefix(10) {
            let wrong = pickRandom(from: alleVerwendungen, not: sauce.verwendung, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Wof\u{00FC}r wird \u{201E}\(sauce.name)\u{201C} typischerweise verwendet?",
                correct: sauce.verwendung,
                wrong: wrong,
                erklaerung: "\(sauce.name) wird verwendet f\u{00FC}r: \(sauce.verwendung)."
            ))
        }

        return questions
    }

    // MARK: - Level 18: ANWENDEN - Praxis

    private static func anwendenPraxis(level: Int, produkte: [Produkt], garmethoden: [Garmethode], saucen: [Sauce]) -> [Question] {
        var questions: [Question] = []
        let alleMethoden = garmethoden.map { $0.name }
        let alleSaucen = saucen.map { $0.name }

        for methode in garmethoden {
            for geeignet in methode.geeignet_fuer.prefix(2) {
                let wrong = pickRandom(from: alleMethoden, not: methode.name, count: 3)
                guard wrong.count == 3 else { continue }

                questions.append(makeQ(
                    level: level,
                    text: "Du m\u{00F6}chtest \u{201E}\(geeignet)\u{201C} zubereiten. Welche Garmethode eignet sich besonders?",
                    correct: methode.name,
                    wrong: wrong,
                    erklaerung: "\(methode.name) eignet sich besonders f\u{00FC}r: \(methode.geeignet_fuer.joined(separator: ", ")). \(firstSentence(methode.praxistipps))"
                ))
            }
        }

        let mitAllergenen = produkte.filter { !$0.allergene.isEmpty }
        let ohneAllergene = produkte.filter { $0.allergene.isEmpty && $0.kategorie != "Gew\u{00FC}rze" }

        let allergenGruppen: [(name: String, suchbegriff: String)] = [
            ("Milch", "Milch"), ("Fisch", "Fisch"), ("Krebstiere", "Krebstiere"),
            ("Weichtiere", "Weichtiere"), ("Sellerie", "Sellerie")
        ]

        for (allergenName, suchbegriff) in allergenGruppen {
            let betroffene = mitAllergenen.filter { $0.allergene.contains(suchbegriff) }
            guard let gefaehrlich = betroffene.randomElement() else { continue }
            let sichere = ohneAllergene.shuffled().prefix(3).map { $0.name }
            guard sichere.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Ein Gast hat eine \(allergenName)-Allergie. Welches Produkt darfst du NICHT verwenden?",
                correct: gefaehrlich.name,
                wrong: Array(sichere),
                erklaerung: "\(gefaehrlich.name) enth\u{00E4}lt \(gefaehrlich.allergene). Bei Allergien muss dies dem Gast mitgeteilt werden (EU-Verordnung 1169/2011)."
            ))
        }

        for sauce in saucen.shuffled().prefix(10) {
            let wrong = pickRandom(from: alleSaucen, not: sauce.name, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Du brauchst eine Sauce f\u{00FC}r \u{201E}\(sauce.verwendung)\u{201C}. Welche w\u{00E4}hlst du?",
                correct: sauce.name,
                wrong: wrong,
                erklaerung: "\(sauce.name) wird klassisch verwendet f\u{00FC}r: \(sauce.verwendung)."
            ))
        }

        return questions
    }

    // MARK: - Level 19: ANWENDEN - Cross-Domain

    private static func anwendenCrossDomain(level: Int, garmethoden: [Garmethode], saucen: [Sauce]) -> [Question] {
        var questions: [Question] = []
        let alleSaucen = saucen.map { $0.name }
        let alleMethoden = garmethoden.map { $0.name }

        let mutterSaucen = saucen.filter { $0.typ.contains("Grundso\u{00DF}e") || $0.typ.contains("Mutterso\u{00DF}e") }
        for mutter in mutterSaucen {
            guard !mutter.ableitungen.isEmpty else { continue }
            var wrong = pickRandom(from: mutterSaucen.map { $0.name }, not: mutter.name, count: 3)
            for s in alleSaucen where wrong.count < 3 && s != mutter.name && !wrong.contains(s) {
                wrong.append(s)
            }
            guard wrong.count >= 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Die Ableitungen \u{201E}\(mutter.ableitungen)\u{201C} basieren auf welcher Mutterso\u{00DF}e?",
                correct: mutter.name,
                wrong: Array(wrong.prefix(3)),
                erklaerung: "\(mutter.name) (\(mutter.typ)) ist die Basis f\u{00FC}r: \(mutter.ableitungen)."
            ))
        }

        for methode in garmethoden.shuffled().prefix(12) {
            guard !methode.praxistipps.isEmpty else { continue }
            let tipp = firstSentence(methode.praxistipps)
            guard !tipp.isEmpty else { continue }
            let wrong = pickRandom(from: alleMethoden, not: methode.name, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "F\u{00FC}r welche Garmethode gilt dieser Praxistipp?\n\u{201E}\(tipp)\u{201C}",
                correct: methode.name,
                wrong: wrong,
                erklaerung: "Praxistipp f\u{00FC}r \(methode.name): \(methode.praxistipps)"
            ))
        }

        let klassiker: [(frage: String, antwort: String, erkl: String)] = [
            ("Welche Sauce ist der Klassiker zu wei\u{00DF}em Spargel?", "Hollandaise", "Hollandaise ist die klassische warme Emulsionssauce zu Spargel, Gem\u{00FC}se und Fisch."),
            ("Welche Sauce serviert man traditionell zu Eier Benedict?", "Hollandaise", "Eggs Benedict werden klassisch mit Hollandaise serviert."),
            ("Welche Sauce geh\u{00F6}rt klassisch zu gegrilltem Steak?", "B\u{00E9}arnaise", "B\u{00E9}arnaise ist die klassische Sauce zu gegrilltem oder kurzgebratenem Fleisch."),
            ("Welche Sauce ist die Basis f\u{00FC}r Lasagne?", "B\u{00E9}chamel", "Lasagne wird klassisch mit B\u{00E9}chamel und Bolognese geschichtet."),
            ("Aus welcher Sauce wird Sauce Mornay hergestellt?", "B\u{00E9}chamel", "Sauce Mornay = B\u{00E9}chamel + K\u{00E4}se (Gruy\u{00E8}re)."),
            ("Welcher Fond ist die Basis f\u{00FC}r eine Fischsuppe?", "Fumet de poisson (Fischfond)", "Fischfond wird aus Fischkarkassen und Gem\u{00FC}se hergestellt. Maximal 30 Minuten kochen!")
        ]
        for klassik in klassiker {
            let wrong = pickRandom(from: alleSaucen, not: klassik.antwort, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: klassik.frage,
                correct: klassik.antwort,
                wrong: wrong,
                erklaerung: klassik.erkl
            ))
        }

        let fonds = saucen.filter { $0.typ == "Grundfond" }
        for fond in fonds {
            var wrong = pickRandom(from: fonds.map { $0.name }, not: fond.name, count: 3)
            for s in alleSaucen where wrong.count < 3 && s != fond.name && !wrong.contains(s) {
                wrong.append(s)
            }
            guard wrong.count >= 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Du brauchst einen Fond f\u{00FC}r \u{201E}\(fond.verwendung)\u{201C}. Welchen verwendest du?",
                correct: fond.name,
                wrong: Array(wrong.prefix(3)),
                erklaerung: "\(fond.name): \(fond.verwendung). Basis: \(fond.basis)."
            ))
        }

        return questions
    }

    // MARK: - Level 20: BEWERTEN

    private static func bewerten(level: Int, produkte: [Produkt], garmethoden: [Garmethode], saucen: [Sauce]) -> [Question] {
        var questions: [Question] = []

        for methode in garmethoden {
            for nichtGeeignet in methode.nicht_geeignet_fuer.prefix(2) {
                var distractors = garmethoden
                    .filter { $0.name != methode.name }
                    .map { $0.name }
                    .shuffled()
                distractors = Array(distractors.prefix(3))
                guard distractors.count == 3 else { continue }

                questions.append(makeQ(
                    level: level,
                    text: "Welche Garmethode ist NICHT geeignet f\u{00FC}r \u{201E}\(nichtGeeignet)\u{201C}?",
                    correct: methode.name,
                    wrong: distractors,
                    erklaerung: "\(methode.name) ist nicht geeignet f\u{00FC}r \(nichtGeeignet). \(methode.name) eignet sich f\u{00FC}r: \(methode.geeignet_fuer.prefix(3).joined(separator: ", "))."
                ))
            }
        }

        let mutterSaucen = saucen.filter { $0.typ.contains("Grundso\u{00DF}e") || $0.typ.contains("Mutterso\u{00DF}e") }
        for sauce in mutterSaucen {
            guard let andere = mutterSaucen.filter({ $0.name != sauce.name }).randomElement() else { continue }

            let falscheAussage = "\(sauce.name) basiert auf \(andere.basis)"
            let richtigeAussage = "\(sauce.name) basiert auf \(sauce.basis)"
            let andereRichtige1 = "\(andere.name) basiert auf \(andere.basis)"

            let dritte = mutterSaucen.first { $0.name != sauce.name && $0.name != andere.name }
            let andereRichtige2 = dritte.map { "\($0.name) basiert auf \($0.basis)" }
                ?? "Roux ist eine Mehlschwitze aus Butter und Mehl"

            questions.append(makeQ(
                level: level,
                text: "Welche Aussage \u{00FC}ber Saucen ist FALSCH?",
                correct: falscheAussage,
                wrong: [richtigeAussage, andereRichtige1, andereRichtige2],
                erklaerung: "Falsch: \(falscheAussage). Richtig: \(sauce.name) basiert auf \(sauce.basis)."
            ))
        }

        for produkt in produkte.shuffled().prefix(10) {
            guard !produkt.lagerung.isEmpty else { continue }
            let richtig = shortenText(produkt.lagerung, maxLength: 70)
            let andereLagerungen = Array(Set(
                produkte
                    .filter { $0.name != produkt.name && !$0.lagerung.isEmpty && $0.lagerung != produkt.lagerung }
                    .map { shortenText($0.lagerung, maxLength: 70) }
            ))
            let wrong = pickRandom(from: andereLagerungen, count: 3)
            guard wrong.count == 3 else { continue }

            questions.append(makeQ(
                level: level,
                text: "Welche Lagerungsempfehlung ist RICHTIG f\u{00FC}r \u{201E}\(produkt.name)\u{201C}?",
                correct: richtig,
                wrong: wrong,
                erklaerung: "Richtige Lagerung von \(produkt.name): \(produkt.lagerung)"
            ))
        }

        for methode in garmethoden.shuffled().prefix(8) {
            guard let andere = garmethoden.filter({ $0.name != methode.name }).randomElement() else { continue }

            let falscheAussage = "\(methode.name) arbeitet bei \(andere.temperatur) mit \(andere.medium)"
            let richtigeAussage = "\(methode.name) arbeitet bei \(methode.temperatur) mit \(methode.medium)"
            let andereRichtige = "\(andere.name) arbeitet bei \(andere.temperatur) mit \(andere.medium)"

            let dritte = garmethoden.first { $0.name != methode.name && $0.name != andere.name }
            let dritteRichtige = dritte.map { "\($0.name) arbeitet bei \($0.temperatur) mit \($0.medium)" }
                ?? "Beim Kochen gehen N\u{00E4}hrstoffe ins Wasser \u{00FC}ber"

            questions.append(makeQ(
                level: level,
                text: "Welche Aussage \u{00FC}ber Garmethoden ist FALSCH?",
                correct: falscheAussage,
                wrong: [richtigeAussage, andereRichtige, dritteRichtige],
                erklaerung: "Falsch: \(falscheAussage). Richtig: \(methode.name) arbeitet bei \(methode.temperatur) mit \(methode.medium)."
            ))
        }

        return questions
    }

    // MARK: - Hilfsfunktionen

    private static func makeQ(level: Int, text: String, correct: String, wrong: [String], erklaerung: String) -> Question {
        Question(
            level: level,
            text: text,
            answers: [correct] + Array(wrong.prefix(3)),
            correctIndex: 0,
            erklaerung: erklaerung
        )
    }

    private static func pickRandom(from pool: [String], not excluded: String, count: Int = 3) -> [String] {
        let unique = Array(Set(pool.filter { $0 != excluded }))
        return Array(unique.shuffled().prefix(count))
    }

    private static func pickRandom(from pool: [String], count: Int = 3) -> [String] {
        let unique = Array(Set(pool))
        return Array(unique.shuffled().prefix(count))
    }

    private static func firstSentence(_ text: String) -> String {
        var searchStart = text.startIndex
        while searchStart < text.endIndex {
            guard let dotRange = text[searchStart...].range(of: ".") else { break }
            let dotIndex = dotRange.lowerBound
            let distance = text.distance(from: text.startIndex, to: dotIndex)

            if distance >= 20 {
                return String(text[text.startIndex...dotIndex])
            }
            searchStart = text.index(after: dotIndex)
        }

        if text.count > 100 {
            let index = text.index(text.startIndex, offsetBy: 100)
            return String(text[..<index]) + "\u{2026}"
        }
        return text
    }

    private static func shortenText(_ text: String, maxLength: Int) -> String {
        if text.count <= maxLength { return text }
        let index = text.index(text.startIndex, offsetBy: maxLength)
        return String(text[..<index]) + "\u{2026}"
    }

    private static func simplifyGarmethodenTyp(_ typ: String) -> String {
        if typ.contains("Feuchte") || typ.contains("vakuumiert") { return "Feuchte Garmethode" }
        if typ.contains("Trockene") { return "Trockene Garmethode" }
        if typ.contains("Kombiniert") { return "Kombinierte Garmethode" }
        if typ.contains("Kalte") || typ.contains("Marinieren") { return "Kalte Garmethode" }
        if typ.contains("Konservierung") { return "Konservierung" }
        return typ
    }
}
