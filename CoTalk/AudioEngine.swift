//
//  AudioEngine.swift
//
//  Created by Majid Jamali with ❤️ on 2/27/25.
//
//

import Foundation
import AVFoundation
import Combine

class AudioEngine: NSObject {
    
    var averagePower = CGFloat()
    var peakPower = CGFloat()
    var timer: Timer.TimerPublisher = Timer.publish(every: 6.0/60.0, on: .main, in: .common)
    var cancellables = Set<AnyCancellable>()
    
    private var audioRecorder: AVAudioRecorder?
    
    private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            print("access: \(granted)")
            completion(granted)
        }
    }
    
    private func startAudioRecording() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("recording.m4a")
        print("saving url: \(audioFilename)")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            guard let audioRecorder else { return }
            audioRecorder.delegate = self
            audioRecorder.record()
            audioRecorder.isMeteringEnabled = true
            self.timer.autoconnect().sink(receiveValue: { [weak self] _ in
                audioRecorder.updateMeters()
                self?.averagePower = CGFloat(audioRecorder.averagePower(forChannel: 0))
                self?.peakPower = CGFloat(audioRecorder.peakPower(forChannel: 0))
            }).store(in: &cancellables)
            
        } catch {
            print("ERROR: Failed to start recording process.")
        }
    }
    
    func stopAudioRecording() {
        audioRecorder?.stop()
        cancellables.removeAll()
        averagePower = 0.0
        peakPower = 0.0
    }
    
    func start() {
        requestMicrophonePermission { [weak self] isGranted in
            if isGranted {
                self?.startAudioRecording()
                
            }
        }
    }
}

extension AudioEngine: AVAudioRecorderDelegate {
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: (any Error)?) {
        
    }
}
