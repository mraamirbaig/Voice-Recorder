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
    
    var audioEngine: AVAudioEngine?
    var audioFile: AVAudioFile?
    var buffer: AVAudioPCMBuffer?
    
    //AudioPlayerNodes
    var normalPlayerNode = AVAudioPlayerNode()                     //normal
    var echoPlayerNode = AVAudioPlayerNode()                       //echo
    var reverbPlayerNode = AVAudioPlayerNode()                     //reverb
    
    //AudioPlayerNodes volumes
    var normalPlayerNodeVolume: Float!
    var echoPlayerNodeVolume: Float!
    var reverbPlayerNodeVolume: Float!
    
    var showAlertService: ShowAlertService!
    let documentsDirectoryService = DocumentsDirectoryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showAlertService = ShowAlertService.init(onViewController: self)
        
        if fileName != nil{
            resetAllEffects()
        }else{
            playNavBtnItem.isEnabled = false
            showAlertService.showAlertWithAlertTitle(title: "Cant play", alertMessage: "No file to play.", actionTitle: "Ok")
        }
    }
    
    func resetAllEffects() {
        
        print("All effects are reset.")
        //Echo slider
        normalPlayerNodeVolume = 1.0
        normalPlayerNode.volume = normalPlayerNodeVolume
        
        //Reset echo effect
        echoPlayerNodeVolume = 0.0
        echoPlayerNode.volume = echoPlayerNodeVolume
        echoSlider.setValue(echoPlayerNodeVolume, animated: true)
        
        //Reset reverb effect
        reverbPlayerNodeVolume = 0.0
        reverbPlayerNode.volume = 0.0
        reverbSlider.setValue(0.0, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudio()
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
        
        if reInitializeAudioEngine() {
            playAllAudioPlayerNodes()
            playNavBtnItem.title = PLAY_BTN_TITLE.STOP
        }else{
            playNavBtnItem.isEnabled = false
            showAlertService.showAlertWithAlertTitle(title: "SetUp failed", alertMessage: "Failed to setup player. Please try again later.", actionTitle: "Ok")
        }
    }
    
    func reInitializeAudioEngine() -> Bool {
        
        buffer = createBufferForFileName(fileName)
        
        if buffer != nil {
            
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(
                AVAudioSessionCategoryPlayback)
            
            audioEngine = AVAudioEngine()
            
            normalPlayerNode = AVAudioPlayerNode()
            normalPlayerNode.volume = normalPlayerNodeVolume
            
            echoPlayerNode = AVAudioPlayerNode()
            echoPlayerNode.volume = echoPlayerNodeVolume
            
            reverbPlayerNode = AVAudioPlayerNode()
            reverbPlayerNode.volume = reverbPlayerNodeVolume
            
            attachAllNodesToAudioEngineWithBuffer(buffer!)
            
            audioEngine!.prepare()
            try! audioEngine!.start()
            return true
        }
        return false
    }
    
    func createBufferForFileName(_ fileName: String) -> AVAudioPCMBuffer? {
        
        audioFile = try? AVAudioFile(forReading: documentsDirectoryService.createFileURLWithFileName(fileName))
        
        if audioFile != nil {
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: AVAudioFrameCount(audioFile!.length))
            try! audioFile!.read(into: buffer)
            
            return buffer
        }
        return nil
    }
    
    func attachAllNodesToAudioEngineWithBuffer(_ buffer: AVAudioPCMBuffer) {
        
        attachNormalEffectToAudioEngine(audioEngine!, buffer: buffer)
        attachEchoEffectToAudioEngine(audioEngine!, buffer: buffer)
        attachReverbEffectToAudioEngine(audioEngine!, buffer: buffer)
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
        
        echoPlayerNodeVolume = echoSlider.value
        echoPlayerNode.volume = echoPlayerNodeVolume
        normalPlayerNode.volume = 1 - echoPlayerNodeVolume - reverbPlayerNodeVolume
    }
    
    @IBAction func reverbSliderValueChanged(_ sender: Any) {
        
        reverbPlayerNodeVolume = reverbSlider.value
        reverbPlayerNode.volume = reverbPlayerNodeVolume
        normalPlayerNode.volume = 1 - reverbPlayerNodeVolume - echoPlayerNodeVolume
    }
    
    
    @IBAction func saveNavBtnItem(_ sender: Any) {
        
        //stopAudio()
        saveAudioEffects()
    }
    
    func saveAudioEffects() {
        
        if audioEngine != nil {
            
            if playNavBtnItem.title == PLAY_BTN_TITLE.STOP {
                stopAudio()
            }
            
            reInitializeAudioEngine()
            playAllAudioPlayerNodes()
            let newAudio = try! AVAudioFile(forWriting: documentsDirectoryService.createFileURLWithFileName(fileName), settings: [AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                                                                                                                                  AVEncoderBitRateKey: 16,
                                                                                                                                  AVNumberOfChannelsKey: 2,
                                                                                                                                  AVSampleRateKey: 44100.0])
            
            let length = self.audioFile!.length
            
            
            audioEngine!.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(audioFile!.length), format: self.audioEngine!.mainMixerNode.inputFormat(forBus: 0)) {
                (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                
                
                print(newAudio.length)
                print("=====================")
                print(length)
                print("**************************")
                
                if (newAudio.length) < length {//Let us know when to stop saving the file, otherwise saving infinitely
                    
                    do{
                        print(buffer)
                        try newAudio.write(from: buffer)
                    }catch _{
                        print("Problem Writing Buffer")
                    }
                }else{
                    self.audioEngine!.mainMixerNode.removeTap(onBus: 0)//if we dont remove it, will keep on tapping infinitely
                    
                    //DO WHAT YOU WANT TO DO HERE WITH EFFECTED AUDIO
                    self.stopAllAudioPlayerNodes()
                }
            }
        }else {
            showAlertService.showAlertWithAlertTitle(title: "", alertMessage: "Please play and test the audio before saving the effects.", actionTitle: "Ok")
        }
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
