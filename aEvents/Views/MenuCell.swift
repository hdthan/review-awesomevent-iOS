//
//  MenuCell.swift
//  aEvents
//
//  Created by jenkin on 2/22/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuTitle: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        menuTitle.text = nil
        menuIcon.image = nil
    }
    
    override func didMoveToSuperview() {
        menuIcon.isHidden = true
    }
    
}
