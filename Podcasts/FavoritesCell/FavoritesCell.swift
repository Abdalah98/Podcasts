//
//  FavoritesCell.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/9/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit
import SDWebImage
class FavoritesCell: UICollectionViewCell {
    @IBOutlet weak var favoritesImageView: UIImageView!
    @IBOutlet weak var podcastNameLabel: UILabel!
    @IBOutlet weak var airtestNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var podcast :Results!{
        didSet{
            podcastNameLabel.text = podcast.trackName
            airtestNameLabel.text = podcast.artistName
            guard let url = URL(string: podcast.artworkUrl100 ?? "" ) else{return}
            favoritesImageView.sd_setImage(with: url, completed: nil)

        }
    }

}
