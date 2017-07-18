//
//  TutorialPageController.swift
//  aEvents
//
//  Created by jenkin on 4/5/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class TutorialPageController: UIPageViewController {
    
    let titles: [String] = ["Keep track", "Check in", "Communicate"]
    let descriptions: [String] = [
            "View topic schedules and upcoming events",
            "Use the QR code on your ticket to check into events",
            "Receive push notification for schedule changes and announcements"
    ]
    let images: [UIImage?] = [
            UIImage(named: "onboarding-1"),
            UIImage(named: "onboarding-2"),
            UIImage(named: "onboarding-3")
    ]
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(index: 0),
                self.newColoredViewController(index: 1),
                self.newColoredViewController(index: 2)]
    }()
    
    private func newColoredViewController(index: Int) -> UIViewController {
        let tutorialVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        tutorialVC.myTitle = titles[index]
        tutorialVC.myDescription = descriptions[index]
        tutorialVC.myImage = images[index]
        if(index == 2) {
            tutorialVC.isLastViewd = true
        }
        tutorialVC.parentVC = self
        return tutorialVC
    }
    
    override func viewDidLoad() {
        dataSource = self
        delegate = self
        
        self.view.backgroundColor = UIColor.white
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                //view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
                let pageControl = view as! UIPageControl
                pageControl.pageIndicatorTintColor = UIColor.lightGray
                pageControl.currentPageIndicatorTintColor = UIColor.black
                //pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
    }
    
}

extension TutorialPageController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount >= nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}
