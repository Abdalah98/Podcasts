//
//  SearchResults.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/3/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import Foundation
struct SearchResults :Codable{
    let resultCount  :Int
    let results      :[Results]
}
