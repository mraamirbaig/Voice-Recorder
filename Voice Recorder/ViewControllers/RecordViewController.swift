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

class RecordViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var fileName: String?
    
    let documentsDirectoryService = DocumentsDirectoryService()
    var showAlertService: ShowAlertService!
    
    @IBOutlet weak var recordAndStopBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        showAlertService = ShowAlertService.init(onViewController: self)
    }
    
    @IBAction func recordAndStopBtnAction(_ sender: Any) {
        if recordAndStopBtn.title(for: .normal) == RECORD_BTN_TITLE.RECORD{
            let newDateTimeFileName = getNewDateTimeFileName()
            if setUpRecorderWithFileName(newDateTimeFileName) {
                 fileName = newDateTimeFileName
                startRecording()
            }else{
                showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to to setup recorder. Please try again.", actionTitle: "Ok")
            }
        }else{
            stopRecording()
        }
    }
    
    func setUpRecorderWithFileName(_ fileName: String)-> Bool{
        
        let recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
            ] as [String : Any]
        do {
            
            try soundRecorder = AVAudioRecorder.init(url: documentsDirectoryService.getFileURLWithFileName(fileName), settings: recordSettings)
            
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
            return true
        } catch {
                print("Something went wrong while setting up recorder.")
            return false
        }
    }
    
    func getNewDateTimeFileName() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from: Date()) + ".caf"
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
        if fileName != nil {
            if playBtn.title(for: .normal) == PLAY_BTN_TITLE.PLAY{
                playRecordingWithFileName(fileName!)
            }else{
                stopPlaying()
            }
        }else {
            showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "There is no recent recording to play. Please record and try again.", actionTitle: "Ok")
        }
    }
    
    func playRecordingWithFileName(_ fileName: String) {
        
        if setUpPlayerWithFileName(fileName) {
            startPlaying()
        }else{
            showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to setup player. Please try again.", actionTitle: "Ok")
        }
    }
    
    func setUpPlayerWithFileName(_ fileName: String) -> Bool{
        
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: documentsDirectoryService.getFileURLWithFileName(fileName))
            
            //soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
            return true
        } catch {
            
            print("Something went wrong while settingup player.")
            return false
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
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(String(describing: error?.localizedDescription))")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordAndStopBtn.isEnabled = true
        playBtn.setTitle(PLAY_BTN_TITLE.PLAY, for: .normal)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(String(describing: error?.localizedDescription))")
    }
    
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let effectsViewController = segue.destination as? EffectsViewController {
//            
//            
//        }
//    }
}

