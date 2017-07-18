//
//  EventTicketCell.swift
//  aEvents
//
//  Created by jenkin on 2/22/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class EventTicketCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var eventTitle: UILabel!
    @IBOutlet fileprivate weak var eventImage: UIImageView!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var btnTicket: UIButton!
    @IBOutlet weak var btnDetail: UIButton!
    
    var index: Int? {
        didSet{
            guard let index = index else { return }
            btnTicket.tag = index
        }
    }
    
    var enrollment: Enrollment? {
        didSet {
            guard let enrollment = enrollment else { return }
            configure(enrollment)
        }
    }
    
}

//MARK: - Override
extension EventTicketCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventTitle.text = nil
        eventTime.text = nil
        //        eventImage.kf.cancelDownloadTask()
        eventImage.image = nil
    }
    
    
    
}

//MARK: - Private
fileprivate extension EventTicketCell {
    
    func configure(_ enrollment: Enrollment) {
        eventTitle.text = enrollment.event.eventName
        let enrollDate = Date(timeIntervalSince1970: enrollment.enrollDate/1000)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE MMM dd, yyyy HH:mm"
        
        eventTime.text = "Enroll Time: \(dateFormatterPrint.string(from: enrollDate))"
        eventImage.kf.setImage(with: URL(string: "\(Services.server)\(enrollment.event.eventImageUrlString)"))
        
//        btnTicket.tag = enrollment.event.eventID
        btnDetail.tag = enrollment.event.eventID
        
        viewBackground.layer.shadowColor = UIColor.lightGray.cgColor;
        viewBackground.layer.shadowOffset = CGSize(width: 1, height: 1);
        viewBackground.layer.shadowOpacity = 1;
        viewBackground.layer.shadowRadius = 1.0;
    }
    
}
