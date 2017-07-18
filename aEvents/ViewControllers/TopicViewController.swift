//
//  TopicViewController.swift
//  aEvents
//
//  Created by jenkin on 2/10/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

class TopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topicTableView: UITableView!
    
    var topics: [Topic]? {
        didSet {
            guard let topics = topics else { return }
            rearrangeTopic(topics)
        }
    }
    
    var eventID: Int = 0
    var seletedRow: Int = -1
    var topicShows: [[Topic]] = [[]]
    var sections: [Date] = []
    
    var isUpdating: Bool = false
    var isReloadEnabled = true
    
}

//MARK: - Override
extension TopicViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicTableView.delegate = self
        topicTableView.dataSource = self
    
        //Fix Height tabel cell
        topicTableView.estimatedRowHeight = 87.0
        topicTableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTopics()
    }
    
    func checkTopicEmpty(){
        guard topics != nil else {
            return
        }
        if(topics!.isEmpty) {
            print("empty")
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2 - 100, width: 300, height: 35))
            toastLabel.backgroundColor = UIColor.clear
            toastLabel.textColor = UIColor.darkGray
            toastLabel.textAlignment = NSTextAlignment.center;
            self.view.addSubview(toastLabel)
            toastLabel.text = "Coming soon"
        }
    }
    
    func rearrangeTopic(_ topics: [Topic]){
        if(!topics.isEmpty) {
            topicShows.removeAll()
            sections.removeAll()
            var topicSection: [Topic] = []
            var currentDate = Date(timeIntervalSince1970: topics[0].startTime/1000)
            
            sections.append(currentDate)
            topicSection.append(topics[0])
            for (index, topic) in topics.enumerated() {
                if (index > 0) {
                    let time = Date(timeIntervalSince1970: topic.startTime/1000)
                    //                for(_, date) in sections.enumerated() {
                    if (Calendar.current.isDate(time, inSameDayAs: currentDate)) {
                        topicSection.append(topic)
                    }
                    else {
                        topicShows.append(topicSection)
                        topicSection = []
                        topicSection.append(topic)
                        currentDate = time
                        sections.append(currentDate)
                        
                    }
                    //                }
                }
            }
            topicShows.append(topicSection)
        }
        
    }
    
    
    fileprivate func reloadTopics(){
        Services.eventTopic(eventID: eventID) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let topics):
                strongSelf.topics = topics
                strongSelf.topicTableView.reloadData()
            case .failure:
                print("error")
            }
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension TopicViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicShows[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE MMM dd, yyyy"
        return "\(dateFormatterPrint.string(from: sections[section]))"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
//        view.tintColor = UIColor.white
//        view.backgroundColor = UIColor.darkGray
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor = UIColor.white
//        header.contentView.backgroundColor = UIColor.darkGray
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell
        
        // Configure the cell...
        let sectionData = topicShows[indexPath.section]
        
        //Format startTime
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "HH:mm"
        let startTime = Date(timeIntervalSince1970: (sectionData[indexPath.row].startTime)/1000)

        //TimeInterval.
        let endTime = Date(timeIntervalSince1970: (sectionData[indexPath.row].endTime)/1000)
        let diff = endTime.timeIntervalSince(startTime)
        let days = Int(diff) / 86400
        let hours = Int(diff/3600) % 24
        let mins = Int(diff/60) % 60
        let duration = (days > 0 ? ((days > 1) ? "\(days) days" : "1 day") : "") + (hours > 0 ? ((hours > 1) ? " \(hours) hours" : " 1 hour") : "") + (mins > 0 ? ((mins > 1) ? " \(mins) minutes" : "1 min") : "")
        
        var title = "\(dateFormatterPrint.string(from: startTime))"
        if(indexPath.row > 0){
            if (sectionData[indexPath.row].startTime == sectionData[indexPath.row-1].startTime){
                title = ""
            }
        }
        let timeLocation =  "\(duration.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)), " + sectionData[indexPath.row].location
        let topicName = sectionData[indexPath.row].title
        
        let today = Date()
        if (endTime < today) {
            cell.timelinePoint.isFilled = false
        }
        else if (today < startTime) {
            cell.timelinePoint.isFilled = true
        }
        else {
            cell.timelinePoint.isFilled = false
            cell.timelinePoint.isHappening = true
        }
//        cell.timelinePoint = timelinePoint
        if(indexPath.row == sectionData.count - 1) {
            cell.timeline.backColor = UIColor.clear
        }
        if(indexPath.row == 0){
            cell.timeline.frontColor = UIColor.clear
        }

        cell.titleLabel.text = title
        cell.descriptionLabel.text = topicName
        cell.timeLocationLabel.text = timeLocation
        cell.lineInfoLabel.text = ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = topicShows[indexPath.section][indexPath.row]
//        let popup = PopupDialog(title: topic.title, message: topic.description, image: nil, buttonAlignment: .horizontal, transitionStyle: .fadeIn, gestureDismissal: true, completion: nil)
        if(topic.description != "" || topic.speakers.count > 0) {
            let view = PopupTopicVC(nibName: "PopupTopicVC", bundle: nil)
            view.topic = topic
            let popup = PopupDialog(viewController: view, buttonAlignment: .horizontal, transitionStyle: .fadeIn, gestureDismissal: true)
            let button = DefaultButton(title: "Close") {
                
            }
            popup.addButton(button)
            self.present(popup, animated: true, completion: nil)
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height;
        
        let contentYoffset = scrollView.contentOffset.y;
        
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset;
        
        //Handle load more on scrolling to bottom
        if((distanceFromBottom < height || contentYoffset < 0) && isReloadEnabled)
        {
            if(!isUpdating){
                self.isReloadEnabled = false
                
                reloadTopics()
                print("reloaded")
                //Timeout for next loading
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.isUpdating = false
                    self.isReloadEnabled = true
                }
            }
        }
        
//        //Handle reload on scrolling to top
//        if(contentYoffset < 0 && isReloadEnabled) {
//
//        }
    }

}
