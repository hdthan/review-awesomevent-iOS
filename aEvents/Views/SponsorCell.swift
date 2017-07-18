//
//  SponsorCell.swift
//  aEvents
//
//  Created by jenkin on 2/13/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit

class SponsorCell: UITableViewCell {
    
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var sponsorName: UILabel!
    @IBOutlet weak var sponsorLocation: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    
    var sponsor: Sponsor? {
        didSet {
            guard let sponsor = sponsor else { return }
            configure(sponsor)
        }
    }
}


//MARK: - Override
extension SponsorCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sponsorName.text = nil
        sponsorLocation.text = nil
//        imageLogo.kf.cancelDownloadTask()
        imageLogo.image = nil
    }
    
}

//MARK: - Private
fileprivate extension SponsorCell {
    
    func configure(_ sponsor: Sponsor) {
        sponsorName.text = sponsor.name
        sponsorLocation.text = sponsor.location
        imageLogo.kf.setImage(with: URL(string: "\(Services.server)\(sponsor.imageURL)"))

//        configBackground()
    }
    
    func configBackground(){
        viewBackground.layer.shadowColor = UIColor.lightGray.cgColor;
        viewBackground.layer.shadowOffset = CGSize(width: 1, height: 1);
        viewBackground.layer.shadowOpacity = 1;
        viewBackground.layer.shadowRadius = 1.0;
    }
    
}
