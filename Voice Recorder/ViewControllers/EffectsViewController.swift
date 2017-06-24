//
//  EffectsViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/19/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit
import AVFoundation


class EffectsViewController: UIViewController {
    
    @IBOutlet weak var playNavBtnItem: UIBarButtonItem!
    //Sliders
    @IBOutlet weak var echoSlider: UISlider!
    
    var fileName: String!
    
    var audioEngine = AVAudioEngine()
    
    //AudioPlayerNodes
    var normalPlayerNode = AVAudioPlayerNode()                     //normal
    var echoPlayerNode = AVAudioPlayerNode()                       //echo
    
    
    var showAlertService: ShowAlertService!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showAlertService = ShowAlertService.init(onViewController: self)
        
        if fileName != nil{
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(
                AVAudioSessionCategoryPlayback)
            
            let documentsDirectoryService = DocumentsDirectoryService()
            let file = try? AVAudioFile(forReading: documentsDirectoryService.getFileURLWithFileName(fileName))
            let buffer = AVAudioPCMBuffer(pcmFormat: file!.processingFormat, frameCapacity: AVAudioFrameCount(file!.length))
            try! file!.read(into: buffer)
            
            
            let normal = AVAudioUnitReverb()
            normal.loadFactoryPreset(AVAudioUnitReverbPreset.largeHall)
            normal.wetDryMix = 0
            
            let echo = AVAudioUnitDistortion()
            echo.loadFactoryPreset(AVAudioUnitDistortionPreset.multiEcho1)
            
            
            audioEngine.attach(normalPlayerNode)
            audioEngine.attach(echoPlayerNode)
            audioEngine.attach(normal)
            audioEngine.attach(echo)
            
            audioEngine.connect(normalPlayerNode, to:normal, format: buffer.format)
            audioEngine.connect(normal, to:audioEngine.mainMixerNode, format:buffer.format)
            
            audioEngine.connect(echoPlayerNode, to:echo, format: buffer.format)
            audioEngine.connect(echo, to:audioEngine.mainMixerNode, format:buffer.format)
            
            normalPlayerNode.scheduleBuffer(buffer, at:nil, options:AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
            echoPlayerNode.scheduleBuffer(buffer, at:nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
            
            audioEngine.prepare()
            try! audioEngine.start()
        }else{
            showAlertService.showAlertWithAlertTitle(title: "Cant play", alertMessage: "No file to play.", actionTitle: "Ok")
        }
        
        resetAllEffects()
    }
    
    func resetAllEffects() {
        
        print("All effects are reset.")
        //Echo slider
        normalPlayerNode.volume = 1.0
        
        //Reset echo effect
        echoPlayerNode.volume = 0.0
        echoSlider.setValue(0.0, animated: true)
    }
    
    @IBAction func resetAllNavItemAction(_ sender: Any) {
        resetAllEffects()
    }
    
    @IBAction func playNavBtnItemAction(_ sender: Any) {
        
        togglePlayStopBtn()
    }
    
    func togglePlayStopBtn() {
        if playNavBtnItem.title == PLAY_BTN_TITLE.PLAY {
            playAudio()
        }else{
            stopAudio()
        }
    }
    
    func playAudio() {
        playAllAudioPlayerNodes()
        playNavBtnItem.title = PLAY_BTN_TITLE.STOP
    }
    
    func playAllAudioPlayerNodes() {
        try! audioEngine.start()
        normalPlayerNode.play()
        echoPlayerNode.play()
    }
    
    func stopAudio() {
        stopAllAudioPlayerNodes()
        playNavBtnItem.title = PLAY_BTN_TITLE.PLAY
    }
    
    func stopAllAudioPlayerNodes() {
        normalPlayerNode.stop()
        echoPlayerNode.stop()
    }
    
    @IBAction func echoSliderValueChanged(_ sender: Any) {
        
        let echoSliderValue = echoSlider.value
        echoPlayerNode.volume = echoSliderValue
        normalPlayerNode.volume = 1 - echoSliderValue
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
