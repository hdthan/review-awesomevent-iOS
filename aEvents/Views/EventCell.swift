//
//  EventCell.swift
//  aEvents
//
//  Created by Dang Duc Nam on 2/3/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import UIKit
import Kingfisher

class EventCell: UITableViewCell {
    @IBOutlet fileprivate weak var eventTitle: UILabel!
    @IBOutlet fileprivate weak var eventImage: UIImageView!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var btnJoin: UIButton!
    
    var type: Int = 0
    
    var event: Event? {
        didSet {
            guard let event = event else { return }
            configure(event)
        }
    }

}

//MARK: - Override
extension EventCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventTitle.text = nil
        eventTime.text = nil
        eventLocation.text = nil
//        eventImage.kf.cancelDownloadTask()
        eventImage.image = nil
    }
    
}

//MARK: - Private
fileprivate extension EventCell {
    
    func configure(_ event: Event) {
        eventTitle.text = event.eventName
        let startTime = Date(timeIntervalSince1970: event.startTime/1000)
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE MMM dd, yyyy HH:mm"
        
        eventTime.text = "\(dateFormatterPrint.string(from: startTime))"
        eventLocation.text = event.location
        eventImage.kf.setImage(with: URL(string: "\(Services.server)\(event.eventImageUrlString)"))
        btnJoin.tag = event.eventID
        checkJoinEvent(eventID: event.eventID)
        
        //btnJoin
        btnJoin.layer.cornerRadius = self.btnJoin.frame.size.width / 2
        btnJoin.clipsToBounds = true
//        btnJoin.layer.shadowColor = UIColor.lightGray.cgColor;
//        btnJoin.layer.shadowOffset = CGSize(width: 1, height: 1);
//        btnJoin.layer.shadowOpacity = 1.0
//        btnJoin.layer.shadowRadius = 0.0
//        btnJoin.layer.masksToBounds = false;

//        btnJoin.layer.borderColor = UIColor.init(red: 0, green: 122/255, blue: 1.0 , alpha: 1.0).cgColor
        
        //Shadow background
        viewBackground.layer.shadowColor = UIColor.lightGray.cgColor;
        viewBackground.layer.shadowOffset = CGSize(width: 1, height: 1);
        viewBackground.layer.shadowOpacity = 1;
        viewBackground.layer.shadowRadius = 1.0;
    }
    
    func checkJoinEvent(eventID: Int) {
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != "") {
            Services.checkJoin(eventId: eventID, token: token as String) { [weak self] result in
                guard let strongSelf = self else { return }
                
                switch result {
                case .success(let type):
                    strongSelf.type = type;
                    strongSelf.btnJoin.tag = eventID
                    if(type == 0){
                        strongSelf.btnJoin.setTitle("Join", for: UIControlState.normal)
                        strongSelf.btnJoin.setImage(nil, for: UIControlState.normal)
                        strongSelf.btnJoin.layer.borderColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1).cgColor
                        strongSelf.btnJoin.layer.borderWidth = 1.0
                        strongSelf.btnJoin.layer.backgroundColor = UIColor.white.cgColor
                    }
                    else if(type == 1 || type == 3){
                        strongSelf.btnJoin.isHidden = true
                    }
                    else {
                        strongSelf.btnJoin.setTitle("", for: UIControlState.normal)
                        strongSelf.btnJoin.layer.borderWidth = 0.0
                        let ticketImg = UIImage.init(named: "ticket-icon")
                        strongSelf.btnJoin.setImage(ticketImg, for: UIControlState.normal)
                        strongSelf.btnJoin.layer.backgroundColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1).cgColor
                    }
                case .failure:
                    print("error")
                }
            }
        }
        else {
            self.btnJoin.setTitle("Join", for: UIControlState.normal)
            self.btnJoin.setImage(nil, for: UIControlState.normal)
            self.btnJoin.layer.borderColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1).cgColor
            self.btnJoin.layer.borderWidth = 1.0
            self.btnJoin.layer.backgroundColor = UIColor.white.cgColor
        }
    }
}
