//
//  ProfileViewController.swift
//  aEvents
//
//  Created by jenkin on 2/27/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation

class ProfileViewController: UIViewController, UINavigationControllerDelegate  {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textFullName: UITextField!
    @IBOutlet weak var textAddress: UITextField!
    @IBOutlet weak var textJob: UITextField!
    @IBOutlet weak var textCompany: UITextField!
    @IBOutlet weak var textPhone: UITextField!
    @IBOutlet weak var textBirthday: UITextField!
    @IBOutlet weak var btnSaveEdit: UIButton!
    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var radioMale: UIButton!
    @IBOutlet weak var radioFemale: UIButton!
    var currentGender:Int = 1
    
    let imagePicker = UIImagePickerController()
    var birthday: Double = 0
    
    var user: User?
    
    var status = ["View", "Edit"]
    var avatarChoosen: UIImage?
    
    var dateFormate = Bool()
    
    override func viewDidLoad() {
        loadUser()
        //Init Navigation
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 45/255, green: 141/255, blue: 185/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        //Load Menu
        btnMenu.target = revealViewController()
        btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        btnEdit.target = self
        btnEdit.action = #selector(self.editSaveProfile(_:))

        btnSaveEdit.layer.borderWidth = 0.8
        btnSaveEdit.layer.cornerRadius = 2
        btnSaveEdit.layer.borderColor = UIColor.init(red: 0, green: 122/255, blue: 1.0, alpha: 1.0).cgColor
        
        //Handle Keyboard Appear
        registerKeyboardNotifications()

//        scrollView.contentInset = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
//        scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: -64, left: 0, bottom: 0, right: 0)
        
        //Handle upload image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageAvatar.isUserInteractionEnabled = true
        imageAvatar.addGestureRecognizer(tapGestureRecognizer)
        
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
    
    @IBAction func onBtnMaleTouched(_ sender: Any) {
        if(currentGender == 0){
            currentGender = 1
            let btnCheck = UIImage(named: "radio_check")
            let btnUncheck = UIImage(named: "radio_uncheck")
            self.radioMale.setImage(btnCheck , for: UIControlState.normal)
            self.radioFemale.setImage(btnUncheck , for: UIControlState.normal)
        }
    }
    
    @IBAction func onBtnFemaleTouched(_ sender: Any) {
        if(currentGender == 1){
            currentGender = 0
            let btnCheck = UIImage(named: "radio_check")
            let btnUncheck = UIImage(named: "radio_uncheck")
            self.radioFemale.setImage(btnCheck , for: UIControlState.normal)
            self.radioMale.setImage(btnUncheck , for: UIControlState.normal)
        }
    }
    
    @IBAction func editSaveProfile(_ sender: Any) {
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        guard (user != nil) else {
            return
        }
        
        guard (self.isValidEmail(textEmail.text!)) else {
            self.alertWithMessage("Please fill a valid email!")
            return
        }
        
        guard (textFullName.text != "")  else {
            self.alertWithMessage("Full name cannot be blank!")
            return
        }
        
        guard (textPhone.text == "" || self.isValidPhoneLength(textPhone.text!)) else {
            self.alertWithMessage("Phone must be between 9 and 13 numbers")
            return
        }
        
        user?.fullName = textFullName.text!
        user?.email = textEmail.text!
        user?.gender = currentGender
        user?.birthday = self.birthday
        user?.phone = textPhone.text!
        user?.address = textAddress.text!
        user?.job = textJob.text!
        user?.company = textCompany.text!
//        let avatar = imageAvatar.image
        
        self.alertLoading("Updating...")
        Services.updateProfile(user: user!, image: avatarChoosen, token: token as String) {[weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: false, completion: {
                switch result {
                    case .success(let responseUser):
                        //update top view
                        strongSelf.lblEmail.text = responseUser.email
                        strongSelf.lblName.text = responseUser.fullName
                        var avatar = responseUser.avatar
                        if(!avatar.contains("http")){
                            avatar = Services.server + avatar
                        }
                        strongSelf.imageAvatar.kf.setImage(with: URL(string: avatar))
                        strongSelf.avatarChoosen = nil
                        
                        //reload user corner
                        strongSelf.saveUserCorner(responseUser)
                        let menuView = strongSelf.revealViewController().rearViewController as! MenuViewController
                        menuView.loadUserCorner()
                        
                        strongSelf.alertWithMessage("Profile Updated Successfully!")
                    case .failure:
                        print("error")
                        strongSelf.alertConnectionFail()
                }
            })
        }
        
//        let today = Date()
//        let date = Calendar.current.date(byAdding: .minute, value: 1, to: today)
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        delegate?.scheduleNotification(at: date!)
    }
    
    @IBAction func birthdayEditing(_ sender: Any) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.maximumDate = Date()
        datePickerView.date = Date(timeIntervalSince1970: (user?.birthday)!/1000)
        
        (sender as! UITextField).inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        let toolBar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: 0, height: 40))
        
        toolBar.barStyle = UIBarStyle.default
        
        let toolBarButton = UIBarButtonItem(title: "Close picker", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePicker))

        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.rewind, target: self, action: #selector(donePicker))
        
        toolBar.items = [toolBarButton, shareButton]
        
        (sender as! UITextField).inputAccessoryView = toolBar
    }
    
    func donePicker(sender:UIBarButtonItem)
    {
        textBirthday.resignFirstResponder()
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        self.birthday = sender.date.timeIntervalSince1970*1000
        textBirthday.text = dateFormatter.string(from: sender.date)
        
    }
    
    @IBAction func validateEmail(_ sender: UITextView) {
        if !isValidEmail(sender.text) {
            sender.layer.borderColor = UIColor.red.cgColor
            sender.layer.borderWidth = 0.8
        }
        else {
            sender.layer.borderColor = self.textBirthday.layer.borderColor
            sender.layer.borderWidth = self.textBirthday.layer.borderWidth
        }
    }
    
}

