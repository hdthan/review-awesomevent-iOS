//
//  Notification.swift
//  aEvents
//
//  Created by jenkin on 3/7/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

struct Notification {
    let type: String
    var startTime: String
    var location: String
    var topicName: String
    var typeStatus: String
    var title: String
    var message: String
    var eventId: String
    let date: Date
    
    init(dictionary: [String: AnyObject]) {
        location = (dictionary["location"] as? String) ?? ""
        topicName = (dictionary["topic_name"] as? String) ?? ""
        type = (dictionary["type_broadcast"] as? String) ?? ""
        startTime = (dictionary["start_time"] as? String) ?? ""
        typeStatus = (dictionary["type_status"] as? String) ?? ""
        title = (dictionary["title"] as? String) ?? ""
        message = (dictionary["message"] as? String) ?? ""
        eventId = (dictionary["event_id"] as? String) ?? ""
        date = Date()
    }
    
}
