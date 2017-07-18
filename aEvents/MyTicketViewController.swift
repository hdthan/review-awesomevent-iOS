//
//  MyTicketViewController.swift
//  aEvents
//
//  Created by jenkin on 2/22/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import SwiftyJSON

class MyTicketViewController: UIViewController {
    
    @IBOutlet fileprivate weak var eventTableView: UITableView!
    @IBOutlet weak var tabBarMenu: TabySegmentedControl!
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    //Handle auto update
    var currentTab: Int = 0
    var currentNumber: Int = 5
    var isUpdating: Bool = false
    var isReloadEnabled: Bool = true
    
    fileprivate var enrollments: [Enrollment] = []
    
    override func viewDidLoad() {
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
        
        eventTableView.delegate = self
        eventTableView.dataSource = self
        loadMyUpcomingTickets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTicketDetail",
            let destination = segue.destination as? TicketViewController,
            let blogIndex = eventTableView.indexPathForSelectedRow?.row
        {
            destination.eventId = enrollments[blogIndex].event.eventID
            destination.eventName = enrollments[blogIndex].event.eventName
        }
    }
    
    
    @IBAction func showEventDetail(_ sender: UIButton) {
        let eventDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        eventDetailViewController.eventID = sender.tag
        self.navigationController?.pushViewController(eventDetailViewController, animated: true)
    }
    
    @IBAction func showTicketDetail(_ sender: UIButton) {
        let ticketViewController = self.storyboard?.instantiateViewController(withIdentifier: "TicketViewController") as! TicketViewController
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        ticketViewController.eventId = (enrollments[sender.tag] as Enrollment).event.eventID
        ticketViewController.eventName = (enrollments[sender.tag] as Enrollment).event.eventName
        self.navigationController?.pushViewController(ticketViewController, animated: true)
    }
    
    @IBAction func switchTabs(sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0) {
            currentTab = 0
            loadMyUpcomingTickets()
        }
        else{
            currentTab = 1
            loadExpiredTickets()
        }
        
    }
}

//MARK: - Private
fileprivate extension MyTicketViewController {
    func loadMyUpcomingTickets() {
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        Services.getUpcomingTicket(limit: currentNumber, token: token as String) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let enrollments):
                strongSelf.enrollments = enrollments
                strongSelf.eventTableView?.reloadData()
            case .failure:
                guard let value = UserDefaults.standard.value(forKey: "LiveTicket") as? NSArray,
                    let enrollmentsArray = JSON(value).arrayObject as? [[String: AnyObject]] else {
                        return
                }
                
                strongSelf.enrollments = enrollmentsArray.map {(enrollment:[String:AnyObject]) -> Enrollment in Enrollment(dictionary: enrollment) }
                strongSelf.eventTableView?.reloadData()
                print("Use offline data")
            }
            strongSelf.isUpdating = false
            strongSelf.eventTableView.tableFooterView = nil
        }
    }
    
    func loadExpiredTickets() {
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        Services.getExpiredTicket(limit: currentNumber, token: token as String) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let enrollments):
                strongSelf.enrollments = enrollments
                strongSelf.eventTableView?.reloadData()
            case .failure:
                guard let value = UserDefaults.standard.value(forKey: "PassTicket") as? NSArray,
                    let enrollmentsArray = JSON(value).arrayObject as? [[String: AnyObject]] else {
                        return
                }
                
                strongSelf.enrollments = enrollmentsArray.map {(enrollment:[String:AnyObject]) -> Enrollment in Enrollment(dictionary: enrollment) }
                strongSelf.eventTableView?.reloadData()
                print("Use offline data")
            }
            strongSelf.isUpdating = false
            strongSelf.eventTableView.tableFooterView = nil
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension MyTicketViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrollments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTicketCell.self), for: indexPath) as! EventTicketCell
        cell.enrollment = enrollments[indexPath.row]
        cell.index = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
                if(currentNumber <= enrollments.count){
                    currentNumber = currentNumber + 5
                    isUpdating = true
                    if(currentTab == 0){
                        self.loadMyUpcomingTickets()
                    }
                    else{
                        self.loadExpiredTickets()
                    }
                }
                
                //Timeout for spinner
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.eventTableView.tableFooterView = nil
                }
                
                //Timeout for next loading
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
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
                    self.loadMyUpcomingTickets()
                }
                else{
                    self.loadExpiredTickets()
                }
                
                //Timout for spinner
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.eventTableView.tableHeaderView = nil
                }
                
                //Timeout for next loading
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.isReloadEnabled = true
                }
            }
        }
    }
}
