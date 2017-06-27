//
//  DocumentsDirectoryService.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/21/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import Foundation


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
    
    func getAllFiles() -> FileManager.DirectoryEnumerator? {
        if let searchPath = getSearchPath() {
            
            let fileManager = FileManager.default
            return fileManager.enumerator(atPath: searchPath)
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
