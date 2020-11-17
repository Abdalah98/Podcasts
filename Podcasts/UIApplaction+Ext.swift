//
//  UIApplaction+Ext.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/7/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit
extension UIApplication {
    static func mainTabaBarController()-> MainTabBarController?{
        return shared.windows.filter { $0.isKeyWindow }.first?.rootViewController as? MainTabBarController

    }
}
