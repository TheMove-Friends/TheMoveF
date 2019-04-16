//
//  SettingsViewController.swift
//  TheMove
//
//  Created by User 2 on 3/13/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import Kingfisher
import EFInternetIndicator
import Photos
import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,InternetStatusIndicable{
    
    var internetConnectionIndicator: InternetViewIndicator?
    

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var fullNameField: UITextField!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var editBtn: UIButton!
    var doneItem = UIBarButtonItem()
    
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let appID = "1458083790"
//
//        let urlStr =  //
//
//
//        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
        
        self.startMonitoringInternet()
        
         let color2 = UIColor(rgb: 0xFF8C00)
        self.view.backgroundColor = UIColor.black
       
        fullNameField.underlined()
        
        phoneNumberField.underlined()
        
        editBtn.layer.cornerRadius = editBtn.frame.height / 2
        editBtn.clipsToBounds = true
        
        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
            
            
            print(userIds)
            
            if let userName : String = userIds.value(forKey:"username") as? String{
                
                fullNameField.text = userName
                
            }
            
            if let userMobile : String = userIds.value(forKey:"usermobile") as? String{
                
                
                phoneNumberField.text = userMobile
                
                
            }
            
            if let userImageUrl : String = userIds.value(forKey:"userimage") as? String{
                
                if userImageUrl == "None"{
                    
                    if let userName : String = userIds.value(forKey:"username") as? String{
                        userImageView.image = LetterImageGenerator.imageWith(name:userName )
                    }
                    
                }else{
                    
                     userImageView.kf.setImage(with: URL.init(string: userImageUrl))
                    
                }
                
            }else{
                  if let userName : String = userIds.value(forKey:"username") as? String{
                userImageView.image = LetterImageGenerator.imageWith(name:userName )
                }
            }
        
        }
     
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.navigationItem.title = "Profile"
//
//        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.done))
//
//        var image = UIImage(named: "menu")
//        image = image?.withRenderingMode(.automatic)
//        let leftButton = UIBarButtonItem(image: image, style:.plain, target: nil, action: #selector(self.menuAction))
//
//        leftButton.tintColor = UIColor.white
//
//        self.tabBarController?.navigationItem.leftBarButtonItem = leftButton
        
        let editImage       = UIImage(named: "menu")!
        
        let menuButton      = UIBarButtonItem(image: editImage,  style: .plain, target: self, action: #selector(menuAction))
         doneItem  = UIBarButtonItem.init(title: "Edit", style: .plain, target: self, action:  #selector(done))
        
        self.tabBarController!.navigationItem.leftBarButtonItems = [menuButton]
        
       // self.tabBarController?.navigationItem.rightBarButtonItems = [doneItem]
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.leftBarButtonItems = nil
        
       // self.tabBarController?.navigationItem.rightBarButtonItems = nil
        
    }

    @objc func done() {
        
        if doneItem.title == "Save"{
            
             doneItem.title = "Edit"
            
        }else{
            
           doneItem.title = "Save"
        }
        
    }

    
    @IBAction func editBtnAction(_ sender: Any) {
        
        let alert = UIAlertController.init(title: "", message: "Add photo", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default , handler:{ (UIAlertAction)in
            
            
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authorizationStatus {
            case .notDetermined:
                // permission dialog not yet presented, request authorization
                AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                                          completionHandler: { (granted:Bool) -> Void in
                                                            if granted {
                                                                 self.openCamera()
                                                            }
                                                            else {
                                                               return
                                                            }
                })
            case .authorized:
                print("Access authorized", terminator: "")
            case .denied, .restricted: break
                
            default:
                print("DO NOTHING", terminator: "")
            }
           
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from library", style: .default , handler:{ (UIAlertAction)in
            let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            switch photoAuthorizationStatus {
            case .authorized:
                
                self.openGallary()
              
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({
                    (newStatus) in
                    print("status is \(newStatus)")
                    if newStatus ==  PHAuthorizationStatus.authorized {
                         self.openGallary()
                    }else{
                        
                        return
                    }
                })
                print("It is not determined until now")
            case .restricted:
                // same same
                print("User do not have access to photo album.")
            case .denied:
                // same same
                print("User has denied the permission.")
            }
        }))
        
       
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    
    @objc func menuAction(){
        
        let alert = UIAlertController.init()
        
//        alert.addAction(UIAlertAction(title: "Settings", style: .default , handler:{ (UIAlertAction)in
//            print("User click Approve button") 
//        }))
//
//        alert.addAction(UIAlertAction(title: "Rate us", style: .default , handler:{ (UIAlertAction)in
//            print("User click Edit button")
//        }))
//
//        alert.addAction(UIAlertAction(title: "Contact us", style: .default , handler:{ (UIAlertAction)in
//            print("User click Delete button")
//        }))
        
        alert.addAction(UIAlertAction(title: "SignOut", style: .destructive, handler:{ (UIAlertAction)in
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                UserDefaults.standard.removeObject(forKey: key.description)
            }
            
            UserDefaults.standard.removeObject(forKey: "loginDetails")
            
           NotificationCenter.default.post(name:NSNotification.Name.InstanceIDTokenRefresh , object: nil)
            
            
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
            
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDel.window?.rootViewController = loginVC
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        
    }
    
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.originalImage] as? UIImage {
            self.userImageView.contentMode = .scaleAspectFill
            self.userImageView.image = chosenImage
            
            self.dismiss(animated: true, completion: nil)
            
        } else{
            print("Something went wrong")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
