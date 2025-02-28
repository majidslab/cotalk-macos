// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

public extension AVAudioPCMBuffer {
    /// Read the contents of the url into this buffer
    convenience init?(url: URL) throws {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        try self.init(file: file)
    }

    /// Read entire file and return a new AVAudioPCMBuffer with its contents
    convenience init?(file: AVAudioFile) throws {
        file.framePosition = 0

        self.init(pcmFormat: file.processingFormat,
                  frameCapacity: AVAudioFrameCount(file.length))

        try file.read(into: self)
    }
}

public extension AVAudioPCMBuffer {
    /// Local maximum containing the time, frame position and  amplitude
    struct Peak {
        /// Initialize the peak, to be able to use outside of AudioKit
        public init() {}
        internal static let min: Float = -10000.0
        /// Time of the peak
        public var time: Double = 0
        /// Frame position of the peak
        public var framePosition: Int = 0
        /// Peak amplitude
        public var amplitude: Float = 1
    }

    /// Find peak in the buffer
    /// - Returns: A Peak struct containing the time, frame position and peak amplitude
    func peak() -> Peak? {
        guard frameLength > 0 else { return nil }
        guard let floatData = floatChannelData else { return nil }

        var value = Peak()
        var position = 0
        var peakValue: Float = Peak.min
        let chunkLength = 512
        let channelCount = Int(format.channelCount)

        while true {
            if position + chunkLength >= frameLength {
                break
            }
            for channel in 0 ..< channelCount {
                var block = Array(repeating: Float(0), count: chunkLength)

                // fill the block with frameLength samples
                for i in 0 ..< block.count {
                    if i + position >= frameLength {
                        break
                    }
                    block[i] = floatData[channel][i + position]
                }
                // scan the block
                let blockPeak = getPeakAmplitude(from: block)

                if blockPeak > peakValue {
                    value.framePosition = position
                    value.time = Double(position) / Double(format.sampleRate)
                    peakValue = blockPeak
                }
                position += block.count
            }
        }

        value.amplitude = peakValue
        return value
    }

    // Returns the highest level in the given array
    private func getPeakAmplitude(from buffer: [Float]) -> Float {
        // create variable with very small value to hold the peak value
        var peak: Float = Peak.min

        for i in 0 ..< buffer.count {
            // store the absolute value of the sample
            let absSample = abs(buffer[i])
            peak = max(peak, absSample)
        }
        return peak
    }
}

extension AVAudioPCMBuffer {
    var rms: Float {
        guard let data = floatChannelData else { return 0 }

        let channelCount = Int(format.channelCount)
        var rms: Float = 0.0
        for i in 0 ..< channelCount {
            var channelRms: Float = 0.0
            vDSP_rmsqv(data[i], 1, &channelRms, vDSP_Length(frameLength))
            rms += abs(channelRms)
        }
        let value = (rms / Float(channelCount))
        return value
    }
}

public extension AVAudioPCMBuffer {
    func mixToMono() -> AVAudioPCMBuffer {
        let newFormat = AVAudioFormat(standardFormatWithSampleRate: format.sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: newFormat, frameCapacity: frameLength)!
        buffer.frameLength = frameLength

        let stride = vDSP_Stride(1)
        let result = buffer.floatChannelData![0]
        for channel in 0 ..< format.channelCount {
            let channelData = self.floatChannelData![Int(channel)]
            vDSP_vadd(channelData, stride, result, stride, result, stride, vDSP_Length(frameLength))
        }
        return buffer
    }
}
