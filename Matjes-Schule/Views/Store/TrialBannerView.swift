//
//  TrialBannerView.swift
//  Matjes
//
//  Dezenter Banner waehrend des Free Trials: "Noch X Tage kostenlos"
//

import SwiftUI

struct TrialBannerView: View {
    var daysRemaining: Int
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)

                Text("Noch \(daysRemaining) \(daysRemaining == 1 ? "Tag" : "Tage") kostenlos")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
