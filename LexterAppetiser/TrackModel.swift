//
//  TrackModel.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 24/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//

import RxSwift

import struct Foundation.URL

struct TrackModel: CustomDebugStringConvertible {
    let title: String
    let image: Foundation.URL
    let description: String
    let price: String
    let genre: String
    
    // tedious parsing part
    static func parseJSON(_ json: [AnyObject]) throws -> [TrackModel] {
        let rootArrayTyped = json.compactMap { $0 as? [AnyObject] }
        
        guard rootArrayTyped.count == 3 else {
            throw NSError(domain: "TrackModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "JSON Parse Error"])
        }
        
        let (titles, descriptions, urls) = (rootArrayTyped[0], rootArrayTyped[1], rootArrayTyped[2])
        
        let titleDescriptionAndUrl: [((AnyObject, AnyObject), AnyObject)] = Array(zip(zip(titles, descriptions), urls))
        
        return try titleDescriptionAndUrl.map { result -> TrackModel in
            let ((title, description), url) = result
            
            guard let titleString = title as? String,
                let descriptionString = description as? String,
                let urlString = url as? String,
                let URL = Foundation.URL(string: urlString) else {
                    throw NSError(domain: "TrackModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "JSON Parse Error"])
            }
            
            return TrackModel(title: titleString, description: descriptionString, URL: URL)
        }
    }
}

extension WikipediaSearchResult {
    var debugDescription: String {
        return "[\(title)](\(URL))"
    }
}
