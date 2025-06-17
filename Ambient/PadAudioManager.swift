import Foundation
import AVFoundation

class PadAudioManager: ObservableObject {
    private var engine = AVAudioEngine()
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var varispeedUnits: [String: AVAudioUnitVarispeed] = [:]
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]

    @Published var tempoBPM: Double = 60 {
        didSet {
            updatePlaybackRates()
        }
    }
    
    @Published var masterGainDB: Double = 0.0 {
        didSet {
            let linear = pow(10, masterGainDB / 20)
            engine.mainMixerNode.outputVolume = Float(linear)
        }
    }

    init() {
        // engine will be started after connection setup in playLoop
    }

    func toggleLoop(for padLabel: String) {
        if let player = playerNodes[padLabel], player.isPlaying {
            stopLoop(for: padLabel)
        } else {
            playLoop(for: padLabel)
        }
    }

    private func playLoop(for padLabel: String) {
        guard let url = Bundle.main.url(forResource: padLabel, withExtension: "wav") else {
            print("Audio file \(padLabel).wav not found.")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)

            let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                          frameCapacity: AVAudioFrameCount(file.length))!
            try file.read(into: buffer)

            let player = AVAudioPlayerNode()
            let varispeed = AVAudioUnitVarispeed()
            varispeed.rate = Float(tempoBPM / 60.0)

            engine.attach(player)
            engine.attach(varispeed)

            engine.connect(player, to: varispeed, format: buffer.format)
            engine.connect(varispeed, to: engine.mainMixerNode, format: buffer.format)
            
            engine.mainMixerNode.outputVolume = Float(pow(10, masterGainDB / 20))

            player.scheduleBuffer(buffer, at: nil, options: [.loops])
            if !engine.isRunning {
                try engine.start()
            }
            player.play()

            playerNodes[padLabel] = player
            varispeedUnits[padLabel] = varispeed
            audioBuffers[padLabel] = buffer

            print("Playing \(padLabel)")
        } catch {
            print("Error playing \(padLabel): \(error.localizedDescription)")
        }
    }

    private func stopLoop(for padLabel: String) {
        if let player = playerNodes[padLabel] {
            player.stop()
            engine.detach(player)
            playerNodes.removeValue(forKey: padLabel)
        }

        if let varispeed = varispeedUnits[padLabel] {
            engine.detach(varispeed)
            varispeedUnits.removeValue(forKey: padLabel)
        }

        audioBuffers.removeValue(forKey: padLabel)
        print("Stopped \(padLabel)")
    }

    private func updatePlaybackRates() {
        for (label, varispeed) in varispeedUnits {
            varispeed.rate = Float(tempoBPM / 60.0)
            print("Updated rate for \(label) to \(varispeed.rate)")

            if let player = playerNodes[label],
               let buffer = audioBuffers[label] {

                player.stop()
                player.scheduleBuffer(buffer, at: nil, options: [.loops])
                player.play()
            }
        }
    }
}
