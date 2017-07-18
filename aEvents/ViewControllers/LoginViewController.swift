//
//  ExampleScrollMenuController.swift
//  aEvents
//
//  Created by jenkin on 2/14/17.
//  Copyright © 2017 Dang Duc Nam. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var lblFullName: UITextField!

    @IBOutlet weak var lblEmail: UITextField!
    @IBOutlet weak var facebookLoginBtn: UIButton!

    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var lblPassword: UITextField!
    @IBOutlet weak var switchLink: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var constraintsFullnameHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!

    
    var isLogin: Bool = true
    
//    override func viewWillAppear(_ animated: Bool) {
//        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
//        if(token != ""){
//            self.saveUserSession()
//        }
//
//    }
    
    @IBOutlet weak var skipLogin: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        lblFullName.alpha = 0.0
        
        //init keyboard for textField
        lblFullName.returnKeyType = .next
        lblEmail.returnKeyType = .next
        lblPassword.returnKeyType = .done
        
        //Handle Switch Link Color
        let myMutableString = NSMutableAttributedString(string: "Need an account? Tap here")
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location:17, length:8))
        switchLink.attributedText = myMutableString
        
        //Google Sign In
        GIDSignIn.sharedInstance().clientID = "966314298950-8550tio5ec2mskdcga9r2u57l82f3208.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        //Check Logged In
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if(token != ""){
//            self.saveUserSession()

            //else{
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                let newFronViewController = UINavigationController.init(rootViewController: secondViewController)
                self.revealViewController().pushFrontViewController(newFronViewController, animated: true)
            //}
        }
        
        //Handle Switch Link Clicked
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(linkClicked(tapGestureRecognizer:)))
        switchLink.isUserInteractionEnabled = true
        switchLink.addGestureRecognizer(tapGestureRecognizer)
        
        //Handle Skip Login
        let tapSkipGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(skipLogin(tapGestureRecognizer:)))
        skipLogin.isUserInteractionEnabled = true
        skipLogin.addGestureRecognizer(tapSkipGestureRecognizer)
        
        //Handle Keyboard Appear
        registerKeyboardNotifications()
        
        //Custom button
        btnSubmit.layer.cornerRadius = 2
        btnSubmit.clipsToBounds = true
        facebookLoginBtn.layer.cornerRadius = 2
        facebookLoginBtn.clipsToBounds = true
        googleLoginBtn.layer.cornerRadius = 2
        googleLoginBtn.clipsToBounds = true
        
        //dimiss on tap outside
        let tapper = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)

    }
    
    @objc func showNotiVC(){
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        if token != "" {
            let prefs: UserDefaults = UserDefaults.standard
            prefs.removeObject(forKey: "startUpNotif")
            prefs.synchronize()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: NotificationViewController = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    @IBAction func loginFBAction(_ sender: AnyObject) {
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) {
            (result, error) -> Void in
            if (error == nil) {
                  self.getFBUserData()
            }
        }
    }
        
    func getFBUserData(){
        if(FBSDKAccessToken.current() != nil) {
            self.alertLoading("Please wait...")
            Services.socialLogin(token: FBSDKAccessToken.current().tokenString!, type: 0)
            { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: false, completion: {
                    switch result {
                    case .success(let token):
                        if(token != ""){
                            UserDefaults.standard.setValue(token, forKey: "token")
                            UserDefaults.standard.synchronize()
                            
                            strongSelf.saveUserSession()                            
                        }
                        else{
                            print("login FB Error!")
                        }
                    case .failure:
                        print("error")
                        strongSelf.alertConnectionFail()
                    }
                })
            }
            
        }
    }
    
    
    @IBAction func loginWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func login(_ sender: Any) {
        let email = lblEmail.text!
        let password = lblPassword.text!
        
        guard (self.isValidEmail(email)) else {
            self.alertWithMessage("Please fill a valid email!")
            return
        }
        
        guard (self.isValidPasswordLength(password)) else {
            self.alertWithMessage("Password must be at least 7 characters!")
            return
        }
        
        if(isLogin){
            self.signIn(email: email, password: password)
        }
        else {
            let fullName = lblFullName.text!
            guard (fullName != "") else {
                self.alertWithMessage("Please fill your full name!")
                return
            }
            self.register(fullName: fullName, email: email, password: password)
        }
    }
}

//Google Login
extension LoginViewController {
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            print("Logged out")
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            self.alertLoading("Please wait...")
            Services.socialLogin(token: user.authentication.idToken, type: 1)
            { [weak self] result in
                guard let strongSelf = self else { return }

                strongSelf.dismiss(animated: false, completion: {
                    switch result {
                    case .success(let token):
                        if(token != ""){
                            UserDefaults.standard.setValue(token, forKey: "token")
                            UserDefaults.standard.synchronize()
                            
                            strongSelf.saveUserSession()
                        }
                        else {
                            print("login GG Error!")

                        }
                    case .failure:
                        print("error")
                        strongSelf.alertConnectionFail()
                    }
                })

            }
            
        } else {
            self.dismiss(animated: false, completion: nil)
            print("\(error.localizedDescription)")
        }
    }
    
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

}

