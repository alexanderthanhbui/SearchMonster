//
//  PlaceObject.swift
//  SearchMonster
//
//  Created by Hayne Park on 8/16/17.
//  Copyright © 2017 Alexander Bui. All rights reserved.
//

import Foundation

class PlaceObject {
    
    var id: String
    var name: String
    var formattedAddress: String?
    var open: Bool?
    var photoRef: String?
    var latitude: Double?
    var longitude: Double?
   
    init(id: String, name: String, formattedAddress: String?, open: Bool?, photoRef: String?, latitude: Double?, longitude: Double?) {
        self.id = id
        self.name = name
        self.formattedAddress = formattedAddress
        self.open = open
        self.photoRef = photoRef
        self.latitude = latitude
        self.longitude = longitude
    }
}
