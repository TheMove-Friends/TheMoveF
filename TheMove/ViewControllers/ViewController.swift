//
//  ViewController.swift
//  TheMove
//
//  Created by User 2 on 2/22/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import GoogleSignIn
import Alamofire
import FBSDKLoginKit
import BRYXBanner
import PUGifLoading
import EFInternetIndicator

class ViewController: UIViewController, GIDSignInUIDelegate,GIDSignInDelegate,UITextFieldDelegate,InternetStatusIndicable{
    var internetConnectionIndicator: InternetViewIndicator?
    
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    var arrayOfContacts: [contact] = []
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var googleSignBtn: UIButton!
    
    var gradientLayer: CAGradientLayer!
    
    var socialUserName : String!
    
    var socialEmailId : String!
    
    var socialImageUrl :URL!
    
    let loading = PUGIFLoading()
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startMonitoringInternet()
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRect(x:self.view.frame.width / 3 + 10, y: 70, width:100, height:100));
        imageView.image = UIImage(named:"profile")
        self.view.addSubview(imageView)
        
       
        
        
        if(FBSDKAccessToken.current() == nil){
            print("Not logged in ")
        }else{
            print("Logged in already")
            //getFacebookUserInfo()
        }
        
       
        let image = UIImage.init(named: "google")?.withRenderingMode(.alwaysTemplate)
        
        googleSignBtn.setImage(image, for: .normal)
        
        googleSignBtn.tintColor = UIColor.white
        
        googleSignBtn.imageView?.contentMode = .scaleToFill
        
        SetLeftSIDEImage(TextField: userNameField, ImageName: "mail")
        
        SetLeftSIDEImage(TextField: passwordField, ImageName: "password")
        
        userNameField.layer.cornerRadius = 8
        
        userNameField.layer.masksToBounds = true
        
        passwordField.layer.cornerRadius = 8
        
        passwordField.layer.masksToBounds = true

        signInBtn.layer.cornerRadius = 10

        signInBtn.layer.masksToBounds = true
        
        signInBtn.layer.borderWidth = 1.5
        
        userNameField.layer.borderColor = UIColor.white.cgColor
        
        userNameField.layer.borderWidth = 1.5
        
        passwordField.layer.borderColor = UIColor.white.cgColor
        
        passwordField.layer.borderWidth = 1.5
        
        signInBtn.layer.borderColor = UIColor.white.cgColor
        
        signInBtn.backgroundColor = UIColor.clear
        
        
        let leftImageView = UIImageView()
        leftImageView.image = UIImage.init(named: "password")?.withRenderingMode(.alwaysTemplate)
        leftImageView.tintColor = UIColor.white
        
        let leftView = UIView()
        leftView.addSubview(leftImageView)
        
        leftView.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        leftImageView.frame = CGRect.init(x: 15, y: 5, width: 15, height: 20)
        
        passwordField.leftView = leftView
        
        let leftImageView1 = UIImageView()
        leftImageView1.image = UIImage.init(named: "mail")?.withRenderingMode(.alwaysTemplate)
        
        leftImageView1.tintColor = UIColor.white
        let leftView1 = UIView()
        leftView1.addSubview(leftImageView1)
        
        leftView1.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        leftImageView1.frame = CGRect.init(x: 10, y: 5, width: 25, height: 20)
        
        userNameField.leftView = leftView1
        
        userNameField.attributedPlaceholder = NSAttributedString(string: "User Name",
                                                                 attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                 attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
    }

    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.gradientView.bounds
        
        gradientLayer.colors = [UIColor.white.cgColor,  UIColor(rgb: 0x1E1F5F).cgColor]
        
        self.gradientView.layer.addSublayer(gradientLayer)
    }
    
    override func viewWillLayoutSubviews() {
        createGradientLayer()
        
    }

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error?) {
        
    }
    @IBAction func signUpBtnAction(_ sender: Any) {
        
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
    }
   
    
    @IBAction func facebookBtnAction(_ sender: Any) {
        
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (result, error) in
            
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((FBSDKAccessToken.current()) != nil){
                            FBSDKGraphRequest(graphPath: "me", parameters:["fields":"id, email, first_name, last_name, picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
                                if (error == nil){
                                    let dict: NSDictionary = result as! NSDictionary
                                    if let token = FBSDKAccessToken.current().tokenString {
                                        print("tocken: \(token)")
                                        
                                        let userDefult = UserDefaults.standard
                                        userDefult.setValue(token, forKey: "access_tocken")
                                        userDefult.synchronize()
                                    }
                                    
                                    var userName : String?
                                     var emailID : String?
                                    if let user : NSString = dict.object(forKey:"name") as! NSString? {
                                        userName = user as String
                                    }
                                    if let id : NSString = dict.object(forKey:"id") as? NSString {
                                        print("id: \(id)")
                                    }
                                    
                                    
                                    if let emailz : NSString = (result! as AnyObject).value(forKey: "employee_number") as? NSString {
                                        print(emailz)
                                        
                                    }
                                    
                                    if let email : NSString = (result! as AnyObject).value(forKey: "email") as? NSString {
                                        emailID = email as String
                                    }
                                    let imagesDict: NSDictionary = dict["picture"] as! NSDictionary
                                    
                                    let imagesData : NSDictionary = imagesDict["data"] as! NSDictionary
                        
                                    
                                    self.socialEmailId = emailID
                                    
                                    self.socialUserName = userName
                                    
                                    self.socialImageUrl = URL.init(string: imagesData.value(forKey: "url") as! String)
                                
                                    
                                    if let email = emailID{
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.loading.hide()
                                            
                                            self.loading.show("Please wait....", gifimagename: "foodloader")
                                            
                                            ApiService.callPost(url: URL.init(string: Endpoints().checkSocialAccountUrl)!, params: ["email":email],viewcontroller: self, finish: self.checkFBAccount(message:data:))
                                            
                                            self.autohide()
                                            
                                        }
                                       
                                        
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func googleBtnAction(_ sender: Any) {
        
        
        if (GIDSignIn.sharedInstance()?.hasAuthInKeychain())! {
            
            print("signIn")
            
        }else{
            
            print("not")
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.google.com/m8/feeds/"]
        GIDSignIn.sharedInstance().clientID = "123746515481-vei54uk68qfgctqm0c3qko7nfjfs81ae.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func checkGoogleAccount(message:String, data:Data?) -> Void
    {
        do
        {
            if let jsonData = data
            {
                let json = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                
                let dict : NSDictionary = json as! NSDictionary
                
                let isAlreadyadded : Bool = dict.value(forKey: "success") as! Bool
                
               
                
                if isAlreadyadded != true{
                
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
                
                vc?.emailId = socialEmailId
                
                vc?.userName = socialUserName
                
                vc?.profileUrl = socialImageUrl
                
                self.navigationController?.pushViewController(vc!, animated: true)
                }else{
                
                    
                    DispatchQueue.main.async {
                        
                        self.userNameField.text = self.socialEmailId
                        
                        
                        AppDelegate.showAlertView(vc: self, titleString: "Please Login", messageString: "Already Added This Google Acoount")
                        
                    }
                   
                    
                }
                
            }
        }
        catch
        {
            print("Parse Error: \(error)")
        }
    }
    
    func checkFBAccount(message:String, data:Data?) -> Void
    {
        do
        {
            if let jsonData = data
            {
                let json = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                
                let dict : NSDictionary = json as! NSDictionary
                
                let isAlreadyadded : Bool = dict.value(forKey: "success") as! Bool
           
                if isAlreadyadded != true{
                    
                    DispatchQueue.main.async {
                    
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
                    
                        vc?.emailId = self.socialEmailId
                    
                        vc?.userName = self.socialUserName
                    
                        vc?.profileUrl = self.socialImageUrl
                    
                    self.navigationController?.pushViewController(vc!, animated: true)
                        
                    }
                }else{
                    
                    DispatchQueue.main.async {
                        
                        self.userNameField.text = self.socialEmailId
                        
                        AppDelegate.showAlertView(vc: self, titleString: "Please Login", messageString: "Already Added This FB Acount")
                        
                    }
                }
                
            }
        }
        catch
        {
            print("Parse Error: \(error)")
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func finishPost (message:String, data:Data?) -> Void
    {
        self.autohide()
        do
        {
            if let jsonData = data
            {
               if let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any] {
                
                print(json)
                
                
                
                let loginDetails : NSDictionary = json as! NSDictionary
                
                let isLogin : Bool = loginDetails.value(forKey: "success") as! Bool
                
                if isLogin == true{
                    
                    UserDefaults.standard.set(loginDetails, forKey: "loginDetails")
                    
                    DispatchQueue.main.async {
                    
                         self.autohide()
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
                
                
                
            }
            else{
                
                DispatchQueue.main.async {
                    
                    let banner = Banner(title: "Oops", subtitle: message, image: UIImage(named: "offline"), backgroundColor: UIColor.red)
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
    
    func apicalls(){
        
      
        
        if userNameField.text != "" && passwordField.text != ""{

            loading.hide()
          
            loading.show("Please wait....", gifimagename: "foodloader")
            
          
           ApiService.callPost(url: URL.init(string: Endpoints().loginUrl)!, params: ["email": userNameField.text!, "password" : passwordField.text!,  "fcm_id" : UserDefaults.standard.value(forKey: "fcm_id")!],viewcontroller: self, finish: finishPost)
            
            self.autohide()
            
        }else{
            userNameField.shake()
            passwordField.shake()
        }
    }
    
    func autohide()
    {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
        
            self.loading.hide()
        }
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let userAuth = user{
            
            
            UserDefaults.standard.removeObject(forKey:"GoogleUserAuth")
            
            UserDefaults.standard.set(userAuth.authentication.accessToken!, forKey: "GoogleUserAuth")
            
            
            socialEmailId = userAuth.profile.email
            
            socialUserName = userAuth.profile.givenName
            
            print(userAuth.profile.email)
            
            if user.profile.hasImage
            {
                let pic = user.profile.imageURL(withDimension: 100)
                
               socialImageUrl = pic
            }
            
            if let email = userAuth.profile.email{
              ApiService.callPost(url: URL.init(string: Endpoints().checkSocialAccountUrl)!, params: ["email":email],viewcontroller: self, finish: checkGoogleAccount(message:data:))
                self.autohide()
            }
            
     }

}
    
    func SetLeftSIDEImage(TextField: UITextField, ImageName: String){
        
        let leftImageView = UIImageView()
        leftImageView.contentMode = .scaleAspectFit
        
        let leftView = UIView()
        
        leftView.frame = CGRect(x: 20, y: 0, width: 30, height: 20)
        leftImageView.frame = CGRect(x: 13, y: 0, width: 30, height: 25)
        TextField.leftViewMode = .always
        TextField.leftView = leftView
        
       let image = UIImage(named: ImageName)
        leftImageView.image = image
//       // leftImageView.tintColor = UIColor(red: 106/255, green: 79/255, blue: 131/255, alpha: 1.0)
//        leftImageView.tintColorDidChange()
        
        leftView.addSubview(leftImageView)
    }
    @IBAction func signInBtnAction(_ sender: Any) {
        
        apicalls()
    }
    
    func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

class contact : NSObject{
    
    var name: String?
    
    var image : String?
    
}
extension UITextField
{
    enum Direction
    {
        case Left
        case Right
    }
    
    func AddImage(direction:Direction,imageName:String,Frame:CGRect,backgroundColor:UIColor)
    {
        let View = UIView(frame: CGRect.init(x: self.frame.maxX , y: 0, width: Frame.width, height: Frame.height))
        View.backgroundColor = backgroundColor
        
        let imageView = UIImageView(frame: Frame)
        imageView.image = UIImage(named: imageName)
        
        View.addSubview(imageView)
        
        if Direction.Left == direction
        {
            self.leftViewMode = .always
            self.leftView = View
        }
        else
        {
            self.rightViewMode = .always
            self.rightView = View
        }
    }
    
}


