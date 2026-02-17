//
//  FragenkatalogView.swift
//  MatjesSchule
//
//  Verwaltung eigener Fragenkataloge (Ausbilder)
//

import SwiftUI

struct FragenkatalogView: View {
    @State private var kataloge: [Fragenkatalog] = []
    @State private var showNeuenKatalog = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if kataloge.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("Keine Fragenkataloge")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Erstelle eigene Fragen f\u{00FC}r deine Sch\u{00FC}ler, zus\u{00E4}tzlich zu den Matjes-Standardfragen.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: { showNeuenKatalog = true }) {
                            Label("Neuer Katalog", systemImage: "plus.circle.fill")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    List(kataloge) { katalog in
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text(katalog.name)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                Text(katalog.beschreibung)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            if katalog.istVeroeffentlicht {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Fragenkataloge")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showNeuenKatalog = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
