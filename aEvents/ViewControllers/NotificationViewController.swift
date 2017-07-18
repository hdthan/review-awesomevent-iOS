//
//  NotificationViewController.swift
//  aEvents
//
//  Created by jenkin on 3/14/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class NotificationViewController : UIViewController {
    
    @IBOutlet weak var notificationTableView: UITableView!
    static var notifications: [Notification] = []
    var currentNotifications: [Notification] = []
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var btnClear: UIBarButtonItem!
    
//    @IBAction func onDeleteNotification(_ sender: UIButton) {
//        currentNotifications = currentNotifications.filter{$0.date.hashValue != sender.tag}
//        NotificationViewController.notifications = NotificationViewController.notifications.filter{$0.date.hashValue != sender.tag}
//        notificationTableView.reloadData()
//    }
    
    override func viewDidLoad() {
        //Init Navigation
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        //Load Menu
        btnMenu.target = revealViewController()
        btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //btn Clear
        btnClear.target = self
        btnClear.action = #selector(self.clearAllNotification)
        btnClear.title = ""
        
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        
        currentNotifications = NotificationViewController.notifications
        
        //Comming soon
        if #available(iOS 10.0, *) {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)

            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
        } else {
            // Fallback on earlier versions
        }
        
        let label = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2, width: 300, height: 35))
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center;
        self.view.addSubview(label)
        label.text = "Coming soon"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    @objc func clearAllNotification(){
        currentNotifications = []
        NotificationViewController.notifications = []
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.notificationTableView.reloadData()
    }
    
    func loadList(notification: NSNotification){
        //load data here
        currentNotifications = NotificationViewController.notifications
        self.notificationTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNotificationEvent",
            let destination = segue.destination as? EventDetailViewController,
            let blogIndex = notificationTableView.indexPathForSelectedRow?.row,
            let currentId = Int(currentNotifications[blogIndex].eventId)
        {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            destination.eventID = currentId
        }
    }
}


extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NotificationCell.self), for: indexPath) as! NotificationCell
        cell.notification = currentNotifications[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.currentNotifications.remove(at: indexPath.row)
            NotificationViewController.notifications.remove(at: indexPath.row)
            self.notificationTableView.reloadData()
        }
    }
}
