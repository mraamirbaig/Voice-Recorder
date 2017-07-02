//
//  TimerView.swift
//  Voice Recorder
//
//  Created by IT O on 7/2/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import UIKit

class TimerView: UIView {

    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var timerLabel: UILabel!
    
    var startTime = TimeInterval()
    var timer:Timer = Timer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);

    }
    
    func startTimer() {
        
        if (!timer.isValid) {
            let aSelector : Selector = #selector(TimerView.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
    
    func stopTimer() {
        
        timer.invalidate()
    }
    
    func updateTime() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        timerLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
}
