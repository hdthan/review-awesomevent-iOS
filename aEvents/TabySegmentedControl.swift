//
//  TabySegmentedControl.swift
//  aEvents
//
//  Created by jenkin on 2/10/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit

class TabySegmentedControl: UISegmentedControl {
    
    func initUI(){
        setupBackground()
        setupFonts()
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage
    {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func setupBackground(){
        let backgroundImage = UIImage(named: "segmented_unselected_bg")
        let dividerImage = getImageWithColor(color: UIColor.white, size: CGSize.init(width: 1, height: 29))
        let backgroundImageSelected = UIImage(named: "segmented_selected_bg")
        
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelected, for: .highlighted, barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelected, for: .selected, barMetrics: .default)
        
        self.setDividerImage(dividerImage, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    func setupFonts(){
        let font = UIFont.systemFont(ofSize: 14.0)        
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: font
        ]
        
        let seletedTextAttributes = [
            NSForegroundColorAttributeName: UIColor.init(red: 120/255, green: 175/255, blue: 54/255, alpha: 1),
            NSFontAttributeName: font
        ]
        
        self.setTitleTextAttributes(normalTextAttributes, for: .normal)
        self.setTitleTextAttributes(seletedTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(seletedTextAttributes, for: .selected)
    }
    
}
