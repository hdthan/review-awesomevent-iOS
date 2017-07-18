//
//  TimelineTableViewCell.swift
//  aEvents
//
//  Created by jenkin on 3/23/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import UIKit


open class TimelineTableViewCell: UITableViewCell {
    
    @IBOutlet weak open var titleLabel: UILabel!
    @IBOutlet weak open var descriptionLabel: UILabel!
    @IBOutlet weak open var lineInfoLabel: UILabel!
    @IBOutlet weak open var thumbnailImageView: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak open var timeLocationLabel: UILabel!
    
    open var timelinePoint = TimelinePoint() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    open var timeline = Timeline() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    open var bubbleRadius: CGFloat = 2.0 {
        didSet {
            if (bubbleRadius < 0.0) {
                bubbleRadius = 0.0
            } else if (bubbleRadius > 6.0) {
                bubbleRadius = 6.0
            }
            
            self.setNeedsDisplay()
        }
    }
    
    open var bubbleColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    
    override open func prepareForReuse() {
        self.timeline = Timeline()
        self.descriptionLabel.text = nil
        self.titleLabel.text = nil
        self.timeLocationLabel.text = nil
        self.timelinePoint = TimelinePoint()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override open func draw(_ rect: CGRect) {
        for layer in self.contentView.layer.sublayers! {
            if layer is CAShapeLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        lineInfoLabel.sizeToFit()
        titleLabel.sizeToFit()
//        descriptionLabel.sizeToFit()
        
        timelinePoint.position = CGPoint(x: timeline.leftMargin + timeline.width / 2, y: titleLabel.frame.origin.y + titleLabel.intrinsicContentSize.height / 2 - timelinePoint.diameter / 2)
        
        timeline.start = CGPoint(x: timelinePoint.position.x + timelinePoint.diameter / 2, y: 0)
        timeline.middle = CGPoint(x: timeline.start.x, y: timelinePoint.position.y)
        timeline.end = CGPoint(x: timeline.start.x, y: self.bounds.size.height)
        timeline.draw(view: self.contentView)
        
        timelinePoint.draw(view: self.contentView)
        
        if let title = titleLabel.text, !title.isEmpty {
            drawBubble()
        }
        
        configBackground()

    }
    
    fileprivate func drawBubble() {
        let offset: CGFloat = 15
        let bubbleRect = CGRect(
            x: titleLabel.frame.origin.x - offset / 2,
            y: titleLabel.frame.origin.y - offset / 2,
            width: titleLabel.intrinsicContentSize.width + offset,
            height: titleLabel.intrinsicContentSize.height + offset)
        
        let path = UIBezierPath(roundedRect: bubbleRect, cornerRadius: bubbleRadius)
        let startPoint = CGPoint(x: bubbleRect.origin.x + bubbleRect.width, y: bubbleRect.origin.y + bubbleRect.height / 2 - 8)
        path.move(to: startPoint)
        path.addLine(to: startPoint)
        path.addLine(to: CGPoint(x: bubbleRect.origin.x + bubbleRect.width + 8, y: bubbleRect.origin.y + bubbleRect.height / 2))
        path.addLine(to: CGPoint(x: bubbleRect.origin.x + bubbleRect.width, y: bubbleRect.origin.y + bubbleRect.height / 2 + 8))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = bubbleColor.cgColor
        
        self.contentView.layer.insertSublayer(shapeLayer, below: titleLabel.layer)
    }
    
    fileprivate func configBackground(){
        viewBackground.layer.borderWidth = 1
        viewBackground.layer.borderColor = UIColor.lightGray.cgColor
        viewBackground.layer.shadowColor = UIColor.lightGray.cgColor
        viewBackground.layer.shadowOffset = CGSize(width: 1, height: 1)
        viewBackground.layer.shadowOpacity = 1
        viewBackground.layer.shadowRadius = 1.0
    }

}
