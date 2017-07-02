//
//  EffectsViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/19/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit
import AVFoundation


class AddEffectsViewController: UIViewController {
    
    @IBOutlet weak var playNavBtnItem: UIBarButtonItem!
    
    //Sliders
    @IBOutlet weak var echoSlider: UISlider!
    @IBOutlet weak var distortionSlider: UISlider!
    @IBOutlet weak var hallSlider: UISlider!
    @IBOutlet weak var smallRoomSlider: UISlider!
    
    var fileName: String!
    
    var audioEngine: AVAudioEngine?
    var audioFile: AVAudioFile?
    var buffer: AVAudioPCMBuffer?
    
    //AudioPlayerNodes
    var normalPlayerNode = AVAudioPlayerNode()                     //normal
    var echoPlayerNode = AVAudioPlayerNode()                       //echo
    var distortionPlayerNode = AVAudioPlayerNode()                     //reverb
    var hallPlayerNode = AVAudioPlayerNode()                     //hall
    var smallRoomPlayerNode = AVAudioPlayerNode()                     //hall
    
    //AudioPlayerNodes volumes
    var normalPlayerNodeVolume: Float!
    var echoPlayerNodeVolume: Float!
    var distortionPlayerNodeVolume: Float!
    var hallPlayerNodeVolume: Float!
    var smallRoomPlayerNodeVolume: Float!
    
    var showAlertService: ShowAlertAndLoaderService!
    let documentsDirectoryService = DocumentsDirectoryService()
    
    static func getInstanceForFileName(_ fileName: String) -> AddEffectsViewController {
        
        let effectsViewController = AddEffectsViewController.init(nibName: "AddEffectsViewController", bundle: Bundle.init(for: RecordViewController.self))
        effectsViewController.fileName = fileName
        return effectsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        showAlertService = ShowAlertAndLoaderService.init(onViewController: self)
        
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
        
        //Reset distortion effect
        distortionPlayerNodeVolume = 0.0
        distortionPlayerNode.volume = 0.0
        distortionSlider.setValue(0.0, animated: true)
        
        //Reset hall effect
        hallPlayerNodeVolume = 0.0
        hallPlayerNode.volume = 0.0
        hallSlider.setValue(0.0, animated: true)
        
        //Reset small room effect
        smallRoomPlayerNodeVolume = 0.0
        smallRoomPlayerNode.volume = 0.0
        smallRoomSlider.setValue(0.0, animated: true)
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
        
        if playNavBtnItem.tag == 0 {
            playAudio()
        }else{
            stopAudio()
        }
    }
    
