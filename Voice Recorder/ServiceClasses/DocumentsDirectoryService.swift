//
//  DocumentsDirectoryService.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/21/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

class DocumentsDirectoryService {
    
    func getPathURL() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
    func createFileURLWithFileName(_ fileName: String) -> URL{
        
        let fileURL = getPathURL().appendingPathComponent(fileName)
        print(fileURL)
        return fileURL
    }
    
    func getSearchPath() -> String? {
        
        let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return searchPath
    }
    
    func getAllFileNames() -> [String]? {
        
        if let searchPath = getSearchPath() {
            return try? FileManager.default.contentsOfDirectory(atPath: searchPath)
        }
        return nil
    }
    
    func getAllRecordingAudioFiles(isAccending:Bool) -> [AudioFile]? {
        
        if let fileNames = getAllFileNames() {
            var audioFiles = [AudioFile]()
            for fileName in fileNames {
                
                if let searchPathURL = getSearchFilePathURLForFileName(fileName){
                    let audioFile = AudioFile.init(name: fileName)
                    audioFile.fileURL = searchPathURL
                    audioFile.duration = AudioProcessing().getDurationOfAudioFileWithURL(searchPathURL)
                    audioFiles.append(audioFile)
                }
            }
            
            if isAccending == true {
                return audioFiles.sorted{$0.name < $1.name}
            }else {
                return audioFiles.sorted{$0.name > $1.name}
            }
        }
        return nil
    }
    
    func deleteFileOfFileName(_ fileName: String) -> Bool {
        
        print("Deleting fileof Filename: \(fileName)")
        if let searchFilePathURL = getSearchFilePathURLForFileName(fileName) {
            
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: searchFilePathURL)
                return true
            }
            catch {
                return false
            }
        }
        return false
    }
    
    func getSearchFilePathURLForFileName(_ fileName: String) -> URL? {
        
        if let searchPath = getSearchPath() {
            
            return URL(fileURLWithPath: searchPath).appendingPathComponent(fileName)
        }
        return nil
    }
    
    func getFileOfFileName(_ fileName: String) {
        
        print("Getting file of Filename: \(fileName)")
    }
}
