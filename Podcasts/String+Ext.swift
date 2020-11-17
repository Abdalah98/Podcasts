//
//  String+Ext.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/4/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import Foundation
extension String{
    func toSecureHTTPS() ->String{
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
