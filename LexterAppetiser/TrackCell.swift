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
        self.priceLabel?.text = "\(String(describing: self.cellData.currency)) \(self.cellData.trackPrice)"
        
        if let localArtworkPath = self.cellData.localArtworkPath {
            let fullPath: String = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(localArtworkPath)!.absoluteString
            self.trackImageView.image = UIImage(contentsOfFile: fullPath)
            return
        }
        self.trackImageView.image = UIImage(named: "Placeholder")
//        self.cellData.isDownloadingArtwork = true
    
        return
        
        if cellData.isDownloadingArtwork == false {
            let trackId = self.cellData.trackId
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = cellData.managedObjectContext
            privateContext.perform { [unowned self] in
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
                fetchRequest.predicate = NSPredicate(format: "trackId == \(trackId)")
                do {
                    let fRes = try privateContext.fetch(fetchRequest)
                    if fRes.count > 0 {
                        let trackObj = fRes.first! as! Track
//                        print("\(String(describing: trackObj.trackName)) - \(trackObj.isDownloadingArtwork)")
                        trackObj.isDownloadingArtwork = true
                        
                        if let url = URL(string: self.cellData.artworkUrl100!) {
                            
                            var filename = url.pathComponents.last!
                            let ext = filename.components(separatedBy: ".").last!
                            
                            self.defaultSession.dataTask(with: url) { [unowned self] (data, resp, error) in
                                
                                guard error == nil else {
                                    trackObj.isDownloadingArtwork = false
                                    do {
                                        try privateContext.save()
//                                        privateContext.parent?.performAndWait {
//                                            do {
//                                                try privateContext.parent?.save()
//                                            }
//                                            catch let e {
//                                                print(e)
//                                            }
//                                        }
                                    }
                                    catch let e {
                                        print(e)
                                    }
                                    DispatchQueue.main.async(execute: {
                                        self.activityView.isHidden = true
                                        self.activityView.stopAnimating()
                                    })
                                    return
                                }
                                
                                let tempDir = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
                                filename = "\(UUID().uuidString).\(ext)"
                                let targetURL = tempDir.appendingPathComponent(filename)
                                trackObj.localArtworkPath = filename
                                trackObj.isDownloadingArtwork = true
                                
                                do {
                                    try data!.write(to: targetURL)
                                    try privateContext.save()
//                                    privateContext.parent?.performAndWait {
//                                        do {
//                                            try privateContext.parent?.save()
//                                        }
//                                        catch let e {
//                                            print(e)
//                                        }
//                                    }
                                }
                                catch let e {
                                    print(e)
                                }
                                
                                DispatchQueue.main.async(execute: {
                                    self.activityView.isHidden = true
                                    self.activityView.stopAnimating()
            
//                                    guard error == nil else {
//                                        return
//                                    }
//                                    self.imageObj = UIImage(data: data!)
//                                    self.trackImageView.image = self.imageObj
                                })
                            }.resume()
                        } // END OF: if let url = URL(string: self.cellData.artworkUrl100!) {
                    }
                    do {
                        try privateContext.save()
//                        privateContext.parent?.performAndWait {
//                            do {
//                                try privateContext.parent?.save()
//                            }
//                            catch let e {
//                                print(e)
//                            }
//                        }
                    }
                    catch let e {
                        print(e)
                    }
                }
                catch {
                    print("FETCH ERROR")
                }
                
                DispatchQueue.main.async(execute: {
                    self.activityView.isHidden = false
                    self.activityView.startAnimating()
                })
            } // END OF: privateContext.perform { [unowned self] in
        } // END OF: if cellData.isDownloadingArtwork == false {
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
