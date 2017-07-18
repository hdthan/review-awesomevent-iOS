//
//  Event.swift
//  aEvents
//
//  Created by Dang Duc Nam on 2/3/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//
import SwiftyJSON

struct Event {
    let eventName: String
    let eventImageUrlString: String
    let eventID: Int
    let longitude: Double
    let latitude: Double
    let location: String
    let description: String
    let startTime: Double
    let endTime: Double
    let topics: [Topic]
    let sponsors: [Sponsor]
    let speakers: [Speaker]
    let slug: String
    
    init(dictionary: [String: AnyObject]) {
        eventName = (dictionary["title"] as? String) ?? ""
        eventImageUrlString = (dictionary["imageCover"] as? String) ?? ""
        eventID = (dictionary["id"] as? Int) ?? 0
        longitude = (dictionary["longitude"] as? Double) ?? 0
        latitude = (dictionary["latitude"] as? Double) ?? 0
        location = (dictionary["location"] as? String) ?? ""
        description = (dictionary["description"] as? String) ?? ""
        startTime = (dictionary["startDate"] as? Double) ?? 0
        endTime = (dictionary["endDate"] as? Double) ?? 0
        if (dictionary["topics"] == nil) {
            topics = []
        }
        else {
            let topicDictionaries = JSON(dictionary["topics"]!).arrayObject as! [[String : AnyObject]]
            topics =  topicDictionaries.map{Topic(dictionary: $0)}
        }
        if (dictionary["sponsors"] == nil) {
            sponsors = []
        }
        else {
            let sponsorDictionaries = JSON(dictionary["sponsors"]!).arrayObject as! [[String : AnyObject]]
            sponsors =  sponsorDictionaries.map{Sponsor(dictionary: $0)}
        }
        if (dictionary["speakers"] == nil) {
            speakers = []
        }
        else {
            let speakerDictionaries = JSON(dictionary["speakers"]!).arrayObject as! [[String : AnyObject]]
            speakers =  speakerDictionaries.map{Speaker(dictionary: $0)}
        }
        slug = (dictionary["slug"] as? String) ?? ""
    }
    
}
