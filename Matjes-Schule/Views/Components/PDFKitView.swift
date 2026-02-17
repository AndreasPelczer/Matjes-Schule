//
//  PDFKitView.swift
//  MatjesSchule
//
//  UIKit-Wrapper für PDFView (PDFKit)
//  Ermöglicht PDF-Darstellung in SwiftUI
//

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical

        // PDF-Dokument laden
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }

        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // Keine Updates nötig
    }
}
