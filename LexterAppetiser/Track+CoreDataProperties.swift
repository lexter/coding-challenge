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
