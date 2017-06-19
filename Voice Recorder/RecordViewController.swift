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
    
    @IBOutlet weak var recordAndStopBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpRecorder()
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
            let newDateTimeFileName = getNewDateTimeFileName()
            try soundRecorder = AVAudioRecorder.init(url: getFileURLWithFileName(newDateTimeFileName), settings: recordSettings)
            fileName = newDateTimeFileName
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print("Something went wrong while setting up recorder.")
        }
    }
    
    func getNewDateTimeFileName() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from: Date()) + ".caf"
    }
    
    func setUpPlayer(){
        
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: getFileURLWithFileName(fileName!))
            
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            
            print("Something went wrong while settingup player.")
        }
    }
    
    private func getFileURLWithFileName(_ fileName: String) -> URL{
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        print(fileURL!)
        return fileURL!
        
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
            setUpPlayer()
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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let effectsViewController = segue.destination as? EffectsViewController {
            
            
        }
    }
}

