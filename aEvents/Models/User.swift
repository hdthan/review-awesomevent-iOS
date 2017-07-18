//
//  User.swift
//  aEvents
//
//  Created by jenkin on 2/20/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

struct User {
    let id: Int
    var fullName: String
    var email: String
    var birthday: Double
    var job: String
    var phone: String
    var rangeAge: String
    var gender: Int
    var address: String
    var avatar: String
    var company: String
    
    init(dictionary: [String: AnyObject]) {
        id = (dictionary["id"] as? Int) ?? 0
        fullName = (dictionary["fullName"] as? String) ?? ""
        email = (dictionary["email"] as? String) ?? ""
        birthday = (dictionary["birthday"] as? Double) ?? 0
        job = (dictionary["job"] as? String) ?? ""
        phone = (dictionary["phone"] as? String) ?? ""
        rangeAge = (dictionary["rangeAge"] as? String) ?? ""
        address = (dictionary["address"] as? String) ?? ""
        gender = (dictionary["gender"] as? Int) ?? 0
        avatar = (dictionary["avatar"] as? String) ?? ""
        company = (dictionary["company"] as? String) ?? ""
    }
    
}
