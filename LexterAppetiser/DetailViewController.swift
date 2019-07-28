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
    @IBOutlet weak var previewButton: UIButton!

    func configureView() {
        // Update the user interface for the detail item.
        if let t = track {
            titleLabel.text = t.trackName
            genreLabel.text = t.primaryGenreName
            priceLabel.text = "\(t.currency!)\(t.trackPrice)"
            descriptionLabel.text = t.trackLongDescription
            let fullPath: String = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(t.localArtworkPath!).path
            trackImageView.image = UIImage(contentsOfFile: fullPath)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var track: Track? {
        didSet {
            // Update the view.
//            configureView()
        }
    }


}

