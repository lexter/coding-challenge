//
//  Trackself.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 24/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//

import UIKit
import CoreData

class TrackCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    let defaultSession = URLSession(configuration: .default)
    
    var cellData: Track!
    
    func configure() {        
        self.titleLabel?.text = self.cellData.trackName
        self.genreLabel?.text = self.cellData.primaryGenreName
        self.priceLabel?.text = "\(self.cellData.currency!) \(self.cellData.trackPrice)"
        
        if let localArtworkPath = self.cellData.localArtworkPath {
            self.activityView.stopAnimating()
            self.activityView.isHidden = true
            let fullPath: String = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(localArtworkPath).path
            self.trackImageView.image = UIImage(contentsOfFile: fullPath)
            return
        }
        self.activityView.startAnimating()
        self.activityView.isHidden = false
        self.trackImageView.image = UIImage(named: "Placeholder")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
