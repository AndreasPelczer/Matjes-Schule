//
//  AnswerButton.swift
//  MatjesSchule
//
//  Created by Andreas Pelczer on 27.12.25.
//

import Foundation
import SwiftUI

struct AnswerButton: View {
    let label: String
    let text: String
    let state: ButtonState
    let action: () -> Void

    @State private var animateScale: CGFloat = 1.0
    @State private var shakeOffset: CGFloat = 0

    enum ButtonState: Equatable {
        case normal
        case correct
        case wrong
        case dimmed
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(label)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(labelColor)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(labelBackground))

                Text(text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)

                Spacer()

                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(backgroundColor)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(borderColor, lineWidth: 2)
            )
            .shadow(color: shadowColor, radius: state == .normal ? 0 : 8)
        }
        .disabled(state != .normal)
        .accessibilityLabel("Antwort \(label): \(text)")
        .accessibilityHint(state == .normal ? "Doppeltippen zum Auswählen" : "")
        .accessibilityAddTraits(state == .correct ? .isSelected : [])
        .scaleEffect(animateScale)
        .offset(x: shakeOffset)
        .padding(.horizontal)
        .onChange(of: state) { _, newState in
            switch newState {
            case .correct:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                    animateScale = 1.06
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        animateScale = 1.0
                    }
                }
            case .wrong:
                withAnimation(.default.speed(5).repeatCount(4, autoreverses: true)) {
                    shakeOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring()) {
                        shakeOffset = 0
                    }
                }
            default:
                animateScale = 1.0
                shakeOffset = 0
            }
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .normal: return Color.blue.opacity(0.3)
        case .correct: return Color.green.opacity(0.8)
        case .wrong: return Color.red.opacity(0.8)
        case .dimmed: return Color.gray.opacity(0.2)
        }
    }

    private var borderColor: Color {
        switch state {
        case .normal: return Color.white.opacity(0.3)
        case .correct: return Color.green
        case .wrong: return Color.red
        case .dimmed: return Color.gray.opacity(0.2)
        }
    }

    private var shadowColor: Color {
        switch state {
        case .correct: return Color.green.opacity(0.5)
        case .wrong: return Color.red.opacity(0.5)
        default: return Color.clear
        }
    }

    private var labelColor: Color {
        switch state {
        case .dimmed: return Color.gray
        default: return Color.white
        }
    }

    private var labelBackground: Color {
        switch state {
        case .normal: return Color.white.opacity(0.2)
        case .correct: return Color.green
        case .wrong: return Color.red
        case .dimmed: return Color.gray.opacity(0.3)
        }
    }
}
