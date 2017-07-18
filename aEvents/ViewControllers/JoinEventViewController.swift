//
//  JoinEventViewController.swift
//  aEvents
//
//  Created by jenkin on 2/20/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit
import FirebaseMessaging

class JoinEventViewController: UIViewController{
    
    @IBOutlet weak var rangeAgeSelection: UIPickerView!
    @IBOutlet weak var lblPhone: UITextField!
    @IBOutlet weak var lblEmail: UITextField!
    @IBOutlet weak var lblFullName: UITextField!
    @IBOutlet weak var lblJob: UITextField!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblCompany: UITextField!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var radioMale: UIButton!
    @IBOutlet weak var radioFemale: UIButton!
    
    var currentGender: Int = 1
    
    var eventId: Int?
    var eventName: String = ""

    let pickerData = ["Under 18","18 - 25","25 - 35","Over 35"]
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            configure(user)
        }
    }
    
    @IBAction func joinEvent(_ sender: Any) {
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        guard (eventId != nil) && (user != nil) else {
            return
        }
        
        guard (self.isValidEmail(lblEmail.text!)) else {
            self.alertWithMessage("Please fill a valid email!")
            return
        }
        
        guard (lblFullName.text != "") && (lblPhone.text != "") && (lblJob.text != "") && (lblEmail.text != "") && (lblCompany.text != "") else {
            self.alertWithMessage("Please fill out all the fields!")
            return
        }
        
        guard (self.isValidPhoneLength(lblPhone.text!)) else {
            self.alertWithMessage("Phone must be between 9 and 13 numbers")
            return
        }
        
        user?.fullName = lblFullName.text!
        user?.gender = currentGender
        user?.email = lblEmail.text!
        user?.phone = lblPhone.text!
        user?.job = lblJob.text!
        user?.rangeAge = pickerData[rangeAgeSelection.selectedRow(inComponent: 0)]
        user?.company = lblCompany.text!
        
        Services.updateUser(user: user!, token: token as String) {[weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                print(user.id)
                Services.joinEvent(eventId: strongSelf.eventId!, userId: strongSelf.user!.id, token: token as String) {[weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(_):
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/i\(strongSelf.eventId!)")
                        let ticketViewController = strongSelf.storyboard?.instantiateViewController(withIdentifier: "TicketViewController") as! TicketViewController
                        ticketViewController.eventId = strongSelf.eventId
                        //                ticketViewController.eventName = event!.eventName
                        let navigationController = strongSelf.navigationController
                        navigationController?.viewControllers.removeLast()
                        navigationController?.pushViewController(ticketViewController, animated: true)

                    case .failure:
                        print("error")
                        strongSelf.alertConnectionFail()
                    }
                }
            case .failure:
                print("error")
                strongSelf.alertConnectionFail()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUser()
        rangeAgeSelection.dataSource = self
        rangeAgeSelection.delegate = self
        if(eventName != ""){
            navigationBar.title = "Join "+eventName
        }
        else {
            navigationBar.title = eventName
        }
        registerKeyboardNotifications()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //dimiss on tap outside
        let tapper = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func validateEmail(_ sender: UITextView) {
        if !isValidEmail(sender.text) {
            sender.layer.borderColor = UIColor.red.cgColor
            sender.layer.borderWidth = 0.8
        }
        else {
            sender.layer.borderColor = self.lblFullName.layer.borderColor
            sender.layer.borderWidth = self.lblFullName.layer.borderWidth
        }
    }
    
    @IBAction func onBtnMaleTouched(_ sender: UIButton) {
        if(currentGender == 0){
            currentGender = 1
            let btnCheck = UIImage(named: "radio_check")
            let btnUncheck = UIImage(named: "radio_uncheck")
            self.radioMale.setImage(btnCheck , for: UIControlState.normal)
            self.radioFemale.setImage(btnUncheck , for: UIControlState.normal)
        }
    }
    
    @IBAction func onBtnFemaleTouched(_ sender: UIButton) {
        if(currentGender == 1){
            currentGender = 0
            let btnCheck = UIImage(named: "radio_check")
            let btnUncheck = UIImage(named: "radio_uncheck")
            self.radioFemale.setImage(btnCheck , for: UIControlState.normal)
            self.radioMale.setImage(btnUncheck , for: UIControlState.normal)
        }
    }
    
}

fileprivate extension JoinEventViewController {
    func loadUser(){
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        Services.getUserInfo(token: token as String) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let user):
                strongSelf.user = user
                strongSelf.lblFullName.text = user.fullName
                strongSelf.lblEmail.text = user.email
                strongSelf.lblPhone.text = user.phone
                strongSelf.lblJob.text = user.job
                if let index = strongSelf.pickerData.index(of: user.rangeAge) {
                    strongSelf.rangeAgeSelection.selectRow(index, inComponent: 0, animated: true)
                }
                strongSelf.lblCompany.text = user.company
                //Set Gender
                strongSelf.currentGender = user.gender
                let btnCheck = UIImage(named: "radio_check")
                let btnUncheck = UIImage(named: "radio_uncheck")
                if (strongSelf.currentGender == 1) {
                    strongSelf.radioMale.setImage(btnCheck , for: UIControlState.normal)
                    strongSelf.radioFemale.setImage(btnUncheck , for: UIControlState.normal)
                }
                else {
                    strongSelf.radioFemale.setImage(btnCheck , for: UIControlState.normal)
                    strongSelf.radioMale.setImage(btnUncheck , for: UIControlState.normal)
                }
            case .failure:
                print("error")
            }
        }
    }
    
    func configure(_ user: User){
        
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 64, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    
}

extension JoinEventViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }

}

extension JoinEventViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789+").inverted
            return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
        }
        return true
    }
}
