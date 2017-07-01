
//
//  AudioFile.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 7/1/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import Foundation

class AudioFile {
    
    let name: String!
    var fileURL: URL?
    var duration: String?
    
    init(name: String) {
        
        self.name = name
    }
}
