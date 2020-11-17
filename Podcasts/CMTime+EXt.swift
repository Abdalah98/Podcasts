//
//  CMTime+EXt.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/5/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import AVKit

extension CMTime{
    func toDisplayString() ->String{
        let rawSeconds           = CMTimeGetSeconds(self)
        guard !(rawSeconds.isNaN || rawSeconds.isInfinite) else {
           return "--" // or some other default string
        }
        let totalSeconds = Int(rawSeconds)
        
        let second               = totalSeconds % 60
        let min                  = totalSeconds % ( 60 * 60 ) / 60
        let hours                = totalSeconds / 60 / 60
        let timeFormatString     = String(format: "%02d:%02d:%02d",hours,min, second)
        return timeFormatString
    }
}
