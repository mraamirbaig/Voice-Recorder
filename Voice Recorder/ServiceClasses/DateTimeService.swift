//
//  DateTimeService.swift
//  Voice Recorder
//
//  Created by IT O on 7/2/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import Foundation


class DateTimeService {
    
    
    func getDurationStringFromTimeInterval(_ timeInterval: TimeInterval) -> String {
        
        let timeInteger = NSInteger(timeInterval)
        
        let ms = Int(timeInterval.truncatingRemainder(dividingBy: 1) * 100)
        let seconds = timeInteger % 60
        let minutes = (timeInteger / 60) % 60
        let hours = (timeInteger / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.2d",hours,minutes,seconds,ms)
    }
    
    //    private func timeText(from int: Int) -> String {
    //        return int < 10 ? "0\(int)" : "\(int)"
    //    }
    
}
