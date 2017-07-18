//
//  PopupCellSpeaker.swift
//  aEvents
//
//  Created by jenkin on 4/3/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class PopupCellSpeaker : UICollectionViewCell {
    
    @IBOutlet open weak var imageSpeaker: UIImageView!
    
    @IBOutlet open weak var textSpeaker: UILabel!
    
    
    override func prepareForReuse() {
        imageSpeaker.image = nil
        textSpeaker.text = nil
    }
    
}
