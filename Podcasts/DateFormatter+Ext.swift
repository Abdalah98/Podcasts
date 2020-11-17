//
//  DateFormatter+Ext.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/4/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import Foundation

extension Date{
    func convertDate()->String{
        let dateFormattter          = DateFormatter()
        dateFormattter.dateFormat   = "MMM dd, yyyy"
        return dateFormattter.string(from: self)
    }
}
