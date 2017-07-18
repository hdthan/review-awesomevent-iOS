//
//  TimelinePoint.swift
//  aEvents
//
//  Created by jenkin on 3/23/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

public struct TimelinePoint {
    public var diameter: CGFloat = 12.0 {
        didSet {
            if (diameter < 0.0) {
                diameter = 0.0
            } else if (diameter > 100.0) {
                diameter = 100.0
            }
        }
    }
    
    public var lineWidth: CGFloat = 2.0 {
        didSet {
            if (lineWidth < 0.0) {
                lineWidth = 0.0
            } else if(lineWidth > 20.0) {
                lineWidth = 20.0
            }
        }
    }
    
    public var color = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1)
    
    public var isFilled = false
    
    public var isHappening = false
    
    internal var position = CGPoint(x: 0, y: 0)
    
    public init(diameter: CGFloat, lineWidth: CGFloat, color: UIColor, filled: Bool) {
        self.diameter = diameter
        self.lineWidth = lineWidth
        self.color = color
        self.isFilled = filled
    }
    
    public init(diameter: CGFloat, color: UIColor, filled: Bool) {
        self.init(diameter: diameter, lineWidth: 2.0, color: color, filled: filled)
    }
    
    public init(color: UIColor, filled: Bool) {
        self.init(diameter: 12.0, lineWidth: 2.0, color: color, filled: filled)
    }
    
    public init() {
        self.init(diameter: 12.0, lineWidth: 2.0, color: UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1), filled: true)
    }
    
    public func draw(view: UIView) {
        let path = UIBezierPath(ovalIn: CGRect(x: position.x, y: position.y, width: diameter, height: diameter))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = isFilled ? color.cgColor : UIColor.white.cgColor
        shapeLayer.lineWidth = lineWidth
        
        view.layer.addSublayer(shapeLayer)
        
        if(isHappening) {
            let path = UIBezierPath(ovalIn: CGRect(x: position.x+3, y: position.y+3, width: diameter-6, height: diameter-6))
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
//            shapeLayer.strokeColor = color.cgColor
            shapeLayer.fillColor = color.cgColor
            shapeLayer.lineWidth = lineWidth
            view.layer.addSublayer(shapeLayer)
        }
    }
}
