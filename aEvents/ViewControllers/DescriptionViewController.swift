//
//  DescriptonViewController.swift
//  aEvents
//
//  Created by jenkin on 2/10/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kingfisher
import UIKit
import WebKit

class DescriptionViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var heightWebViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var webViewDescription: UIWebView!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var wvMarginBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var event: Event?
    var boxView: UIView!
    var tempHeight:CGFloat = 0

}

//MARK: - Override
extension DescriptionViewController: UIWebViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        webViewDescription.scrollView.isScrollEnabled = false;
        webViewDescription.scrollView.bounces = false
//        webViewDescription.delegate = self
//        scrollView.contentSize.height = 10000
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard event != nil else {
            return
        }
        loadWebView()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
//        heightWebViewConstraint.constant = 1000
        tempHeight = self.view.bounds.size.height - self.webViewDescription.frame.origin.y
        heightWebViewConstraint.constant = tempHeight

    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        heightWebViewConstraint.constant = tempHeight - 20
        wvMarginBottomConstraint.constant = 1000 - tempHeight
//        let height = webView.scrollView.contentSize.height
//        var wRect = webView.frame
//        wRect.size.height = height
        
//        webViewDescription.scrollView.isScrollEnabled = false;
        
//        let heightConstraint = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: height)
//        webView.addConstraint(heightConstraint)
        
//        heightWebViewConstraint.constant = height
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            let height = webView.scrollView.contentSize.height
            var wRect = webView.frame
            wRect.size.height = height
            self.heightWebViewConstraint.constant = height
            self.wvMarginBottomConstraint.constant = 20
        }
        
//        print(height)
        
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            if navigationType == UIWebViewNavigationType.linkClicked{
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(request.url!)
                } else {
                    // Fallback on earlier versions
                }
                return false
            }
            return true
    }
    
}

//MARK: - Private
fileprivate extension DescriptionViewController {
    
    func loadData() {
        loadWebView()
        //config time
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE MMM dd, yyyy HH:mm"
        
        let event:Event = self.event!
        self.lblTitle.text = event.eventName
        self.lblLocation.text = event.location
        let startDate = Date(timeIntervalSince1970: event.startTime/1000)
        self.lblStartTime.text = "From: \(dateFormatterPrint.string(from: startDate))"
        let endDate = Date(timeIntervalSince1970: event.endTime/1000)
        self.lblEndTime.text = "To: \(dateFormatterPrint.string(from: endDate))"
        self.imageCover.kf.setImage(with: URL(string: "\(Services.server)\(event.eventImageUrlString)"))
    }
    
    func loadWebView(){
        let path = Bundle.main.path(forResource: "style", ofType: "css")
        var cssContent:NSString = ""
        do {
            cssContent = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
        }
        catch let error as NSError {
            print(error)
        }
        
        let javaScrStr = "<style>%@</style>"
        let cssFile = String(format: javaScrStr, cssContent)
        let description = self.event!.description
        if(description.characters.count>14){
            let index = description.index(description.startIndex, offsetBy: 14)
            let wvContent = description.substring(to: index) + cssFile + description.substring(from: index).replacingOccurrences(of: "src=\"//", with: "src=\"http://")
            self.webViewDescription.loadHTMLString(wvContent, baseURL: nil)
        }
    }
}