//private func
fileprivate extension ProfileViewController {
    func loadUser(){
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        Services.getUserInfo(token: token as String) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let user):
                strongSelf.user = user
                strongSelf.textFullName.text = user.fullName
                strongSelf.textEmail.text = user.email
                strongSelf.textPhone.text = user.phone
                strongSelf.textAddress.text = user.address
                strongSelf.textCompany.text = user.company
                strongSelf.textJob.text = user.job
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd/MM/yyyy"
                let birthday = Date(timeIntervalSince1970: user.birthday/1000)
                strongSelf.textBirthday.text = "\(dateFormatterPrint.string(from: birthday))"
                strongSelf.birthday = user.birthday
                
                //top view
                strongSelf.lblEmail.text = user.email
                strongSelf.lblName.text = user.fullName
                var avatar = user.avatar
                if(!avatar.contains("http")){
                    avatar = Services.server + avatar
                }
                strongSelf.imageAvatar.kf.setImage(with: URL(string: avatar))
                strongSelf.imageAvatar.layer.cornerRadius = strongSelf.imageAvatar.frame.size.width / 2
                strongSelf.imageAvatar.clipsToBounds = true
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
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    
}

//UITextField Delegate
extension ProfileViewController: UITextFieldDelegate {
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

//ImagePickerView
extension ProfileViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let profileImageFixed = profileImage?.fixOrientation()
        self.avatarChoosen = profileImageFixed
        imageAvatar.image = profileImageFixed
        self.dismiss(animated: true, completion: nil)
    }
    
}

//Fix orientation
extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImageOrientation.up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if ( self.imageOrientation == UIImageOrientation.down || self.imageOrientation == UIImageOrientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        }
        
        if ( self.imageOrientation == UIImageOrientation.left || self.imageOrientation == UIImageOrientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        }
        
        if ( self.imageOrientation == UIImageOrientation.right || self.imageOrientation == UIImageOrientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
        }
        
        if ( self.imageOrientation == UIImageOrientation.upMirrored || self.imageOrientation == UIImageOrientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if ( self.imageOrientation == UIImageOrientation.leftMirrored || self.imageOrientation == UIImageOrientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        
        if ( self.imageOrientation == UIImageOrientation.left ||
            self.imageOrientation == UIImageOrientation.leftMirrored ||
            self.imageOrientation == UIImageOrientation.right ||
            self.imageOrientation == UIImageOrientation.rightMirrored ) {
            
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
        
    }
}
