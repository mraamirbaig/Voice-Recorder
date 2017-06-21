//
//  RecordingsListViewController.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/19/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingsListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var recordingsListTableView: UITableView!
    
    var soundPlayer : AVAudioPlayer!
    var recordingsListNames = [String]()
    
    let documentsDirectoryService = DocumentsDirectoryService()
    var showAlertService: ShowAlertService!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = recordingsListNames[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        playRecordingWithFileName(recordingsListNames[indexPath.row])
    }
    
    func playRecordingWithFileName(_ fileName: String) {
        
        if setUpPlayerWithFileName(fileName) {
            soundPlayer.play()
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
     
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
