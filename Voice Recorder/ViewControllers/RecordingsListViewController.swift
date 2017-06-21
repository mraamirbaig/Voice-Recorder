//
//  RecordingsListViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/19/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingsListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var recordingsListTableView: UITableView!
    
    var soundPlayer : AVAudioPlayer!
    var recordingsListNames = [String]()
    
    let documentsDirectoryService = DocumentsDirectoryService()
    var showAlertService: ShowAlertService!
    
    var indexPathOfPlayingCell: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        recordingsListTableView.register(UINib.init(nibName: "RecordingListCell", bundle: Bundle.init(for: RecordingListCell.self)), forCellReuseIdentifier: "RecordingListCellIdentifier")
        
        showAlertService = ShowAlertService.init(onViewController: self)
        if let recordingListNames = getRecordingListNames() {
            recordingsListNames = recordingListNames
        } 
    }
    
    func getRecordingListNames() -> [String]? {
        
        return documentsDirectoryService.getAllRecordingFileNames()
    }
    
    func reloadrecordingList() {
        
        if let recordingListNames = getRecordingListNames() {
            self.recordingsListNames = recordingListNames
            recordingsListTableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordingsListNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingListCellIdentifier", for: indexPath) as! RecordingListCell
        cell.recordingNameLbl.text = recordingsListNames[indexPath.row]
        
        if indexPathOfPlayingCell != nil {
            if indexPathOfPlayingCell == indexPath {
                cell.stopImgView.isHidden = false
            }else{
                cell.stopImgView.isHidden = true
            }
        }else{
            cell.stopImgView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPathOfPlayingCell == nil {
            setCellAsIsStopped(false, atIndexPath: indexPath)
            playRecordingAtIndexPath(indexPath)
        }else{
            if indexPathOfPlayingCell == indexPath {
                stopPlayer()
            }else{
                stopPlayer()
                playRecordingAtIndexPath(indexPath)
            }
            
        }
    }
    
    func playRecordingAtIndexPath(_ indexPath: IndexPath) {
         
        let fileName = recordingsListNames[indexPath.row]
        if setUpPlayerWithFileName(fileName) {
            indexPathOfPlayingCell = indexPath
            setCellAsIsStopped(false, atIndexPath: indexPath)
            soundPlayer.play()
        }else{
            showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to setup player. Please try again.", actionTitle: "Ok")
        }
    }
    
    func stopPlayer() {
        if indexPathOfPlayingCell != nil {
            
            setCellAsIsStopped(true, atIndexPath: indexPathOfPlayingCell!)
            indexPathOfPlayingCell = nil
            
            if soundPlayer.isPlaying {
                soundPlayer.stop()
            }
        }
    }
    
    func setUpPlayerWithFileName(_ fileName: String) -> Bool{
        
        do {
            try soundPlayer = AVAudioPlayer(contentsOf: documentsDirectoryService.getFileURLWithFileName(fileName))
            
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
            return true
        } catch {
            
            print("Something went wrong while settingup player.")
            return false
        }
    }
    
    func setCellAsIsStopped(_ isStopped: Bool, atIndexPath indexPath: IndexPath)  {
        
        let cell = recordingsListTableView.cellForRow(at: indexPath) as! RecordingListCell
        cell.stopImgView.isHidden = isStopped
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayer()
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        
    }
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
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
