//
//  Feedback.swift
//  aEvents
//
//  Created by jenkin on 3/29/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

struct Feedback {
    
    let id: Int
    let content: String
    let sendDate: Double
    
    init(dictionary: [String: AnyObject]) {
        id = (dictionary["id"] as? Int) ?? 1
        content = (dictionary["content"] as? String) ?? ""
        sendDate = (dictionary["sendDate"] as? Double) ?? 0
    }

}
