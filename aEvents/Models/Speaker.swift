//
//  Speaker.swift
//  aEvents
//
//  Created by jenkin on 2/14/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

struct Speaker {
    let id: Int
    let name: String
    let major: String
    let avatarImage: String
    let description: String
    let email: String
    let phone: String
    let linkedIn: String
    let gender: Int
    
    init(dictionary: [String: AnyObject]){
        id = (dictionary["id"] as? Int) ?? 0
        name = (dictionary["name"] as? String) ?? ""
        major = (dictionary["major"] as? String) ?? ""
        avatarImage = (dictionary["avatar"] as? String) ?? ""
        description = (dictionary["description"] as? String) ?? ""
        email = (dictionary["email"] as? String) ?? ""
        phone = (dictionary["phone"] as? String) ?? ""
        linkedIn = (dictionary["linkedIn"] as? String) ?? ""
        gender = (dictionary["gender"] as? Int) ?? 1
    }
}
