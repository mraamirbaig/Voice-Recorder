//
//  ViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/18/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    let audioSession = AVAudioSession.sharedInstance()
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var audioFile: AudioFile?
    
    var audioIsPlaying = false
    
    let documentsDirectoryService = DocumentsDirectoryService()
    var showAlertService: ShowAlertAndLoaderService!
    
    
    @IBOutlet weak var addEffectsNavBarItem: UIBarButtonItem!
    @IBOutlet weak var timerBgView: UIView!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var recordAndStopBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        showAlertService = ShowAlertAndLoaderService.init(onViewController: self)
        self.buildVoiceCirlce()
    }
    
    @IBAction func recordAndStopBtnAction(_ sender: Any) {
        if recordAndStopBtn.tag == 0 {
            let newDateTimeFileName = getNewDateTimeFileName()
            if setUpRecorderWithFileName(newDateTimeFileName) {
                audioFile = AudioFile.init(name: newDateTimeFileName)
                startRecording()
            }else{
                showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to to setup recorder. Please try again.", actionTitle: "Ok")
            }
        }else{
            stopRecording()
        }
    }
    
    func setUpRecorderWithFileName(_ fileName: String)-> Bool{
        
        do {
            try audioSession.setCategory(
                AVAudioSessionCategoryRecord)
            
            let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                                  AVEncoderBitRateKey: 16,
                                  AVNumberOfChannelsKey: 2,
                                  AVSampleRateKey: 44100.0] as [String : Any]
            do {
                
                try soundRecorder = AVAudioRecorder.init(url: documentsDirectoryService.createFileURLWithFileName(fileName), settings: recordSettings)
                
                soundRecorder.delegate = self
                soundRecorder.prepareToRecord()
                return true
            } catch {
                print("Something went wrong while setting up recorder.")
                return false
            }
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
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
        timerView.startTimer()
        recordAndStopBtn.tag = 1
        recordAndStopBtn.setBackgroundImage(UIImage.init(named: "Stop"), for: .normal)
        
        playBtn.isEnabled = false
    }
    
    private func stopRecording() {
        
        if soundRecorder != nil {
            addEffectsNavBarItem.isEnabled = true
            if soundRecorder.isRecording == true {
                soundRecorder.stop()
                timerView.stopTimer()
            }
        }
    }
    
    @IBAction func playBtnAction(_ sender: Any) {
        if audioFile != nil {
            if playBtn.tag == 0{
                playRecordingWithFileName(audioFile!.name)
            }else{
                stopPlayer()
            }
        }else {
            showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "There is no recent recording to play. Please record and try again.", actionTitle: "Ok")
        }
    }
    
    func playRecordingWithFileName(_ fileName: String) {
        
        do {
            try audioSession.setCategory(
                AVAudioSessionCategoryPlayback)
            
            if setUpPlayerWithFileName(fileName) {
                startPlayer()
            }else{
                showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to setup player. Please try again.", actionTitle: "Ok")
            }
        }
        catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
            showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to setup player. Please try again.", actionTitle: "Ok")
        }
    }
    
    func setUpPlayerWithFileName(_ fileName: String) -> Bool{
        
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: documentsDirectoryService.createFileURLWithFileName(fileName))
            
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
            return true
        } catch {
            
            print("Something went wrong while settingup player.")
            return false
        }
    }
    
    private func startPlayer() {
        
        recordAndStopBtn.isEnabled = false
        playBtn.tag = 1
        playBtn.setBackgroundImage(UIImage.init(named: "Stop"), for: .normal)
        soundPlayer.play()
    }
    
    private func stopPlayer() {
        
        recordAndStopBtn.isEnabled = true
        playBtn.tag = 0
        playBtn.setBackgroundImage(UIImage.init(named: "Play"), for: .normal)
        if soundPlayer != nil {
            if soundPlayer.isPlaying == true {
                soundPlayer.stop()
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //recordAndStopBtn.setTitle(RECORD_BTN_TITLE.RECORD, for: .normal)
        recordAndStopBtn.tag = 0
        recordAndStopBtn.setBackgroundImage(UIImage.init(named: "Record"), for: .normal)
        playBtn.isEnabled = true
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(String(describing: error?.localizedDescription))")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        stopPlayer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(String(describing: error?.localizedDescription))")
    }
     
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        stopRecording()
        stopPlayer()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "AddEffectsViewControllerSegue" {
            if audioFile != nil {
                return true
            }else{
                showAlertService.showAlertWithAlertTitle(title: "No recording found", alertMessage: "Please record and then add effects to it.", actionTitle: "Ok")
                return false
            }
        }
        return true
    }
    
    @IBAction func showRecordingsNavItemAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "RecordingsListSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let addEffectsViewController = segue.destination as? AddEffectsViewController {
            addEffectsViewController.fileName = audioFile!.name
        }
    }
    
    @IBAction func amazonLinkBtnAction(_ sender: Any) {
    
        let amazonURL = URL(string: WEB_URLS.AMAZON_LINK)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(amazonURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(amazonURL)
        }
    }
    
    //MARK: Build Wave Cricle
    var WaveAnimationView:UIView!
    func buildVoiceCirlce(){
        
        let size = CGSize(width: 400, height: 400)
        
        let newPoint = CGPoint(x:self.timerBgView.frame.size.width / 2 - 200 , y: self.timerBgView.frame.size.height / 2 - 200)
        WaveAnimationView = UIView(frame: CGRect(origin:newPoint , size: size))
        WaveAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        WaveAnimationView.layer.cornerRadius = 200
        WaveAnimationView.backgroundColor = UIColor.clear
        WaveAnimationView.layer.borderColor = UIColor.black.cgColor
        WaveAnimationView.layer.borderWidth = 6.0
        self.timerBgView.addSubview(WaveAnimationView)
        
        self.WaveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        
    }
}

