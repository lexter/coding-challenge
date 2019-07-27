//
//  Track+CoreDataProperties.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 24/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//
//

import Foundation
import CoreData

extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var artworkUrl30: String?
    @NSManaged public var artworkUrl60: String?
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var trackName: String?
    @NSManaged public var primaryGenreName: String?
    @NSManaged public var contentAdvisoryRating: String?
    @NSManaged public var currency: String?
    @NSManaged public var localArtworkPath: String?
    @NSManaged public var isDownloadingArtwork: Bool
    @NSManaged public var trackLongDescription: String?
    @NSManaged public var trackShortDescription: String?
    @NSManaged public var trackId: Int64
    @NSManaged public var artistName: String?
    @NSManaged public var trackViewUrl: String?
    @NSManaged public var previewUrl: String?
    @NSManaged public var trackPrice: Double
    @NSManaged public var trackRentalPrice: Double
    @NSManaged public var collectionPrice: Double
    @NSManaged public var collectionHdPrice: Double
    @NSManaged public var trackHdPrice: Double
    @NSManaged public var trackHdRentalPrice: Double
    @NSManaged public var releaseDate: NSDate?

}

/// Utils
extension Track {
    
    
    /// Taken from https://stackoverflow.com/questions/38985660/mirror-not-working-in-swift-when-iterating-through-children-of-an-objective-c-ob/38987424#38987424
    /// - return [String]
    func properties() -> [String] {
        var outCount : UInt32 = 0
        let properties = class_copyPropertyList(Track.self, &outCount)
        var props: [String] = []
        
        for i : UInt32 in 0..<outCount
        {
            let strKey : NSString? = NSString(cString: property_getName(properties![Int(i)]), encoding: String.Encoding.utf8.rawValue)
            props.append(strKey! as String)
        }
        
        return props
    }
    
    func mapData(_ data: [String: Any]) {
        for key in self.properties() {
            switch (key) {
                case "trackShortDescription": self.setValue(data["shortDescription"], forKey: key)
                case "trackLongDescription": self.setValue(data["longDescription"], forKey: key)
                case "releaseDate":
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    self.setValue(dateFormatter.date(from: data["releaseDate"] as! String)! as NSDate, forKey: key)
                case "localArtworkPath": continue
                case "isDownloadingArtwork": self.setValue(false, forKey: key)
                default: self.setValue(data[key], forKey: key)
            }
        }
    }
    
}
