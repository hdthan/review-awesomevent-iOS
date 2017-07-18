//
//  TopicCell.swift
//  aEvents
//
//  Created by jenkin on 2/10/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit

class TopicCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblSpeakers: UILabel!
    
    var topic: Topic? {
        didSet {
            guard let topic = topic else { return }
            configure(topic)
        }
    }
    //    var speakers: [Speaker] = []
}

//MARK: - Override
extension TopicCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblTitle.text = nil
        lblTime.text = nil
        lblLocation.text = nil
    }
    
}

//MARK: - Private
fileprivate extension TopicCell {
    
    func configure(_ topic: Topic) {
        lblTitle.text = topic.title
        let startTime = Date(timeIntervalSince1970: topic.startTime/1000)
        let endTime = Date(timeIntervalSince1970: topic.endTime/1000)
        
        let hourStart = Calendar.current.component(.hour, from: startTime)
        let minStart = Calendar.current.component(.minute, from: startTime)
        
        let hourEnd = Calendar.current.component(.hour, from: endTime)
        let minEnd = Calendar.current.component(.minute, from: endTime)
        lblTime.text = "\(convertTime(hourStart)):\(convertTime(minStart)) - \(convertTime(hourEnd)):\(convertTime(minEnd))"
        lblLocation.text = topic.location
        var speakers = ""
        for (_, speaker) in topic.speakers.enumerated() {
            speakers = (speakers != "") ? speakers + ", " + speaker.name : speaker.name
        }
        lblSpeakers.text = speakers
//        lblSpeakers.frame.size.height=0
//        lblSpeakers.isHidden = true
//        self.configBackground()
    }
    
    func configBackground(){
        viewBackground.layer.shadowColor = UIColor.lightGray.cgColor;
        viewBackground.layer.shadowOffset = CGSize(width: 1, height: 1);
        viewBackground.layer.shadowOpacity = 1;
        viewBackground.layer.shadowRadius = 1.0;
    }
    
    func convertTime(_ val: Int) -> String {
        if(val<10){
            return "0\(val)"
        }
        else{
            return "\(val)"
        }
    }
    
}
