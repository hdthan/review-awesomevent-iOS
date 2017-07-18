//
//  HomeViewController.swift
//  aEvents
//
//  Created by Dang Duc Nam on 2/3/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import MapKit

class HomeViewController: UIViewController {
    @IBOutlet fileprivate weak var eventTableView: UITableView!
    @IBOutlet weak var tabBarMenu: TabySegmentedControl!
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    //for auto update when scroll
    var currentTab: Int = 0
    var currentNumber: Int = 5
    var isUpdating: Bool = false
    var isReloadEnabled = true

    @IBAction func onBtnJoinClicked(_ sender: UIButton) {
        let eventID = sender.tag
        let currentEvent = events.filter {$0.eventID == eventID}.first
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != "") {
            if(sender.currentTitle == "Join"){
                let joinEventViewController = self.storyboard?.instantiateViewController(withIdentifier: "JoinEventViewController") as! JoinEventViewController
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                joinEventViewController.eventId = eventID
                joinEventViewController.eventName = currentEvent!.eventName
                self.navigationController?.pushViewController(joinEventViewController, animated: true)
            }
            else if(sender.currentTitle == ""){
                let ticketViewController = self.storyboard?.instantiateViewController(withIdentifier: "TicketViewController") as! TicketViewController
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                ticketViewController.eventId = eventID
                ticketViewController.eventName = currentEvent!.eventName
                self.navigationController?.pushViewController(ticketViewController, animated: true)
            }
        } else {
            let revealViewController: SWRevealViewController = self.revealViewController()
            let loginView = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let newFronViewController = UINavigationController.init(rootViewController: loginView)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
        }
    }
    
    fileprivate var events: [Event] = []
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
}

//MARK: - Override
extension HomeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.requestWhenInUseAuthorization()
        
        //Close all modal if exist
        self.dismiss(animated: false, completion: nil)
        
        //Init Navigation
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        //tab Bar
        self.tabBarMenu.initUI()
        //Load Menu
        btnMenu.target = revealViewController()
        btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //Fix Height tabel cell
        eventTableView.estimatedRowHeight = 250.0
        eventTableView.rowHeight = UITableViewAutomaticDimension

        //Load events
        loadEvents()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadEvents()
        
        if(UIApplication.shared.applicationIconBadgeNumber > 0) {
            self.showNotiVC()
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNotiVC), name: NSNotification.Name(rawValue: "myNotif"), object: nil)
    }
    
    @objc func showNotiVC(){
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        let badge = UIApplication.shared.applicationIconBadgeNumber
        print(badge)
        if token != "" && badge < 0 {
            let prefs: UserDefaults = UserDefaults.standard
            prefs.removeObject(forKey: "startUpNotif")
            prefs.synchronize()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: EventDetailViewController = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
            vc.eventID = -1 * badge
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEventDetail",
            let destination = segue.destination as? EventDetailViewController,
            let blogIndex = eventTableView.indexPathForSelectedRow?.row
        {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            destination.eventID = events[blogIndex].eventID
        }
    }
    
    @IBAction func switchTabs(sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0) {
            currentTab = 0
            loadEvents()
        }
        else{
            loadNearbyEvent()
            currentTab = 1
        }

    }

}

//MARK: - Private
fileprivate extension HomeViewController {
    func loadEvents() {
        Services.events(limit: currentNumber){ [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let events):
                strongSelf.events = events
                strongSelf.eventTableView?.reloadData()
            case .failure:
                print("error")
            }
            strongSelf.isUpdating = false
            strongSelf.eventTableView.tableFooterView = nil
            strongSelf.eventTableView.tableHeaderView = nil
        }
    }
    
    func loadNearbyEvent(){
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
//            print(currentLocation)
            Services.events(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, limit: currentNumber){[weak self] result in
                guard let strongSelf = self else { return }
                
                switch result {
                case .success(let events):
                    strongSelf.events = events
                    strongSelf.eventTableView?.reloadData()
                case .failure:
                    strongSelf.events = []
                    strongSelf.eventTableView?.reloadData()
                    print("error")
                }
                strongSelf.isUpdating = false
                strongSelf.eventTableView.tableFooterView = nil
                strongSelf.eventTableView.tableHeaderView = nil
            }
        } else {
            self.events = []
            self.eventTableView?.reloadData()
            self.alertWithMessage("Please enable location to use this feature!")
        }
    }
    
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventCell.self), for: indexPath) as! EventCell
        cell.event = events[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height;
        
        let contentYoffset = scrollView.contentOffset.y;
        
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset;
        
        //Handle load more on scrolling to bottom
        if(distanceFromBottom < height && isReloadEnabled)
        {
            if(!isUpdating){
                self.isReloadEnabled = false
                //Add spinner
                let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                pagingSpinner.startAnimating()
                pagingSpinner.hidesWhenStopped = true
                self.eventTableView.tableFooterView = pagingSpinner
                
                //Load more data
                if(currentNumber <= events.count){
                    currentNumber = currentNumber + 5
                    isUpdating = true
                    if(currentTab == 0){
                        self.loadEvents()
                    }
                    else{
                        self.loadNearbyEvent()
                    }
                }
                
                //Timeout for spinner
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.eventTableView.tableFooterView = nil
                }
                
                //Timeout for next loading
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.isUpdating = false
                    self.isReloadEnabled = true
                }
            }
        }
        
        //Handle reload on scrolling to top
        if(contentYoffset < 0 && isReloadEnabled) {
            if(!isUpdating){
                isReloadEnabled = false
                
                //Load Spinner
                let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                pagingSpinner.startAnimating()
                pagingSpinner.hidesWhenStopped = true
                self.eventTableView.tableHeaderView = pagingSpinner
                
                //start update
                isUpdating = true
                if(currentTab == 0){
                    self.loadEvents()
                }
                else{
                    self.loadNearbyEvent()
                }
                
                //Timout for spinner
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.eventTableView.tableHeaderView = nil
                }
                
                //Timeout for next loading
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.isUpdating = false
                    self.isReloadEnabled = true
                }
            }
        }
    }

}
