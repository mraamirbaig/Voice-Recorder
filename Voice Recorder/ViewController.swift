//
//  ViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/18/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit
import AVFoundation

struct RECORD_BTN_TITLE {
    static let RECORD = "Record"
    static let STOP = "Stop"
}

struct PLAY_BTN_TITLE {
    static let PLAY = "Play"
    static let STOP = "Stop"
}

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    var fileName = "demo.caf"
    
    @IBOutlet weak var recordAndStopBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpRecorder()
        setUpPlayer()
    }
    
    func setUpRecorder(){
        
        let recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ] as [String : Any]
        do {
            try soundRecorder = AVAudioRecorder.init(url: getFileURL(), settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print("Something went wrong while setting up recorder.")
        }
    }
    
    func setUpPlayer(){
        
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: getFileURL())
            
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 10.0
        } catch {
            print("Something went wrong while settingup player.")
        }
    }
    
    private func getFileURL() -> URL{
        
        let path  = getCacheDirectory()
        let filePath = URL(fileURLWithPath: path).appendingPathComponent(fileName)
        
        return filePath
    }
    
    private func getCacheDirectory() -> String {
        
        //let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask, true) as [String]
        
        return paths[0]
    }
    
    @IBAction func recordAndStopBtnAction(_ sender: Any) {
        if recordAndStopBtn.title(for: .normal) == RECORD_BTN_TITLE.RECORD{
            startRecording()
        }else{
            stopRecording()
        }
    }
    
    private func startRecording() {
        
        soundRecorder.record()
        recordAndStopBtn.setTitle(RECORD_BTN_TITLE.STOP, for: .normal)
        playBtn.isEnabled = false
    }
    
    private func stopRecording() {
        
        soundRecorder.stop()
    }
    
    @IBAction func playBtnAction(_ sender: Any) {
        
        if playBtn.title(for: .normal) == PLAY_BTN_TITLE.PLAY{
            startPlaying()
        }else{
            stopPlaying()
        }
    }
    
    private func startPlaying() {
        
        recordAndStopBtn.isEnabled = false
        playBtn.setTitle(PLAY_BTN_TITLE.STOP, for: .normal)
        soundPlayer.play()

    }
    
    private func stopPlaying() {
        
        soundPlayer.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordAndStopBtn.setTitle(RECORD_BTN_TITLE.RECORD, for: .normal)
        playBtn.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordAndStopBtn.isEnabled = true
        playBtn.setTitle(PLAY_BTN_TITLE.PLAY, for: .normal)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(String(describing: error?.localizedDescription))")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(String(describing: error?.localizedDescription))")
    }
}

