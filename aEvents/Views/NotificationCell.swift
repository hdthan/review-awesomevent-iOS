//
//  NotificationCell.swift
//  aEvents
//
//  Created by jenkin on 3/14/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class NotificationCell : UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    
    var notification: Notification? {
        didSet {
            guard let notification = notification else { return }
            configure(notification)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblTitle.text = nil
        lblStatus.text = nil
        lblTime.text = nil
        lblDate.text = nil
    }
}


fileprivate extension NotificationCell {
    
    func configure(_ noti: Notification) {
//        lblTitle?.text = noti.title
//        lblLocation?.text = noti.location
       
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEE MMM dd, yyyy HH:mm"
        
        if(noti.type == "1"){
            lblTitle?.text = noti.title
            lblStatus.text = "Message: "+noti.message
        }
        else {
            lblTitle?.text = noti.topicName
            if(noti.typeStatus == "1"){
                let startTime = Date(timeIntervalSince1970: Double(noti.startTime)!/1000)
                lblStatus.text = "Location: \(noti.location) \r\nTime: \(dateFormatterPrint.string(from: startTime))"
            }
            else{
                lblStatus.text = "Location: \(noti.location) \r\nTopic Canceled"
            }
        }
        
//        lblStatus.text = "Status: \(dateFormatterPrint.string(from: startTime))"
        
        //receive Date time
        dateFormatterPrint.dateFormat = "EEE MMM dd"
        lblDate.text = "\(dateFormatterPrint.string(from: noti.date))"
        dateFormatterPrint.dateFormat = "HH:mm"
        lblTime.text = "\(dateFormatterPrint.string(from: noti.date))"
                
    }
}
