//
//  Constants.swift
//  SearchMonster
//
//  Created by Hayne Park on 8/16/17.
//  Copyright © 2017 Alexander Bui. All rights reserved.
//

import Foundation

/* TODO: Try struct format for constants */
struct Constants {
    
    // MARK: Google
    struct Google {
        static let APIBaseURL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        static let APIBasePhotoURL = "https://maps.googleapis.com/maps/api/place/photo"
    }
    
    // MARK: Apple Parameter Keys
    struct GoogleParameterKeys {
        static let query = "query"
        static let key = "key"
        static let reference = "photoreference"
        static let maxwidth = "maxwidth"
    }
    
    // MARK: Google Parameter Values
    struct GoogleParameterValues {
        static let key = "AIzaSyAVkeAY1MT6Bfz5Ob5AvF39tEKNV5qJMgA"
    }
    
}
