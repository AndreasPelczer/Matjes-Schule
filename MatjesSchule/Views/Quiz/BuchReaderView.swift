//
//  BuchReaderView.swift
//  MatjesSchule
//
//  PDF-Reader für "Der junge Hering"
//

import SwiftUI
import PDFKit

struct BuchReaderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                // PDF-Reader
                if let pdfURL = Bundle.main.url(forResource: "Der_junge_Hering", withExtension: "pdf") {
                    PDFKitView(url: pdfURL)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    // Fallback wenn PDF nicht gefunden
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("Buch nicht gefunden")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Text("Die Datei 'Der_junge_Hering.pdf' konnte nicht geladen werden.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .navigationTitle("Der junge Hering")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BuchReaderView()
}
