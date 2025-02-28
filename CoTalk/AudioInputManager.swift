//
//  AudioInputManager.swift
//
//  Created by Majid Jamali with ❤️ on 2/27/25.
//
//

import AVFoundation

class AudioInputManager: NSObject {
    
    var buffer: AVAudioPCMBuffer? = nil
    var audioTime: AVAudioTime? = nil
    var volume: Float = 0.0
    
    private let audioEngine = AVAudioEngine()
    private let mixerNode = AVAudioMixerNode()
    
    func startBuffering() {
        configureAudioEngine()
    }
    
    private func configureAudioEngine() {
        // Get the native audio format of the engine's input bus.
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        
        // Set an output format compatible with ShazamKit.
        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)
        
        // Create a mixer node to convert the input.
        audioEngine.attach(mixerNode)
        
        // Attach the mixer to the microphone input and the output of the audio engine.
        audioEngine.connect(audioEngine.inputNode, to: mixerNode, format: inputFormat)
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: outputFormat)
        
        // Install a tap on the mixer node to capture the microphone audio.
        mixerNode.installTap(onBus: 0, bufferSize: 8192, format: outputFormat) { [weak self] buffer, audioTime in
            
            // mixer buffer and audio time
            self?.buffer = buffer
            self?.audioTime = audioTime
            self?.volume = self?.getVolume(from: buffer, bufferSize: 8192) ?? 0.0
            print(self?.volume)
        }
        
        try? audioEngine.start()
    }
    
    private func getVolume(from buffer: AVAudioPCMBuffer, bufferSize: Int) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else {
            return 0.0
        }
        
        let channelDataArray = Array(UnsafeBufferPointer(start:channelData, count: bufferSize))
        
        var outEnvelope = [Float]()
        var envelopeState:Float = 0
        let envConstantAtk:Float = 0.16
        let envConstantDec:Float = 0.003
        
        for sample in channelDataArray {
            let rectified = abs(sample)
            
            if envelopeState < rectified {
                envelopeState += envConstantAtk * (rectified - envelopeState)
            } else {
                envelopeState += envConstantDec * (rectified - envelopeState)
            }
            outEnvelope.append(envelopeState)
        }
        // 0.007 is the low pass filter to prevent
        // getting the noise entering from the microphone
        if let maxVolume = outEnvelope.max(),
           maxVolume > Float(0.015) {
            return maxVolume
        } else {
            return 0.0
        }
    }
}