    func playAudio() {
        
        if reInitializeAudioEngine() {
            playAllAudioPlayerNodes()
            playNavBtnItem.tag = 1
            playNavBtnItem.image = UIImage(named: "Stop")
            
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
            
            distortionPlayerNode = AVAudioPlayerNode()
            distortionPlayerNode.volume = distortionPlayerNodeVolume
            
            hallPlayerNode = AVAudioPlayerNode()
            hallPlayerNode.volume = hallPlayerNodeVolume
            
            smallRoomPlayerNode = AVAudioPlayerNode()
            smallRoomPlayerNode.volume = smallRoomPlayerNodeVolume
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
        attachDistortionEffectToAudioEngine(audioEngine!, buffer: buffer)
        attachHallEffectToAudioEngine(audioEngine!, buffer: buffer)
        attachSmallRoomEffectToAudioEngine(audioEngine!, buffer: buffer)
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
    
    func attachDistortionEffectToAudioEngine(_ audioEngine: AVAudioEngine,  buffer: AVAudioPCMBuffer) {
        
        let distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(.speechCosmicInterference)
        distortion.preGain = -2
        distortion.wetDryMix = 100
        
        audioEngine.attach(distortionPlayerNode)
        audioEngine.attach(distortion)
        audioEngine.connect(distortionPlayerNode, to:distortion, format: buffer.format)
        audioEngine.connect(distortion, to:audioEngine.mainMixerNode, format:buffer.format)
        distortionPlayerNode.scheduleBuffer(buffer, at:nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
    }
    
    func attachHallEffectToAudioEngine(_ audioEngine: AVAudioEngine,  buffer: AVAudioPCMBuffer) {
        
        let hall = AVAudioUnitReverb()
        hall.loadFactoryPreset(.largeHall)
        hall.wetDryMix = 100
        
        audioEngine.attach(hallPlayerNode)
        audioEngine.attach(hall)
        audioEngine.connect(hallPlayerNode, to:hall, format: buffer.format)
        audioEngine.connect(hall, to:audioEngine.mainMixerNode, format:buffer.format)
        hallPlayerNode.scheduleBuffer(buffer, at:nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
    }
    
    func attachSmallRoomEffectToAudioEngine(_ audioEngine: AVAudioEngine,  buffer: AVAudioPCMBuffer) {
        
        let smallRoom = AVAudioUnitReverb()
        smallRoom.loadFactoryPreset(.smallRoom)
        smallRoom.wetDryMix = 100
        
        audioEngine.attach(smallRoomPlayerNode)
        audioEngine.attach(smallRoom)
        audioEngine.connect(smallRoomPlayerNode, to:smallRoom, format: buffer.format)
        audioEngine.connect(smallRoom, to:audioEngine.mainMixerNode, format:buffer.format)
        smallRoomPlayerNode.scheduleBuffer(buffer, at:nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
    }
    
    func playAllAudioPlayerNodes() {
        
        normalPlayerNode.play()
        echoPlayerNode.play()
        distortionPlayerNode.play()
        hallPlayerNode.play()
        smallRoomPlayerNode.play()
    }
    
    func stopAudio() {
        
        stopAllAudioPlayerNodes()
        playNavBtnItem.tag = 0
        playNavBtnItem.image = UIImage(named: "Play")
    }
    
    func stopAllAudioPlayerNodes() {
        
        normalPlayerNode.stop()
        echoPlayerNode.stop()
        distortionPlayerNode.stop()
        hallPlayerNode.stop()
        smallRoomPlayerNode.stop()
    }
    
    @IBAction func echoSliderValueChanged(_ sender: Any) {
        
        echoPlayerNodeVolume = echoSlider.value
        echoPlayerNode.volume = echoPlayerNodeVolume
        normalPlayerNode.volume = 1 - echoPlayerNodeVolume - distortionPlayerNodeVolume - hallPlayerNodeVolume - smallRoomPlayerNodeVolume
    }
    
    @IBAction func distortionSliderValueChanged(_ sender: Any) {
        
        distortionPlayerNodeVolume = distortionSlider.value
        distortionPlayerNode.volume = distortionPlayerNodeVolume
        normalPlayerNode.volume = 1 - distortionPlayerNodeVolume - echoPlayerNodeVolume - hallPlayerNodeVolume - smallRoomPlayerNodeVolume
    }
    
    @IBAction func hallSliderValueChanged(_ sender: Any) {
        
        hallPlayerNodeVolume = hallSlider.value
        hallPlayerNode.volume = hallPlayerNodeVolume
        normalPlayerNode.volume = 1 - hallPlayerNodeVolume - echoPlayerNodeVolume - distortionPlayerNodeVolume - smallRoomPlayerNodeVolume
    }
    
    @IBAction func smallRoomSliderValueChanged(_ sender: Any) {
        
        smallRoomPlayerNodeVolume = smallRoomSlider.value
        smallRoomPlayerNode.volume = smallRoomPlayerNodeVolume
        normalPlayerNode.volume = 1 - smallRoomPlayerNodeVolume - echoPlayerNodeVolume - distortionPlayerNodeVolume - hallPlayerNodeVolume
    }
    
    @IBAction func saveNavBtnItemAction(_ sender: Any) {
        
        saveAudioEffects()
    }
    
    func saveAudioEffects() {
        
        if audioEngine != nil {
            
            if playNavBtnItem.tag == 1 {
                stopAudio()
            }
            
            if reInitializeAudioEngine() {
                showAlertService.addLoader()
                playAllAudioPlayerNodes()
                
                let newAudio = try! AVAudioFile(forWriting: documentsDirectoryService.createFileURLWithFileName(fileName), settings: [AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                                                                                                                                      AVEncoderBitRateKey: 16,                                                                         AVNumberOfChannelsKey: 2,                                                    AVSampleRateKey: 44100.0])
                
                let length = self.audioFile!.length
                audioEngine!.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(audioFile!.length), format: self.audioEngine!.mainMixerNode.outputFormat(forBus: 0)) {
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
                        
                        
                        DispatchQueue.main.async {
                            self.stopAllAudioPlayerNodes()
                            self.audioEngine!.stop()
                            self.showAlertService.removeLoaderView()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else {
                showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to save effects. Please try again.", actionTitle: "Ok")
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
