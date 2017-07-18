//
//  FeedbackViewController.swift
//  aEvents
//
//  Created by jenkin on 4/5/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnClear: UIButton!
    
    @IBOutlet weak var btnSend: UIButton!
    
    let PLACEHOLDER_TEXT = "Write a feedback..."
    
    override func viewDidLoad() {
        if #available(iOS 9.0, *) {
            textView.returnKeyType = .continue
        } else {
            // Fallback on earlier versions
        }
        textView.delegate = self
        applyPlaceholderStyle(textView!, placeholderText: PLACEHOLDER_TEXT)
        //To make the border look very close to a UITextField
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        
        //The rounded corner part, where you specify your view's corner radius:
        textView.layer.cornerRadius = 5;
        textView.clipsToBounds = true
       
        //Init Navigation
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        btnMenu.target = revealViewController()
        btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        btnSend.layer.borderWidth = 1
        btnSend.tintColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1)
        btnSend.layer.cornerRadius = 2
        btnSend.clipsToBounds = true
        
        btnClear.layer.borderWidth = 1
        btnClear.tintColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1)
        btnClear.layer.cornerRadius = 2
        btnClear.clipsToBounds = true
        
        disableBtns()
        
        //dimiss on tap outside
        let tapper = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func disableBtns(){
        btnClear.isEnabled = false
        btnSend.isEnabled = false
        btnClear.layer.borderColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        btnSend.layer.borderColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
    }
    
    func enableBtns(){
        btnClear.isEnabled = true
        btnSend.isEnabled = true
        btnClear.layer.borderColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1).cgColor
        btnSend.layer.borderColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1).cgColor
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        sendMessage()
    }
    
    @IBAction func btnClearTapped(_ sender: Any) {
        textView.text = ""
        disableBtns()
        applyPlaceholderStyle(textView, placeholderText: PLACEHOLDER_TEXT)
        moveCursorToStart(textView)
    }
    
    func applyPlaceholderStyle(_ aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGray
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(_ aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.black
        aTextview.alpha = 1.0
        
    }
    
    
    func sendMessage(){
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        
        guard let message = textView.text else {
            self.alertWithMessage("Nothing to send!")
            return
        }
        
        Services.sendFeedback(token: token as String, content: message){ [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                strongSelf.alertWithMessage("Sent message sucessfully!\nThanks for your feedback")
                strongSelf.textView.text = ""
                strongSelf.disableBtns()
                strongSelf.applyPlaceholderStyle(strongSelf.textView, placeholderText: strongSelf.PLACEHOLDER_TEXT)
                strongSelf.moveCursorToStart(strongSelf.textView)
                strongSelf.view.endEditing(true)
            case .failure:
                strongSelf.alertConnectionFail()
            }
        }
    }
}

extension FeedbackViewController : UITextViewDelegate {
    
    func moveCursorToStart(_ aTextView: UITextView)
    {
        DispatchQueue.main.async {
            aTextView.selectedRange = NSMakeRange(0, 0);
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == textView && textView.text == PLACEHOLDER_TEXT
        {
            // move cursor to start
            moveCursorToStart(textView)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            self.enableBtns()
            if(newLength<=250){
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
                if textView == self.textView && textView.text == PLACEHOLDER_TEXT
                {
                    if text.utf16.count == 0 // they hit the back button
                    {
                        return false // ignore it
                    }
                    applyNonPlaceholderStyle(textView)
                    textView.text = ""
                }
            }
            return true
        }
        else  // no text, so show the placeholder
        {
            self.disableBtns()
            applyPlaceholderStyle(textView, placeholderText: PLACEHOLDER_TEXT)
            moveCursorToStart(textView)
            return false
        }
    }
        
}
