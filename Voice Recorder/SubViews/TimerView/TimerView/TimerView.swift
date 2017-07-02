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
        let elapsedTime: TimeInterval = currentTime - startTime
 
        timerLabel.text = DateTimeService().getDurationStringFromTimeInterval(elapsedTime)
    }
    
}
