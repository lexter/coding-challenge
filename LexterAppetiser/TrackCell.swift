//
//  Trackself.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 24/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//

import UIKit
import CoreData

/// A custom table view cell that renders the track info.
class TrackCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    /// Stores track instance for rendering.
    var cellData: Track!
    var defaultSession: URLSession!
    
    // MARK: - Custom Methods
    
    /// Maps the track data into the appropriate view components.
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
    
    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func downloadArtworkIfNeeded() -> URLSessionDataTask? {
        let t = self.cellData!
        
        /// If the localArtwork is already downloaded, just return immediately.
        guard t.localArtworkPath == nil else { return nil }
        
        if let url = URL(string: t.artworkUrl100!) {
            
            var filename = url.pathComponents.last!
            let ext = filename.components(separatedBy: ".").last!
            
            let task = self.defaultSession.dataTask(with: url) { (data, resp, error) in
                
                guard error == nil else {
                    t.isDownloadingArtwork = false
                    return
                }
                
                let tempDir = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
                filename = "\(UUID().uuidString).\(ext)"
                let targetURL = tempDir.appendingPathComponent(filename)
                t.localArtworkPath = filename
                t.isDownloadingArtwork = true
                
                do {
                    try data!.write(to: targetURL)
                }
                catch let e {
                    print(e)
                }
                
                DispatchQueue.main.async { [unowned self] in
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    self.activityView.stopAnimating()
                    self.activityView.isHidden = true
                    let fullPath: String = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(t.localArtworkPath!).path
                    self.trackImageView.image = UIImage(contentsOfFile: fullPath)
                }
            }
            task.resume()
            return task
            
        } // END OF: if let url = URL(string: t.artworkUrl100!) {
        return nil
    }
}
