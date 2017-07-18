//
//  AboutUsViewController.swift
//  aEvents
//
//  Created by jenkin on 2/22/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class AboutUsViewController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var textVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init Navigation
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        btnMenu.target = revealViewController()
        btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        let version: String? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String?
        textVersion.text = version
        
    }
    @IBAction func openFanpageURL(_ sender: Any) {
        if let url = URL(string: "https://www.facebook.com/Event-Awesome-417549525253231/"){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
            }
        }

    }
    
}
