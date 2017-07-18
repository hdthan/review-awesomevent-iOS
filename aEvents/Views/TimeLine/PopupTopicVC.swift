//
//  PopupTopicVC.swift
//  aEvents
//
//  Created by jenkin on 3/24/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class PopupTopicVC : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var speakersCaption: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    @IBOutlet weak var speakersCollection: UICollectionView!
    @IBOutlet weak var constraintHeightSpeakers: NSLayoutConstraint!
    
    var topic: Topic? {
        didSet {
            guard let topic = topic else { return }
            configure(topic)
        }
    }
    
    override func viewDidLoad() {
        titleLabel.text = topic?.title
        descriptionLabel.sizeToFit()
        descriptionLabel.text = (topic?.description != "") ? topic?.description : "No description"
//        var speakers = ""
//        for (_, speaker) in (topic?.speakers.enumerated())! {
//            let type = (speaker.gender == 1) ? "Mr. " : "Ms. "
//            speakers = (speakers != "") ? speakers + ", " + type + speaker.name : type + speaker.name
//        }
        if (topic!.speakers.count == 0) {
            speakersCaption.isHidden = true
        }
        
        constraintHeightSpeakers.constant = CGFloat(90 * Int((topic!.speakers.count+1)/2))
        
        let textHeight: CGFloat = (topic?.description.height(withConstrainedWidth: scrollView.frame.size.width - 40, font: UIFont.systemFont(ofSize: 12)))! + ((topic!.speakers.count>0) ? constraintHeightSpeakers.constant+120 : 120)
        
        print(textHeight)
        
        if(textHeight<350) {
            constraintHeight.constant = textHeight
        }
        
        speakersCollection.delegate = self
        speakersCollection.dataSource = self
        
        //let view = PopupCellSpeaker(nibName: "PopupCellSpeaker", bundle: nil)
        self.speakersCollection.register(UINib.init(nibName: "PopupCellSpeaker", bundle: nil), forCellWithReuseIdentifier: "PopupCellSpeaker")
    }
    
    fileprivate func configure(_ topic: Topic) {

    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}

extension PopupTopicVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topic!.speakers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopupCellSpeaker", for: indexPath) as! PopupCellSpeaker
        let speaker = topic!.speakers[indexPath.row]
        cell.imageSpeaker.kf.setImage(with: URL(string: "\(Services.server)\(speaker.avatarImage)"))
        cell.imageSpeaker.layer.cornerRadius = cell.imageSpeaker.frame.size.width / 2
        cell.imageSpeaker.clipsToBounds = true
        let type = (speaker.gender == 1) ? "Mr. " : "Ms. "
        cell.textSpeaker.text = type + speaker.name

        return cell
    }
    
 //   override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
//        return CGSize.init(width: 150, height: 150)
//    }
    
}
