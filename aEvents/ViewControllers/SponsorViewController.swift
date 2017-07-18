//
//  SponsorViewController.swift
//  aEvents
//
//  Created by jenkin on 2/13/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit

class SponsorViewController: UIViewController {
    
    @IBOutlet weak var sponsorTableView: UITableView!
    
    var sponsors: [Sponsor] = []

}

//MARK: - Override
extension SponsorViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sponsorTableView.delegate = self
        sponsorTableView.dataSource = self
        
        //Fix Height tabel cell
        sponsorTableView.estimatedRowHeight = 92.0
        sponsorTableView.rowHeight = UITableViewAutomaticDimension
        
        if(sponsors.isEmpty) {
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2 - 100, width: 300, height: 35))
            toastLabel.backgroundColor = UIColor.clear
            toastLabel.textColor = UIColor.darkGray
            toastLabel.textAlignment = NSTextAlignment.center;
            self.view.addSubview(toastLabel)
            toastLabel.text = "Comming soon"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sponsorTableView.reloadData()
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension SponsorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sponsors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SponsorCell.self), for: indexPath) as! SponsorCell
        cell.sponsor = sponsors[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sponsor = sponsors[indexPath.row]
        let link = (!sponsor.description.contains("http")) ? "http://"+sponsor.description : sponsor.description
        print(link)
        if let url = URL(string: link){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
}

