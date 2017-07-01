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
    
    func durationStringFromCMTime(_ cmTime: CMTime, withFormat format: String) -> String {
        
        let seconds = CMTimeGetSeconds(cmTime)
        let date = Date.init(timeIntervalSinceNow: seconds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
}
