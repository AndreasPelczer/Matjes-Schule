//
//  YouTubePlayerView.swift
//  Matjes
//
//  Created by Andreas Pelczer on 08.01.26.
//


//
//  YouTubePlayerView.swift
//  Matjes
//
//  Created by Senior-Entwickler (Mentor) am 08.01.26.
//

import SwiftUI
import WebKit

/// YouTubePlayerView: Bettet ein YouTube Video per WKWebView ein.
/// Fachbegriff: UIViewRepresentable - Macht alte UIKit-Views in SwiftUI nutzbar.
struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true // Wichtig für Frankfurt-Style (kein Vollbild-Zwang)
        return WKWebView(frame: .zero, configuration: configuration)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") else { return }
        uiView.scrollView.isScrollEnabled = false // Hannes soll nicht im Player rumscrollen
        uiView.load(URLRequest(url: url))
    }
}