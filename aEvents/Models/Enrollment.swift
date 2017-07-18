//
//  Enrollment.swift
//  aEvents
//
//  Created by jenkin on 2/22/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Enrollment {
    let type: Int
    let enrollDate: Double
    let authCode: String
    let event: Event
    
    init(dictionary: [String: AnyObject]) {
        type = (dictionary["type"] as? Int) ?? 0
        enrollDate = (dictionary["enrollDate"] as? Double) ?? 0
        authCode = (dictionary["authCode"] as? String) ?? ""
        let eventArray = JSON(dictionary["event"]!).object as! [String : AnyObject]
        event = Event(dictionary: eventArray)
    }
}
