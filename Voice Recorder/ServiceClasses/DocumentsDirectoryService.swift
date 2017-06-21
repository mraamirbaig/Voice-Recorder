//
//  DocumentsDirectoryService.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/21/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import Foundation


class DocumentsDirectoryService {
    
    func getPath() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
    func getFileURLWithFileName(_ fileName: String) -> URL{
        
        let fileURL = getPath().appendingPathComponent(fileName)
        print(fileURL)
        return fileURL
    }
    
    func getAllFiles() -> FileManager.DirectoryEnumerator? {
        if let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            
            let fileManager = FileManager.default
            return fileManager.enumerator(atPath: documentDirectoryPath)
        }
        return nil
    }
    
    func getAllRecordingFileNames() -> [String]? {
        
        if let files = getAllFiles() {
            var fileNames = [String]()
            while let filename = files.nextObject() {
                if let fileNameStr = filename as? String {
                    fileNames.append(fileNameStr)
                }
            }
            return fileNames
        }
        return nil
    }
}
