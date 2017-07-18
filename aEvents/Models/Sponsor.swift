//
//  Sponsor.swift
//  aEvents
//
//  Created by jenkin on 2/10/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

struct Sponsor {
    let id: Int
    let description: String
    let imageURL: String
    let location: String
    let name: String
    
    init(dictionary: [String:AnyObject]){
        id = (dictionary["id"] as? Int) ?? 0
        description = (dictionary["description"] as? String) ?? ""
        imageURL = (dictionary["image"] as? String) ?? ""
        location = (dictionary["location"] as? String) ?? ""
        name = (dictionary["sponsorName"] as? String) ?? ""
    }

}
