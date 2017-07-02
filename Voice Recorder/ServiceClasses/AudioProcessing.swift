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
        
        let  timeInterval = TimeInterval(CMTimeGetSeconds(audioDuration))
        return DateTimeService().getDurationStringFromTimeInterval(timeInterval)
    }
}
