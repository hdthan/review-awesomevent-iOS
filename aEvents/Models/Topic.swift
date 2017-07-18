//
//  Topic.swift
//  aEvents
//
//  Created by jenkin on 2/10/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Topic {
    
    var title: String
    var description: String
    var location: String
    var id: Int
    var startTime: Double
    var endTime: Double
    var speakers: [Speaker]
    
    init(dictionary: [String: Any]) {
        id = (dictionary["id"] as? Int) ?? 0
        title = (dictionary["title"] as? String) ?? ""
        description = (dictionary["description"] as? String) ?? ""
        location = (dictionary["location"] as? String) ?? ""
        startTime = (dictionary["startTime"] as? Double) ?? 0
        endTime = (dictionary["endTime"] as? Double) ?? 0
        if (dictionary["topicSpeakers"] == nil) {
            speakers = []
        }
        else {
            let speakerDictionaries = JSON(dictionary["topicSpeakers"]!).arrayObject as! [[String : AnyObject]]
            speakers =  speakerDictionaries.map{Speaker(dictionary: $0["speaker"] as! [String : AnyObject])}
        }
    }
    
}
