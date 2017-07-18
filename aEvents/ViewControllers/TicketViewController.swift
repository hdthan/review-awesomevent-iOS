//
//  TicketViewController.swift
//  aEvents
//
//  Created by jenkin on 2/21/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit

class TicketViewController: UIViewController {
    
    @IBOutlet weak var imageQR: UIImageView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var eventId: Int?
    var eventName: String = ""
    
    override func viewDidLoad() {
        let userId = UserDefaults.standard.value(forKey: "userId") as? Int ?? 0
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? ""
        let code = "\(eventId!)0\(userId)"
        let image: String = "\(Services.server)/images/tickets/qr/\(code)"
        self.lblEmail.text = "Email: \(email)"
        self.lblCode.text = "Authentication Code: \(code)"
        self.imageQR.kf.setImage(with: URL(string: image))
        if(eventName != ""){
            navigationBar.title = "Ticket for "+eventName
        }
        else {
            navigationBar.title = eventName
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.white

    }
    
}

fileprivate extension TicketViewController {

    

}
