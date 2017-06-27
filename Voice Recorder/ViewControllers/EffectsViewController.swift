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
    @IBOutlet weak var reverbSlider: UISlider!
    
    var fileName: String!
    
    var audioEngine = AVAudioEngine()
    var audioFile: AVAudioFile?
    
    //AudioPlayerNodes
    var normalPlayerNode = AVAudioPlayerNode()                     //normal
    var echoPlayerNode = AVAudioPlayerNode()                       //echo
    var reverbPlayerNode = AVAudioPlayerNode()                     //reverb
    
    
    var showAlertService: ShowAlertService!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showAlertService = ShowAlertService.init(onViewController: self)
        
        if fileName != nil{
            
            let buffer = createBufferForFileName(fileName)
            
            if buffer != nil {
                
                let audioSession = AVAudioSession.sharedInstance()
                try? audioSession.setCategory(
                    AVAudioSessionCategoryPlayback)
                setUpAudioEngineWithBuffer(buffer!)
            }
        }else{
            playNavBtnItem.isEnabled = false
            showAlertService.showAlertWithAlertTitle(title: "Cant play", alertMessage: "No file to play.", actionTitle: "Ok")
        }
        
        resetAllEffects()
    }
    
    func createBufferForFileName(_ fileName: String) -> AVAudioPCMBuffer? {
        
        let documentsDirectoryService = DocumentsDirectoryService()
        audioFile = try? AVAudioFile(forReading: documentsDirectoryService.createFileURLWithFileName(fileName))
        
        if audioFile != nil {
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: AVAudioFrameCount(audioFile!.length))
            try! audioFile!.read(into: buffer)
            
            return buffer
        }
        return nil
    }
    
    func setUpAudioEngineWithBuffer(_ buffer: AVAudioPCMBuffer) {
        
        attachNormalEffectToAudioEngine(audioEngine, buffer: buffer)
        attachEchoEffectToAudioEngine(audioEngine, buffer: buffer)
        attachReverbEffectToAudioEngine(audioEngine, buffer: buffer)
        
        audioEngine.prepare()
        try! audioEngine.start()
    }
    
    func attachNormalEffectToAudioEngine(_ audioEngine: AVAudioEngine,  buffer: AVAudioPCMBuffer) {
        
        let normal = AVAudioUnitReverb()
        normal.loadFactoryPreset(AVAudioUnitReverbPreset.largeHall)
        normal.wetDryMix = 0
        audioEngine.attach(normalPlayerNode)
        audioEngine.attach(normal)
        audioEngine.connect(normalPlayerNode, to:normal, format: buffer.format)
        audioEngine.connect(normal, to:audioEngine.mainMixerNode, format:buffer.format)
        normalPlayerNode.scheduleBuffer(buffer, at:nil, options:AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
    }
    
    func attachEchoEffectToAudioEngine(_ audioEngine: AVAudioEngine,  buffer: AVAudioPCMBuffer) {
        
        let echo = AVAudioUnitDistortion()
        echo.loadFactoryPreset(AVAudioUnitDistortionPreset.multiEcho2)
        //Adjust the settings of the Echo effect:
        echo.preGain = -2
        echo.wetDryMix = 67
        
        audioEngine.attach(echoPlayerNode)
        audioEngine.attach(echo)
        audioEngine.connect(echoPlayerNode, to:echo, format: buffer.format)
        audioEngine.connect(echo, to:audioEngine.mainMixerNode, format:buffer.format)
        echoPlayerNode.scheduleBuffer(buffer, at:nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
    }
    
    func attachReverbEffectToAudioEngine(_ audioEngine: AVAudioEngine,  buffer: AVAudioPCMBuffer) {
        
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.largeHall)
        reverb.wetDryMix = 100
        
        audioEngine.attach(reverbPlayerNode)
        audioEngine.attach(reverb)
        audioEngine.connect(reverbPlayerNode, to:reverb, format: buffer.format)
        audioEngine.connect(reverb, to:audioEngine.mainMixerNode, format:buffer.format)
        reverbPlayerNode.scheduleBuffer(buffer, at:nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudio()
    }
    
    func resetAllEffects() {
        
        print("All effects are reset.")
        //Echo slider
        normalPlayerNode.volume = 1.0
        
        //Reset echo effect
        echoPlayerNode.volume = 0.0
        echoSlider.setValue(0.0, animated: true)
        
        reverbPlayerNode.volume = 0.0
        reverbSlider.setValue(0.0, animated: true)
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
        
        normalPlayerNode.play()
        echoPlayerNode.play()
        reverbPlayerNode.play()
    }
    
    func stopAudio() {
        
        stopAllAudioPlayerNodes()
        playNavBtnItem.title = PLAY_BTN_TITLE.PLAY
    }
    
    func stopAllAudioPlayerNodes() {
        
        normalPlayerNode.stop()
        echoPlayerNode.stop()
        reverbPlayerNode.stop()
    }
    
    @IBAction func echoSliderValueChanged(_ sender: Any) {
        
        let echoSliderValue = echoSlider.value
        echoPlayerNode.volume = echoSliderValue
        
        normalPlayerNode.volume = 1 - echoSliderValue - reverbSlider.value
    }
    
    @IBAction func reverbSliderValueChanged(_ sender: Any) {
        
        let reverbSliderValue = reverbSlider.value
        reverbPlayerNode.volume = reverbSliderValue
        
        normalPlayerNode.volume = 1 - reverbSliderValue - echoSlider.value
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
