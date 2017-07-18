//
//  TutorialViewController.swift
//  aEvents
//
//  Created by jenkin on 4/5/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class TutorialViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var textDescription: UILabel!
    @IBOutlet weak var buttonGetStarted: UIButton!
    
    var myTitle: String = ""
    var myDescription: String = ""
    var myImage: UIImage!
    var isLastViewd: Bool = false
    
    var parentVC: UIViewController!
    
    override func viewDidLoad() {
        imageView.image = myImage
        textTitle.text = myTitle
        textDescription.text = myDescription
        
        if(isLastViewd){
            buttonGetStarted.isHidden = false
            buttonGetStarted.layer.cornerRadius = self.buttonGetStarted.frame.size.height / 2
            buttonGetStarted.clipsToBounds = true
        }
        else{
            buttonGetStarted.isHidden = true
        }
    }
    
    @IBAction func goToNextPage(_ sender: Any) {
        if(isLastViewd){
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
            UIApplication.shared.keyWindow?.rootViewController = viewController
            
            parentVC.performSegue(withIdentifier: "TutorialSegue", sender: parentVC)
        }
    }
}
