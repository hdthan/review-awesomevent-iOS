//
//  SpeakerDetailController.swift
//  aEvents
//
//  Created by jenkin on 3/21/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class SpeakerDetailController : UIViewController {
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMajor: UILabel!
    @IBOutlet weak var imgLinkedin: UIImageView!
    @IBOutlet weak var constrainstHeightLinkedin: NSLayoutConstraint!

    var speaker: Speaker? {
        didSet {
            guard let speaker = speaker else { return }
            configure(speaker)
        }
    }
    
    override func viewDidLoad() {
        showDetail()
    }
}

fileprivate extension SpeakerDetailController {
    func configure(_ speaker: Speaker) {
        //lblName.text = speaker.name
        //lblMajor.text = speaker.major
    }
    
    func showDetail(){
        lblName.text = speaker?.name
        lblMajor.text = speaker?.major
        
        let imageURL = (speaker?.avatarImage.contains("http"))! ? speaker?.avatarImage : Services.server + (speaker?.avatarImage)!
        imageAvatar.kf.setImage(with: URL(string: imageURL!))
        imageAvatar.layer.cornerRadius = self.imageAvatar.frame.size.width / 2
        imageAvatar.clipsToBounds = true
        
        let myMutableString = NSMutableAttributedString(string: (speaker?.description)!)
        
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 32
        style.alignment = .justified
        myMutableString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, myMutableString.length))
        
        lblDescription.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
        lblDescription.numberOfLines = 0
        lblDescription.attributedText = myMutableString
        
        //Linkedin button
        if speaker?.linkedIn == "" {
            imgLinkedin.isHidden = true
            constrainstHeightLinkedin.constant = 0
        }
        else {
            constrainstHeightLinkedin.constant = 24
            //Handle upload image
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imgLinkedin.isUserInteractionEnabled = true
            imgLinkedin.addGestureRecognizer(tapGestureRecognizer)
        }
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let url = URL(string: speaker!.linkedIn){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
