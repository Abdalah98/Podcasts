//
//  ViewController.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/2/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    let playDetailsView         = PlayerDetailsView.initFromNib()
    
    var maximizedTopAnchorConstraint:NSLayoutConstraint!
    var minimizedTopAnchorConstraint:NSLayoutConstraint!
    var bottomAnchorConstraint:NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerDetailsView()
    }
    
    
    func minimizedPlayerDetails(){
        
        maximizedTopAnchorConstraint.isActive               = false
        bottomAnchorConstraint.constant                     = view.frame.height
        minimizedTopAnchorConstraint.isActive               = true
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            // self.tabBar.transform                            = .identity
            self.tabBar.isHidden = false
            
            self.playDetailsView.maximizedStackView.alpha   = 0
            self.playDetailsView.miniplayerView.alpha       = 1
            
            
        })
    }
    
    func maximizedPlayerDetails(episode:Episode?,playListEpisode:[Episode] = []){
        minimizedTopAnchorConstraint.isActive    =  false
        maximizedTopAnchorConstraint.isActive    = true
        maximizedTopAnchorConstraint.constant    = 0
        bottomAnchorConstraint.constant = 0
        if episode != nil{
            playDetailsView.episode              = episode
            
        }
        playDetailsView.playEpisodes = playListEpisode
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            // self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.tabBar.isHidden = true
            
            self.playDetailsView.maximizedStackView.alpha    = 1
            self.playDetailsView.miniplayerView.alpha        = 0
            
        })
    }
    
    
    fileprivate func setupPlayerDetailsView(){
        view.insertSubview(playDetailsView, belowSubview: tabBar)
        playDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint                =  playDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive       = true
        bottomAnchorConstraint =  playDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: view.frame.height)
        bottomAnchorConstraint.isActive            = true
        minimizedTopAnchorConstraint = playDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor,constant: -64 )
        playDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive    = true
        playDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive  = true
        
        
        
    }
    
}
