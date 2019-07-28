//
//  DetailViewController.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 24/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func configureView() {
        // Update the user interface for the detail item.
        guard track != nil else { return }
        
        titleLabel.text = track!.trackName
        genreLabel.text = track!.primaryGenreName
        priceLabel.text = "\(track!.trackPrice)"
        let fullPath: String = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(track!.localArtworkPath!).path
        trackImageView.image = UIImage(contentsOfFile: fullPath)
        descriptionLabel.text = track!.trackLongDescription
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var track: Track? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

