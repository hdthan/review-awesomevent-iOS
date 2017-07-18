//
//  SpeakerCell.swift
//  aEvents
//
//  Created by jenkin on 2/14/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit

class SpeakerCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var speakerMajor: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    
    var speaker: Speaker? {
        didSet {
            guard let speaker = speaker else { return }
            configure(speaker)
        }
    }
}

//MARK: - Override
extension SpeakerCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        speakerName.text = nil
        speakerMajor.text = nil
        avatarImage.kf.cancelDownloadTask()
        avatarImage.image = nil
    }
    
}

//MARK: - Private
fileprivate extension SpeakerCell {
    
    func configure(_ speaker: Speaker) {
        speakerName.text = speaker.name
        speakerMajor.text = speaker.major
        let imageURL = (speaker.avatarImage.contains("http")) ? speaker.avatarImage : Services.server + speaker.avatarImage
        avatarImage.kf.setImage(with: URL(string: imageURL))
        avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2
        avatarImage.clipsToBounds = true
//        configBackground()
    }
    
    func configBackground(){
        viewBackground.layer.shadowColor = UIColor.lightGray.cgColor;
        viewBackground.layer.shadowOffset = CGSize(width: 1, height: 1);
        viewBackground.layer.shadowOpacity = 1;
        viewBackground.layer.shadowRadius = 1.0;
    }
    
}
