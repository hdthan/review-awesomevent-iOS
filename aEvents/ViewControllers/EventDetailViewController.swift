//
//  EventDetailViewController.swift
//  aEvents
//
//  Created by Dang Duc Nam on 2/6/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import Social

enum TabIndex : Int {
    case FirstChildTab = 0
    case SecondChildTab = 1
    case ThirdChildTab = 2
    case FourthChildTab = 3
    case FifthChildTab = 4
}

class EventDetailViewController: UIViewController {
    @IBOutlet fileprivate weak var lblTitle: UILabel!
    @IBOutlet fileprivate weak var mapView: GMSMapView!
    
    @IBOutlet weak var segmentedControll: TabySegmentedControl!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    
    var eventID: Int = 0
    var type: Int = 0
    var event: Event? {
        didSet {
            guard let event = event else { return }
            configure(event)
        }
    }
    
    //Views
    @IBAction func joinEventBtnClicked(_ sender: Any) {
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != ""){
            if(type == 0){
                let joinEventViewController = self.storyboard?.instantiateViewController(withIdentifier: "JoinEventViewController") as! JoinEventViewController
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                joinEventViewController.eventName = event!.eventName
                joinEventViewController.eventId = eventID
                self.navigationController?.pushViewController(joinEventViewController, animated: true)
            }
            else if(type==2){
                let ticketViewController = self.storyboard?.instantiateViewController(withIdentifier: "TicketViewController") as! TicketViewController
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                ticketViewController.eventId = eventID
                ticketViewController.eventName = event!.eventName
                self.navigationController?.pushViewController(ticketViewController, animated: true)
            }
        } else {
            let revealViewController: SWRevealViewController = self.revealViewController()
            let loginView = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let newFronViewController = UINavigationController.init(rootViewController: loginView)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
        }
    }
    
    var currentViewController: UIViewController?
    lazy var firstChildTabVC: DescriptionViewController? = {
        let firstChildTabVC: DescriptionViewController = self.storyboard?.instantiateViewController(withIdentifier: "DescriptionView") as! DescriptionViewController
        return firstChildTabVC
    }()
    lazy var secondChildTabVC : MapViewController? = {
        let secondChildTabVC: MapViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapView") as! MapViewController
        return secondChildTabVC
    }()
    lazy var topicChildTabVC: TopicViewController? = {
        let topicChildTabVC: TopicViewController = self.storyboard?.instantiateViewController(withIdentifier: "TopicView") as! TopicViewController
        return topicChildTabVC
    }()
    lazy var sponsorChildTabVC: SponsorViewController? = {
        let sponsorChildTabVC: SponsorViewController = self.storyboard?.instantiateViewController(withIdentifier: "SponsorView") as! SponsorViewController
        return sponsorChildTabVC
    }()
    lazy var speakerChildTabVC: SpeakerViewController? = {
        let speakerChildTabVC: SpeakerViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpeakerView") as! SpeakerViewController
        return speakerChildTabVC
    }()

}

//MARK: - Override
extension EventDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEvent()
        checkJoinEvent()
        //Tab bar
        segmentedControll.initUI()
        segmentedControll.selectedSegmentIndex = TabIndex.FirstChildTab.rawValue
        
        btnJoin.layer.cornerRadius = self.btnJoin.frame.size.width / 2
        btnJoin.clipsToBounds = true
        btnJoin.layer.shadowColor = UIColor.lightGray.cgColor;
        btnJoin.layer.shadowOffset = CGSize(width: 2, height: 2);
        btnJoin.layer.shadowOpacity = 1.0
        btnJoin.layer.shadowRadius = 1.0
        btnJoin.layer.masksToBounds = false;
        
        //Share
        btnShare.target = self
        btnShare.action = #selector(self.shareFB(sender:))
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkJoinEvent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    @IBAction func switchTabs(sender: UISegmentedControl) {
        guard let currentVC = self.currentViewController else {
            return
        }
        currentVC.view.removeFromSuperview()
        currentVC.removeFromParentViewController()
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
//            if (tabIndex != 0) {
//                self.view.backgroundColor = self.contentView.backgroundColor
//            }
            vc.view.frame = self.contentView.bounds
        }
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.FirstChildTab.rawValue :
            vc = firstChildTabVC
        case TabIndex.SecondChildTab.rawValue :
            vc = secondChildTabVC
        case TabIndex.ThirdChildTab.rawValue :
            vc = topicChildTabVC
        case TabIndex.FourthChildTab.rawValue :
            vc = speakerChildTabVC
        case TabIndex.FifthChildTab.rawValue:
            vc = sponsorChildTabVC
        default :
            return nil
        }
        
        return vc
    }
}

//MARK: Private
fileprivate extension EventDetailViewController {
    
    func loadEvent() {
        Services.event(eventID: eventID) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let event):
                strongSelf.event = event
            case .failure:
                //_ = strongSelf.navigationController?.popViewController(animated: false)
                strongSelf.alertConnectionFail()
            }
        }
    }
    
    func checkJoinEvent() {
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != "") {
            Services.checkJoin(eventId: eventID, token: token as String) { [weak self] result in
                guard let strongSelf = self else { return }
                
                switch result {
                case .success(let type):
                    strongSelf.type = type;
                    if(type == 0){
                        strongSelf.btnJoin.setTitle("Join", for: UIControlState.normal)
                        strongSelf.btnJoin.setImage(nil, for: UIControlState.normal)
                        strongSelf.btnJoin.layer.borderColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1).cgColor
                        strongSelf.btnJoin.layer.borderWidth = 1.0
                        strongSelf.btnJoin.layer.backgroundColor = UIColor.white.cgColor
                        
                        //                    let btnImage = UIImage(named: "icon_join")
                        //                    strongSelf.btnJoin.setImage(btnImage , for: UIControlState.normal)
                    }
                    else if(type == 1 || type == 3){
                        strongSelf.btnJoin.isHidden = true
                    }
                    else {
                        strongSelf.btnJoin.setTitle("", for: UIControlState.normal)
                        strongSelf.btnJoin.layer.borderWidth = 0.0
                        let btnImage = UIImage(named: "ticket-icon")
                        strongSelf.btnJoin.setImage(btnImage , for: UIControlState.normal)
                        strongSelf.btnJoin.layer.backgroundColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1).cgColor
                    }
                case .failure:
                    print("error")
                }
            }
        } else {
            btnJoin.setTitle("Join", for: UIControlState.normal)
            btnJoin.setImage(nil, for: UIControlState.normal)
            btnJoin.layer.borderColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1).cgColor
            btnJoin.layer.borderWidth = 1.0
            btnJoin.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    func configure(_ event: Event) {
        navigationBar.title = event.eventName
        firstChildTabVC?.event = event
        secondChildTabVC?.longitude = event.longitude
        secondChildTabVC?.latitude = event.latitude
        secondChildTabVC?.locationName = event.location
        topicChildTabVC?.topics = event.topics
        topicChildTabVC?.eventID = eventID
        sponsorChildTabVC?.sponsors = event.sponsors
        speakerChildTabVC?.speakers = event.speakers
        displayCurrentTab(TabIndex.FirstChildTab.rawValue)
    }
    
    @objc func shareFB(sender: AnyObject){
        print("\(Services.server)/event/\(event!.slug)")
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.add(URL(string: "\(Services.server)/event/\(event!.slug).html"))
            facebookSheet.setInitialText("Share on Facebook")
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}
