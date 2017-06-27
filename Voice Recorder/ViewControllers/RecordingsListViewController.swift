//
//  RecordingsListViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/19/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit
import AVFoundation

struct EDIT_BTN_TITLE {
    static let EDIT = "Edit"
    static let DONE = "Done"
}

class RecordingsListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordingsListTableView: UITableView!
    
    @IBOutlet weak var editNavBtn: UIBarButtonItem!
    
    
    let audioSession = AVAudioSession.sharedInstance()
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
        self.enableDisableEditBtn()
    }
    
    
    
    func getRecordingListNames() -> [String]? {
        
        return documentsDirectoryService.getAllRecordingFileNames()
    }
    
    func enableDisableEditBtn() {
        if recordingsListNames.count == 0 {
            if editNavBtn.title == EDIT_BTN_TITLE.DONE {
                toggleEditDoneBtn()
            }
            editNavBtn.isEnabled = false
        }else{
            editNavBtn.isEnabled = true
        }
    }
    
    func reloadRecordingList() {
        
        if let recordingListNames = getRecordingListNames() {
            self.recordingsListNames = recordingListNames
            recordingsListTableView.reloadData()
        }
    }
    
    @IBAction func editNavAction(_ sender: Any) {
        
        toggleEditDoneBtn()
    }
    
    func toggleEditDoneBtn() {
        
        if editNavBtn.title == EDIT_BTN_TITLE.EDIT {
            recordingsListTableView.isEditing = true
            editNavBtn.title = EDIT_BTN_TITLE.DONE
        }else{
            recordingsListTableView.isEditing = false
            editNavBtn.title = EDIT_BTN_TITLE.EDIT
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteRowAction = UITableViewRowAction.init(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            
            if self.deleteFileOfFileName(self.recordingsListNames[indexPath.row]) {
                self.recordingsListNames.remove(at: indexPath.row)
                self.recordingsListTableView.deleteRows(at: [indexPath], with: .automatic)
                self.enableDisableEditBtn()
            }
        }
        
        let shareRowAction = UITableViewRowAction.init(style: .normal, title: "Share") { (rowAction, indexPath) in
            
            self.shareFileOfFileName(self.recordingsListNames[indexPath.row])
        }
        return [deleteRowAction,shareRowAction]
    }
    
    func deleteFileOfFileName(_ fileName: String) -> Bool {
        
        if self.documentsDirectoryService.deleteFileOfFileName (fileName) {
            return true
        }
        return false
    }
    
    func shareFileOfFileName(_ fileName: String) {
        
        if let fileURL = self.documentsDirectoryService.getSearchFilePathURLForFileName(fileName) {
            let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }else{
            showAlertService.showAlertWithAlertTitle(title: "File not found", alertMessage: "Unable to find the file. Please try again.", actionTitle: "Ok")
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
            try audioSession.setCategory(
                AVAudioSessionCategoryPlayback)
            do {
                try soundPlayer = AVAudioPlayer(contentsOf: documentsDirectoryService.createFileURLWithFileName(fileName))
                
                soundPlayer.delegate = self
                soundPlayer.prepareToPlay()
                soundPlayer.volume = 1.0
                return true
            } catch {
                
                showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to setup player. Please try again.", actionTitle: "Ok")
                return false
            }
        }
        catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
            showAlertService.showAlertWithAlertTitle(title: "Failed", alertMessage: "Failed to setup player. Please try again.", actionTitle: "Ok")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        stopPlayer()
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
