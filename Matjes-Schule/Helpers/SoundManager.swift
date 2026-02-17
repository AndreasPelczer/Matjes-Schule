//
//  SoundManager.swift
//  MatjesSchule
//
//  Audio-Feedback und Haptics (portiert aus V1/V2)
//

import AVFoundation
import UIKit

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?

    enum SoundOption: String {
        case correct
        case wrong
        case applaus
        case click
    }

    func playSound(sound: SoundOption) {
        let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3")
            ?? Bundle.main.url(forResource: sound.rawValue, withExtension: "wav")
        guard let url else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            #if DEBUG
            print("Fehler beim Abspielen: \(error.localizedDescription)")
            #endif
        }
    }

    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func triggerNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
