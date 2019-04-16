//
//  SignUpViewController.swift
//  TheMove
//
//  Created by User 2 on 2/27/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Alamofire
import BRYXBanner
import PUGifLoading
import EFInternetIndicator

class SignUpViewController: UIViewController , UITextFieldDelegate ,InternetStatusIndicable{
    
    var internetConnectionIndicator: InternetViewIndicator?
    

    @IBOutlet weak var gradientVIew: UIView!
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confoPasswordField: UITextField!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    var gradientLayer: CAGradientLayer!
    
    var userName : String?
    
    var emailId : String?
    
    var profileUrl : URL?
    
      let loading = PUGIFLoading()
    
    var base64 : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startMonitoringInternet()
        
        if let url = self.profileUrl?.absoluteString {
            
            let url:NSURL = NSURL(string : url)!
            let imageData : NSData = NSData.init(contentsOf: url as URL)!
            base64 = imageData.base64EncodedString()
        }else{
            base64 =  LetterImageGenerator.imageWith(name:"k")?.pngData()?.base64EncodedString()
            
            print(base64?.trimmingCharacters(in: .whitespaces) ?? "")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        userNameField.text = userName
        
        emailField.text = emailId
        
        SetLeftSIDEImage(TextField: userNameField, ImageName: "")
        
        SetLeftSIDEImage(TextField: emailField, ImageName: "")
        
        SetLeftSIDEImage(TextField: passwordField, ImageName: "")
        
        SetLeftSIDEImage(TextField: confoPasswordField, ImageName: "")
        
        userNameField.layer.cornerRadius = 8
        
        userNameField.layer.masksToBounds = true
        
        emailField.layer.cornerRadius = 8
        
        emailField.layer.masksToBounds = true
        
        passwordField.layer.cornerRadius = 8
        
        passwordField.layer.masksToBounds = true
        
        confoPasswordField.layer.cornerRadius = 8
        
        confoPasswordField.layer.masksToBounds = true
        
        registerBtn.layer.cornerRadius = 10
        
        registerBtn.layer.masksToBounds = true
        
        registerBtn.layer.borderWidth = 1.5
        
        userNameField.layer.borderColor = UIColor.white.cgColor
        
        userNameField.layer.borderWidth = 1.5
        
        emailField.layer.borderColor = UIColor.white.cgColor
        
        emailField.layer.borderWidth = 1.5
        
        passwordField.layer.borderColor = UIColor.white.cgColor
        
        passwordField.layer.borderWidth = 1.5
        
        confoPasswordField.layer.borderColor = UIColor.white.cgColor
        
        confoPasswordField.layer.borderWidth = 1.5
        
        registerBtn.layer.borderColor = UIColor.white.cgColor
        
        registerBtn.backgroundColor = UIColor.clear
        
        userNameField.attributedPlaceholder = NSAttributedString(string: "User Name",
                                                                 attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Phone No",
                                                                 attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        
        emailField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                              attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        
        confoPasswordField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                      attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])

        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillLayoutSubviews() {
         createGradientLayer()
    }
    
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.gradientVIew.bounds
        
        gradientLayer.colors = [UIColor.white.cgColor, UIColor(rgb: 0x1E1F5F).cgColor]
        
        self.gradientVIew.layer.addSublayer(gradientLayer)
    }
    @IBAction func forgetBtnAction(_ sender: Any) {
        
//        let next = ChatsFriendsTableViewController()
//
//        self.present(next, animated: true, completion: nil)
        
        self.alert(message: "Error", title: "")
        
    }
    
    func finishPost (message:String, data:Data?) -> Void
    {
        do
        {
            if let jsonData = data
            {
              if let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any] {
                
                let loginDetails : NSDictionary = json as! NSDictionary
             
                let isLogin : Bool = loginDetails.value(forKey: "success") as! Bool
                
                if isLogin == true{
                    
                      UserDefaults.standard.set(loginDetails, forKey: "loginDetails")
             
                DispatchQueue.main.async {
                    
                    let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let initialViewControlleripad : UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "HomeTabbarViewController") as! HomeTabbarViewController
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    
                    let navigationController = UINavigationController(rootViewController: initialViewControlleripad)
                    navigationController.navigationBar.isTranslucent = false
                    appDelegate.window?.rootViewController = navigationController
                    appDelegate.window?.makeKeyAndVisible()
                    
                   
                }
                    
                }else{
                    
                     alert(message: loginDetails.value(forKey: "err_msg") as! String , title: "Oops")
                    
                }
                }
                
            }else{
                DispatchQueue.main.async {
                    
                    let banner = Banner(title: "Oops", subtitle: message, image: UIImage(named: "offline"), backgroundColor: UIColor.white)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    
                }
                
            }
        }
        catch
        {
            print("Parse Error: \(error)")
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
              self.view.frame.origin.y -= 50
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func goBackBtnAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func registerBtnAction(_ sender: Any) {
  
        if  passwordField.text  != ""{
            
            loading.hide()
            
            loading.show("Please wait....", gifimagename: "foodloader")
            
        
            Auth.auth().createUser(withEmail: emailField.text!, password: emailField.text!, completion: { (user, error) in
                if error != nil {
                    print(error ?? "Not Trackable Error")
                    
                    DispatchQueue.main.async {
                        
                        
                        self.alert(message: error.debugDescription, title: "already have an mail Id")
                    }
                    return
                }

                guard let uid = user?.user.uid else {
                    return
                }
               
                let values = ["name":self.userNameField.text!, "email":self.emailField.text!]
                self.registerUserInDatabaseWithUid(uid: uid, values: values as [String : AnyObject])
            })
        }else{
            
            let alert = UIAlertController(title: "Oops", message: "Password did'nt Match.", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
  
    
    private func registerUserInDatabaseWithUid(uid: String, values: [String:AnyObject]) {
        //  Firebasedatabse reference
        let ref = Database.database().reference()
        let userRef = ref.child("users").child(uid)
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "Not Trackable Error")
                return
            }
           print(ref)
            
            
            self.loading.hide()
            
            self.loading.show("Please wait....", gifimagename: "foodloader")
            
            
            let params = ["name" : self.userNameField.text!,
                          "email": self.emailField.text!,
                          "password": self.confoPasswordField.text!,
                          "image_url": self.profileUrl?.absoluteString ?? "None" ,
                          "mobile": self.passwordField.text!,
                          "fcm_id" : UserDefaults.standard.value(forKey: "fcm_id")!,
                          "chatid": uid]
            
            ApiService.callPost(url: URL.init(string: Endpoints().registration)!, params:params as [String : Any], viewcontroller: self, finish: self.finishPost)
            
            self.autohide()
            
        })
    }
    
    func autohide()
    {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            
            self.loading.hide()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func SetLeftSIDEImage(TextField: UITextField, ImageName: String){
        
        let leftImageView = UIImageView()
        leftImageView.contentMode = .scaleAspectFit
        
        let leftView = UIView()
        
        leftView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        leftImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 25)
        TextField.leftViewMode = .always
        TextField.leftView = leftView
        
        let image = UIImage(named: ImageName)
        leftImageView.image = image
        //       // leftImageView.tintColor = UIColor(red: 106/255, green: 79/255, blue: 131/255, alpha: 1.0)
        //        leftImageView.tintColorDidChange()
        
        leftView.addSubview(leftImageView)
    }
}


