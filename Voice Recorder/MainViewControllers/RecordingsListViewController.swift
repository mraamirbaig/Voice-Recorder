//
//  RecordingsListViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/19/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingsListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var recordingsListTableView: UITableView!
    
    @IBOutlet weak var editNavBtn: UIBarButtonItem!
    
    let audioSession = AVAudioSession.sharedInstance()
    var soundPlayer : AVAudioPlayer!
    var allRecordingAudioFiles = [AudioFile]()
    var filteredRecordingAudioFiles = [AudioFile]()
    
    let documentsDirectoryService = DocumentsDirectoryService()
    var showAlertService: ShowAlertService!
    
    var searchActive : Bool = false
    var indexPathOfPlayingCell: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        recordingsListTableView.register(UINib.init(nibName: "RecordingListCell", bundle: Bundle.init(for: RecordingListCell.self)), forCellReuseIdentifier: "RecordingListCellIdentifier")
        
        showAlertService = ShowAlertService.init(onViewController: self)
        if let allRecordingAudioFiles = getAllRecordingAudioFiles() {
            self.allRecordingAudioFiles = allRecordingAudioFiles
        }
        self.enableDisableEditBtn()
    }
    
    private func getAllRecordingAudioFiles() -> [AudioFile]? {
        
        return documentsDirectoryService.getAllRecordingAudioFiles(isAccending: false)
    }
    
    func enableDisableEditBtn() {
        if allRecordingAudioFiles.count == 0 {
            if editNavBtn.title == EDIT_BTN_TITLE.DONE {
                toggleEditDoneBtn()
            }
            editNavBtn.isEnabled = false
        }else{
            editNavBtn.isEnabled = true
        }
    }
    
    func reloadRecordingList() {
        
        if let allRecordingAudioFiles = getAllRecordingAudioFiles() {
            self.allRecordingAudioFiles = allRecordingAudioFiles
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
    
    //UISearchBarDelegate methods
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        stopPlayer()
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        stopPlayer()
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        stopPlayer()
        searchBar.text = ""
        searchBar.endEditing(true)
        searchActive = false
        self.reloadRecordingList()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        stopPlayer()
//        if let allRecordingAudioFiles = getAllRecordingAudioFiles() {
//            self.allRecordingAudioFiles = allRecordingAudioFiles
//        }
//        
//        if searchText.characters.count > 0 {
//            filteredRecordingsListNames = allRecordingAudioFiles.filter({ (recordingName) -> Bool in
//                let tmp: NSString = recordingName as NSString
//                let range = tmp.range(of: searchText, options: .caseInsensitive)
//                return range.location != NSNotFound
//            })
//        }else {
//            filteredRecordingsListNames = recordingsListNames
//        }
        
        self.recordingsListTableView.reloadData()
    }
    
    //TableView delegate methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive == true {
            return filteredRecordingAudioFiles.count
        }
        return allRecordingAudioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingListCellIdentifier", for: indexPath) as! RecordingListCell
        
        let audioFile: AudioFile!
        if searchActive == true {
            audioFile = filteredRecordingAudioFiles[indexPath.row]
        } else {
            audioFile = allRecordingAudioFiles[indexPath.row]
        }
        cell.recordingNameLbl.text = audioFile.name
        cell.recordingDurationLbl.text = audioFile.duration
        
        if indexPathOfPlayingCell != nil {
            if indexPathOfPlayingCell == indexPath {
                cell.stopImgView.image = UIImage.init(named: "Stop")
            }else{
                cell.stopImgView.image = UIImage.init(named: "Play")
            }
        }else{
            cell.stopImgView.image = UIImage.init(named: "Play")
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
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        
//        let deleteRowAction = UITableViewRowAction.init(style: .destructive, title: "Delete") { (rowAction, indexPath) in
//            
//            let recordingFileNameToBeDeleted: String!
//            if self.searchActive == true {
//                recordingFileNameToBeDeleted = self.filteredRecordingsListNames[indexPath.row]
//            }else{
//                recordingFileNameToBeDeleted = self.recordingsListNames[indexPath.row]
//            }
//            
//            if self.deleteFileOfFileName(recordingFileNameToBeDeleted) {
//                if self.searchActive == true {
//                    self.filteredRecordingsListNames.remove(at: indexPath.row)
//                }else{
//                    self.recordingsListNames.remove(at: indexPath.row)
//                }
//                self.recordingsListTableView.deleteRows(at: [indexPath], with: .automatic)
//                self.enableDisableEditBtn()
//            }
//        }
//        
//        let shareRowAction = UITableViewRowAction.init(style: .normal, title: "Share") { (rowAction, indexPath) in
//            
//            let recordingFileNameToBeShared: String!
//            if self.searchActive == true {
//                recordingFileNameToBeShared = self.filteredRecordingsListNames[indexPath.row]
//            }else{
//                recordingFileNameToBeShared = self.recordingsListNames[indexPath.row]
//            }
//            
//            self.shareFileOfFileName(recordingFileNameToBeShared)
//        }
//        return [deleteRowAction,shareRowAction]
//    }
    
    func deleteFileOfFileName(_ fileName: String) -> Bool {
        
        stopPlayer()
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
        
        let fileName = allRecordingAudioFiles[indexPath.row].name
        if setUpPlayerWithFileName(fileName!) {
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
        if isStopped == false {
            cell.stopImgView.image = UIImage.init(named: "Stop")
        }else {
            cell.stopImgView.image = UIImage.init(named: "Play")
        }
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