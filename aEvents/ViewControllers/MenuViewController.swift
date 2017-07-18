//
//  MenuViewController.swift
//  aEvents
//
//  Created by jenkin on 2/21/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var imageAvatar: UIImageView!
    
    @IBOutlet weak var tableMenu: UITableView!
    
    var menuNameArr: Array = [String] ()
    var iconArr: Array = [UIImage] ()
    var isLoggingOut: Bool = false
    
    override func viewDidLoad() {
        loadUserCorner()
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != "") {
            menuNameArr = ["Home", "Profile", "My Ticket", "About Us", "Feedback", "Logout"]
        }
        else {
            menuNameArr = ["Home", "About Us", "Login"]
        }
//        iconArr = [UIImage(named: "icon-home")!, UIImage(named: "users")!, UIImage(named: "ticket")!, UIImage(named: "information")!, UIImage(named: "alarm")!, UIImage(named: "logout")!]
        
        tableMenu.delegate = self
        tableMenu.dataSource = self
    }
        
    func loadUserCorner(){
        guard ((lblName != nil)) && ((lblEmail != nil)) else {
            return
        }
        var avatar = UserDefaults.standard.value(forKey: "avatar") as? String ?? ""
        if(avatar != "" && !avatar.contains("http")){
            avatar = Services.server + avatar
        }
        let name = UserDefaults.standard.value(forKey: "fullName") as? String ?? ""
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? ""
        lblEmail.text = email
        lblName.text = name
        if(avatar != "") {
            imageAvatar.kf.setImage(with: URL(string: avatar))
        }
        else {
            imageAvatar.image = UIImage(named: "avatar")
        }
        imageAvatar.layer.cornerRadius = self.imageAvatar.frame.size.width / 2
        imageAvatar.clipsToBounds = true
        
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != "") {
            menuNameArr = ["Home", "Profile", "My Ticket", "About Us", "Feedback", "Logout"]
        }
        else {
            menuNameArr = ["Home", "About Us", "Login"]
        }
        tableMenu.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuCell.self), for: indexPath) as! MenuCell
        cell.menuTitle.text = menuNameArr[indexPath.row]
//        cell.menuIcon.image = iconArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isLoggingOut else {
            return
        }
        
        let revealViewController: SWRevealViewController = self.revealViewController()
        let cell: MenuCell = tableView.cellForRow(at: indexPath) as! MenuCell
        
        if cell.menuTitle.text == "Home" {
            let homeView = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let newFronViewController = UINavigationController.init(rootViewController: homeView)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
        }
        else if cell.menuTitle.text == "Logout" {
            isLoggingOut = true
            //Stop receive message
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.disconectToFcm()
            
            //Remove Saved User
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "userId")
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "fullName")
            UserDefaults.standard.removeObject(forKey: "avatar")
            UserDefaults.standard.synchronize()
            
            NotificationViewController.notifications.removeAll()
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            //Redirect to Login View
            let loginView = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let newFronViewController = UINavigationController.init(rootViewController: loginView)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
            //Timeout for disabling
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.isLoggingOut = false
            }
            
            GIDSignIn.sharedInstance().signOut()
            
            let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()            
            fbLoginManager.logOut()
            
        }else if cell.menuTitle.text == "Login" {
            //Redirect to Login View
            let loginView = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let newFronViewController = UINavigationController.init(rootViewController: loginView)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
        }
        else if cell.menuTitle.text == "About Us" {
            let aboutUsView: UIViewController? = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsViewController")
            let newFronViewController = UINavigationController.init(rootViewController: aboutUsView!)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
        }
        else if cell.menuTitle.text == "My Ticket" {
            let myTicketView = self.storyboard?.instantiateViewController(withIdentifier: "MyTicketViewController") as! MyTicketViewController
            let newFronViewController = UINavigationController.init(rootViewController: myTicketView)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
        }
        else if cell.menuTitle.text == "Profile" {
            let profileView = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController")
            let newFronViewController = UINavigationController.init(rootViewController: profileView!)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
        }
//        else if cell.menuTitle.text == "Notification" {
//            let notificationView = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController")
//            let newFronViewController = UINavigationController.init(rootViewController: notificationView!)
//            revealViewController.pushFrontViewController(newFronViewController, animated: true)
//        }
        else if cell.menuTitle.text == "Feedback" {
            let notificationView = self.storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController")
            let newFronViewController = UINavigationController.init(rootViewController: notificationView!)
            revealViewController.pushFrontViewController(newFronViewController, animated: true)
        }
    }
    
}