fileprivate extension LoginViewController{
    func saveUserSession(){
        let token = UserDefaults.standard.value(forKey: "token") as? NSString ?? ""
        Services.getUserInfo(token: token as String) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                strongSelf.saveUserCorner(user)
                
                Services.getEventIds(token: token as String){
                    [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let events):
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        delegate?.connectToFcm(events: events)
                    case .failure:
                        print("error")
                        strongSelf.alertConnectionFail()
                    }
                }
                
                let menuView = strongSelf.revealViewController().rearViewController as! MenuViewController
                menuView.loadUserCorner()
                let secondViewController = strongSelf.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                let newFronViewController = UINavigationController.init(rootViewController: secondViewController)
                strongSelf.revealViewController().pushFrontViewController(newFronViewController, animated: true)
                
            case .failure:
                print("error")
                strongSelf.alertConnectionFail()
            }
        }
    }
    
    @objc func linkClicked(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.isLogin = !self.isLogin
        
        if self.isLogin {
            self.lblFullName.fadeOut()
            self.btnSubmit.setTitle("Login", for: .normal)
            let myMutableString = NSMutableAttributedString(string: "Need an account? Tap here")
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location:17, length:8))
            switchLink.attributedText = myMutableString
//            self.switchLink.text = "Need an account? Tap here"
            self.constraintsFullnameHeight.priority = 999
        }
        else {
            self.lblFullName.fadeIn()
            btnSubmit.setTitle("Register", for: .normal)
            let myMutableString = NSMutableAttributedString(string: "Already have account? Login now")
            myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location:22, length:9))
            switchLink.attributedText = myMutableString
//            self.switchLink.text = "Already have account? Login now!"
            self.constraintsFullnameHeight.priority = 250
        }
    }
    
    @objc func skipLogin(tapGestureRecognizer: UITapGestureRecognizer) {
        
        UserDefaults.standard.setValue("", forKey: "userId")
        UserDefaults.standard.setValue("", forKey: "email")
        UserDefaults.standard.setValue("Guest", forKey: "fullName")
        UserDefaults.standard.setValue("", forKey: "avatar")
        UserDefaults.standard.synchronize()
        
        let menuView = self.revealViewController().rearViewController as! MenuViewController
        menuView.loadUserCorner()
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let newFronViewController = UINavigationController.init(rootViewController: secondViewController)
        self.revealViewController().pushFrontViewController(newFronViewController, animated: true)
    }
    
    func signIn(email: String, password: String) {
        self.alertLoading("Please wait...")
        Services.login(email: email, password: password)
        { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: false, completion: {
                switch result {
                case .success(let token):
                    if(token != ""){
                        UserDefaults.standard.setValue(token, forKey: "token")
                        UserDefaults.standard.synchronize()
                        
                        strongSelf.saveUserSession()
                    }
                    else{
                        print("login Error!")
                        let alert = UIAlertController(title: "Alert", message: "Email or Password is incorrect!", preferredStyle: UIAlertControllerStyle.alert)
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                case .failure:
                    print("error")
                    strongSelf.alertConnectionFail()
                }
            })
        }
    }
    
    func register(fullName: String, email: String, password: String){
        self.alertLoading("Please wait...")
        Services.register(fullName: fullName, email: email, password: password)
        { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: false, completion: {
                switch result {
                case .success(let token):
                    if(token != ""){
                        UserDefaults.standard.setValue(token, forKey: "token")
                        UserDefaults.standard.synchronize()
                        strongSelf.saveUserSession()
                    }
                    else{
                        print("Register Error!")
                        let alert = UIAlertController(title: "Alert", message: "Email is already exist!", preferredStyle: UIAlertControllerStyle.alert)
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                case .failure:
                    print("error")
                    strongSelf.alertConnectionFail()
                }
            })
        }
    }
    
    //Handle keyboard
    @objc func unregisterKeyboardNotifications() {
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
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == lblFullName){
            lblEmail.becomeFirstResponder()
        }
        else if(textField == lblEmail) {
            lblPassword.becomeFirstResponder()
        }
        else if(textField == lblPassword){
            textField.resignFirstResponder()
            self.login(btnSubmit)
        }
        return true
    }
}

//Handler Alert ViewController
extension UIViewController {
        
    func alertConnectionFail(){
        alertWithMessage("Cannot connect to server. Please try again!")
    }
    
    func alertWithMessage(_ message: String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveUserCorner(_ user: User) {
        UserDefaults.standard.setValue(user.id, forKey: "userId")
        UserDefaults.standard.setValue(user.email, forKey: "email")
        UserDefaults.standard.setValue(user.fullName, forKey: "fullName")
        if(user.avatar != "") {
            UserDefaults.standard.setValue(user.avatar, forKey: "avatar")
        }
        UserDefaults.standard.synchronize()
    }
    
    func alertLoading(_ message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        //Loading Alert
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        
        //Timeout for loading
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 20) {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func isValidEmail(_ testStr: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPhoneLength(_ phone: String) -> Bool {
        if(phone.characters.count<9 || phone.characters.count>13){
            return false
        }
        else {
            return true
        }
    }
    
    func isValidPasswordLength(_ password: String) -> Bool {
        if(password.characters.count<7 || password.characters.count>255){
            return false
        }
        else{
            return true
        }
    }
}

extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}

