//
//  Timeline.swift
//  aEvents
//
//  Created by jenkin on 3/23/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

public struct Timeline {
    public var width: CGFloat = 2.0 {
        didSet {
            if (width < 0.0) {
                width = 0.0
            } else if(width > 20.0) {
                width = 20.0
            }
        }
    }
    
    public var (frontColor, backColor) = (UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1), UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1))
    
    internal var (start, middle, end) = (CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0))
    
    internal var leftMargin: CGFloat = 64.0
    
    public init(width: CGFloat, frontColor: UIColor, backColor: UIColor) {
        self.width = width
        self.frontColor = frontColor
        self.backColor = backColor
    }
    
    public init(frontColor: UIColor, backColor: UIColor) {
        self.init(width: 2, frontColor: frontColor, backColor: backColor)
    }
    
    public init() {
        self.init(width: 2, frontColor: UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1), backColor: UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1))
    }
    
    public func draw(view: UIView) {
        draw(view: view, from: start, to: middle, color: frontColor)
        draw(view: view, from: middle, to: end, color: backColor)
    }
    
    fileprivate func draw(view: UIView, from: CGPoint, to: CGPoint, color: UIColor) {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        
        view.layer.addSublayer(shapeLayer)
    }
}
