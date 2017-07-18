//
//  SpeakerViewController.swift
//  aEvents
//
//  Created by jenkin on 2/14/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit

class SpeakerViewController: UIViewController {

    @IBOutlet weak var speakerTableView: UITableView!

    var speakers: [Speaker] = []
}

//MARK: - Override
extension SpeakerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speakerTableView.delegate = self
        speakerTableView.dataSource = self
        
        //Fix Height tabel cell
        speakerTableView.estimatedRowHeight = 80.0
        speakerTableView.rowHeight = UITableViewAutomaticDimension
        
        if(speakers.isEmpty) {
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2 - 100, width: 300, height: 35))
            toastLabel.backgroundColor = UIColor.clear
            toastLabel.textColor = UIColor.darkGray
            toastLabel.textAlignment = NSTextAlignment.center;
            self.view.addSubview(toastLabel)
            toastLabel.text = "Coming soon"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        speakerTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSpeakerDetail",
            let destination = segue.destination as? SpeakerDetailController,
            let blogIndex = speakerTableView.indexPathForSelectedRow?.row
        {
            destination.speaker = speakers[blogIndex]
        }
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension SpeakerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speakers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpeakerCell.self), for: indexPath) as! SpeakerCell
        cell.speaker = speakers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

