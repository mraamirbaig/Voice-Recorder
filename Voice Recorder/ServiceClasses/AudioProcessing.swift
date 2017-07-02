//
//  AudioProcessing.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 7/1/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

class AudioProcessing {
    
    func getDurationOfAudioFileWithURL(_ url: URL) -> String {
        
        let asset = AVURLAsset.init(url: url)
        let audioDuration = asset.duration
        return durationStringFromCMTime(audioDuration, withFormat: "HH:mm:ss")
    }
    
    private func durationStringFromCMTime(_ cmTime: CMTime, withFormat format: String) -> String {
        
//        let seconds = Int(CMTimeGetSeconds(cmTime))
//
//        let intHours = timeText(from: seconds / 3600)
//        let intMinutes = timeText(from: (seconds % 3600) / 60)
//        let intSeconds = timeText(from: (seconds % 3600) % 60)
//        let intMiliSeconds = timeText(from: (seconds % 1) * 100)
//        
//        return "\(intHours):\(intMinutes):\(intSeconds):\(intMiliSeconds)"
        
        let timeInterval = TimeInterval(CMTimeGetSeconds(cmTime))
        
        let timeInteger = NSInteger(timeInterval)
        
        let ms = Int(timeInterval.truncatingRemainder(dividingBy: 1) * 100)
        let seconds = timeInteger % 60
        let minutes = (timeInteger / 60) % 60
        let hours = (timeInteger / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.2d",hours,minutes,seconds,ms)
    }
    
//    private func timeText(from int: Int) -> String {
//        return int < 10 ? "0\(int)" : "\(int)"
//    }
}
