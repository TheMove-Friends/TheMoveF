//
//  FriendsListViewController.swift
//  TheMove
//
//  Created by User 2 on 2/27/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import Kingfisher
import ExpandingMenu
import ContactsUI
import BRYXBanner
import Firebase
import HSPopupMenu
import PUGifLoading
import EFInternetIndicator

class FriendsListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource ,CNContactPickerDelegate , googleContactDelegate ,UINavigationControllerDelegate,InternetStatusIndicable {
    var internetConnectionIndicator: InternetViewIndicator?
    
    var contactStore = CNContactStore()
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var FriendsListView: UITableView!
    
    var arrayOfContacts : [Friends] = []
    
    var googleAuthStr : String?
    
    var animationsQueue = ChainedAnimationsQueue()
    
    var db: DatabaseReference!
    
    var isMapsCall : Bool?
    
    let loading = PUGIFLoading()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startMonitoringInternet()
        
         
        
        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
            
            
            print(userIds)
            
            if let userId : String = userIds.value(forKey:"useremail") as? String{
                
    
                Auth.auth().signIn(withEmail: userId, password: userId, completion: { (userSignIn, error) in
                    
                    if error != nil {
                        print(error ?? "")
                        return
                    }
                })
            }
        }
                
        
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
         self.tabBarController?.navigationItem.title = "Friends"
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationController?.navigationBar.barStyle  = .black
        
        FriendsListView.isHidden = true
        
        FriendsListView.tableFooterView = UIView.init()
       
      
       
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
                 super.viewWillAppear(animated)
        
        if isMapsCall == true{
            
            self.navigationItem.title = "Friends"
            
            
            
            let addBtn = UIBarButtonItem.menuButton(self, action: #selector(addFriends), imageName: "addFri")
            
            self.navigationItem.rightBarButtonItems = [addBtn]
        
        
            
        }else{
            
            self.tabBarController?.navigationItem.title = "Friends"
            
            
            let addBtn = UIBarButtonItem.menuButton(self, action: #selector(addFriends), imageName: "addFri")
            
            self.tabBarController!.navigationItem.rightBarButtonItems = [addBtn]
            
            
        }
        
        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
            
            
            print(userIds)
            
            if let userId : String = userIds.value(forKey:"userid") as? String{
                
                let params = ["userid": Int(userId)!]
                
                loading.hide()
                
                arrayOfContacts.removeAll()
                
                loading.show("Please wait....", gifimagename: "foodloader")
                
                ApiService.callPost(url: URL.init(string: Endpoints().friendList)!, params:params as [String : Any],viewcontroller: self, finish: finishPost)
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if isMapsCall == true{
    
            self.navigationItem.rightBarButtonItems = nil
            
        }else{
        
            self.tabBarController!.navigationItem.rightBarButtonItems = nil
            
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func autohide()
    {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            
            self.loading.hide()
        }
    }
    
    @objc func addFriends(){
        
        DispatchQueue.main.async {
        
        let menu1 = HSMenu(icon: UIImage(named: "Invite"), title: "Invite")
        let menu2 = HSMenu(icon: UIImage(named: "mailContact"), title: "Via Google")
        let menu3 = HSMenu(icon: UIImage(named: "contacts"), title: "Via Contact")
        
        let popupMenu = HSPopupMenu(menuArray: [menu1,menu2,menu3] , arrowPoint: CGPoint(x: UIScreen.main.bounds.width-35, y: 64))
        popupMenu.popUp()
        popupMenu.delegate = self
            
        }
    }
    
    
    func finishPost (message:String, data:Data?) -> Void
    {
        
        self.autohide()
        
        do
        {
            if let jsonData = data
            {
                 if let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any] {
                
                    let loginDetails : NSDictionary = json as NSDictionary
                
                arrayOfContacts.removeAll()
     
                if let dict = loginDetails.value(forKey: "restaurants"){
                    
                    let dicts : NSDictionary = dict as! NSDictionary
                    
                    print(dicts)
                    
                    
                    for values in dicts{
                        
                        let friDict: NSDictionary = values.value as! NSDictionary
                        
                      let friendObj = Friends()
                        
                        friendObj.email = friDict.value(forKey: "email") as? String
                        
                        friendObj.imageUrl = friDict.value(forKey: "image_url") as? String
                        
                        friendObj.mobile = friDict.value(forKey: "mobile") as? String
                        friendObj.name = friDict.value(forKey: "name") as? String
                        
                        friendObj.userId = friDict.value(forKey: "userid") as? String
                        
                        friendObj.updateTime = friDict.value(forKey: "last_update_datetime") as? String
                        
                        friendObj.chatId = friDict.value(forKey: "chatid") as? String
                        
                        friendObj.status = friDict.value(forKey: "status") as? String
                        
                        arrayOfContacts.append(friendObj)
                        
                    }
                }
                
                
                
                DispatchQueue.main.async {
                    
                    
                    
                    if self.arrayOfContacts.count != 0{
                        
                        self.FriendsListView.isHidden = false
                        self.FriendsListView.tableFooterView = UIView.init()
                        
                        self.FriendsListView.reloadData()
                        
                    }else{
                        self.FriendsListView.reloadData()
                        let labelView = UIView.init(frame: self.FriendsListView.frame)
                        
                        let message = UILabel()
                        message.text = "No Friends"
                        message.translatesAutoresizingMaskIntoConstraints = false
                        message.lineBreakMode = .byWordWrapping
                        message.numberOfLines = 0
                        message.textAlignment = .center
                        message.frame = CGRect.init(x: 0, y:  self.view.frame.height / 3, width: self.FriendsListView.frame.width, height: 50)
                        
                        labelView.addSubview(message)
                        self.FriendsListView.tableFooterView = labelView
                        
                    }
            
                   
                }
                }
            }else{
                
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
    
    func addFriendsApi(message:String, data:Data?) -> Void
    {
        
        do
        {
            if let jsonData = data
            {
                let json = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                
                let loginDetails : NSDictionary = json as! NSDictionary
                
                print(loginDetails)
                
                DispatchQueue.main.async {
                    
                    let success : Bool = loginDetails.value(forKey: "success") as! Bool
                    
                    if success != true{
                    
                    let alertController = UIAlertController(title: "Oops", message: loginDetails.value(forKey: "err_mode") as? String, preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Invite", style: UIAlertAction.Style.default) {
                        UIAlertAction in

                        let appID = "1458083790"
                        
                        
                        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                            
                            
                            print(userIds)
                            
                    if let userName : String = userIds.value(forKey:"username") as? String{
                                

                                
                           
                        let someText:String = "\(userName) Invited you to the Gathering friends. Download TheMove and join now"
                        let objectsToShare:URL = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)")!
                        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
                        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        
                        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail , UIActivity.ActivityType.message]
                        
                        self.present(activityViewController, animated: true, completion: nil)
                              
                            }
                        }

                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        UIAlertAction in
                        NSLog("Cancel Pressed")
                    }
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                
                    
//                    if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
//
//
//                        print(userIds)
//
//                        if let userId : String = userIds.value(forKey:"userid") as? String{
//
//                            let params = ["userid": Int(userId)!]
//
//                            self.loading.hide()
//
//                            self.loading.show("Please wait....", gifimagename: "foodloader")
//
//                            ApiService.callPost(url: URL.init(string: Endpoints().addFriendList)!, params:params as [String : Any],viewcontroller: self, finish: self.finishPost)
//
//                        }
//                    }
      
                    }else{
                        
                        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                            
                            print(userIds)
                            
                            if let userId : String = userIds.value(forKey:"userid") as? String{
                                
                                let params = ["userid": Int(userId)!]
                                
                                self.loading.hide()
                                
                                self.loading.show("Please wait....", gifimagename: "foodloader")
                                
                                ApiService.callPost(url: URL.init(string: Endpoints().friendList)!, params:params as [String : Any],viewcontroller: self, finish: self.finishPost)
                                
                            }
                        }
                        
                    }
                }
            }
            else{
                
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
    
    func removeFriends (message:String, data:Data?) -> Void
    {
        do
        {
            if let jsonData = data
            {
                if let json = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any]{
                
                    let loginDetails : NSDictionary = json as NSDictionary
                
                print(loginDetails)
                
                DispatchQueue.main.async {
                    
                    if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                        
                        
                        print(userIds)
                        
                        if let userId : String = userIds.value(forKey:"userid") as? String{
                            
                            let params = ["userid": Int(userId)!]
                            
                            self.loading.hide()
                            
                            self.loading.show("Please wait....", gifimagename: "foodloader")
                            
                            ApiService.callPost(url: URL.init(string: Endpoints().friendList)!, params:params as [String : Any],viewcontroller: self, finish: self.finishPost)
                            
                        }
                    }
                    
                }
                }
                
            }else{
                
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
    
    func blockFinishPost (message:String, data:Data?) -> Void
    {
        self.autohide()
        
        do
        {
            if let jsonData = data
            {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any] {
                let loginDetails : NSDictionary = json as! NSDictionary
                
                print(loginDetails)
                
                
                DispatchQueue.main.async {
                    
                    if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                        
                        print(userIds)
                        
                        if let userId : String = userIds.value(forKey:"userid") as? String{
                            
                            let params = ["userid": Int(userId)!]
                            
                            self.loading.hide()
                            
                            self.loading.show("Please wait....", gifimagename: "foodloader")
                            
                            ApiService.callPost(url: URL.init(string: Endpoints().friendList)!, params:params as [String : Any],viewcontroller: self, finish: self.finishPost)
                            
                        }
                    }
                    
                    }
                    
                }
            }else{
                
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
    
    func deleteByID(id : String){
        
        db = Database.database().reference().child("users")
        db.child(id).removeValue()
        
    }
    func didTap(friend: GoogleContact) {
        
        setupNavigation()
        
        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
            
            
            print(userIds)
            
            if let userId : String = userIds.value(forKey:"userid") as? String{
                if let email = friend.email{
            let params = ["userid":Int(userId)!,"frdemail":email,"frdmobile":"","checktype":"gmail"] as [String : Any]
        
        print(params)
        
         ApiService.callPost(url: URL.init(string: Endpoints().addFriendList)!, params:params as [String : Any],viewcontroller: self, finish: addFriendsApi)
                }else{
                    
                   self.alert(message: "Invaild User", title: "Oops")
                }
            
        print(friend.name!)
            
    }
        }
    }
    
    func back(){
        
      setupNavigation()
        
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // You can fetch selected name and number in the following way
        
        setupNavigation()
        // user name
        let userName:String = contact.givenName
        
        // user phone number
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
        
        
        // user phone number string
        let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
        
//        let str = primaryPhoneNumberStr.trimmingCharacters(in: .whitespaces)
        let withoutSpaces = primaryPhoneNumberStr.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)

        
        
        
        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
            
            
            print(userIds)
            
            if let userId : String = userIds.value(forKey:"userid") as? String{
        
            let params = ["userid":Int(userId)!,"frdemail":"","frdmobile": withoutSpaces,"checktype":"contact"] as [String : Any]

            print(params)
        
        ApiService.callPost(url: URL.init(string: Endpoints().addFriendList)!, params:params as [String : Any],viewcontroller: self, finish: addFriendsApi)
        }
        }
        
        print(primaryPhoneNumberStr)
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
        setupNavigation()
        
    }
    
    func setupNavigation(){
        if isMapsCall == true{
            
            self.navigationItem.title = "Friends"
            
            let addBtn = UIBarButtonItem.menuButton(self, action: #selector(addFriends), imageName: "addFri")
            
            self.navigationItem.rightBarButtonItems = [addBtn]
            
            
        }else{
            
            self.tabBarController?.navigationItem.title = "Friends"
            
            
            let addBtn = UIBarButtonItem.menuButton(self, action: #selector(addFriends), imageName: "addFri")
            
            self.tabBarController!.navigationItem.rightBarButtonItems = [addBtn]
            
        }
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfContacts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier:  "cell")!
        
        let obj = arrayOfContacts[indexPath.row]
        
        let label = cell.viewWithTag(2) as! UILabel
        
        print(obj.updateTime ?? "")
        
        label.text = obj.name
        
        let labelAlert = cell.viewWithTag(3) as! UILabel
        
        labelAlert.text = timeAgoSince(convertDateFormatter(date: obj.updateTime!))
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        
        if let images = obj.imageUrl{
    
            if images == "None"{
                
              imageView.image = LetterImageGenerator.imageWith(name: obj.name)
                
            }else{
                
                let url = URL(string:images)
                imageView.kf.setImage(with: url)
                
            }
           
            
        }else{
            
            imageView.image = LetterImageGenerator.imageWith(name: obj.name)
        }
        
        imageView.layer.cornerRadius = imageView.frame.height / 2
        
        
        imageView.layer.borderWidth = 1.0
        
         let color2 = UIColor(rgb: 0xFF8C00)
        
        imageView.layer.borderColor = color2.cgColor
        
        
        
        imageView.clipsToBounds = true
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
     
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90
    }
    
    func showChatControllerForUser(_ user: User) {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0.0
        animationsQueue.queue(withDuration: 0.4, initializations: {
            cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, cell.frame.size.width, 0, 0)
        }, animations: {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        })
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let objs = self.arrayOfContacts[indexPath.row]
         let color2 = UIColor(rgb: 0xFF8C00)
        let editAction = UITableViewRowAction(style: .normal, title: "Chat") { (rowAction, indexPath) in
   
            if objs.status == "Y"{

            let obj = Person()

            obj.profileImageUrl = self.arrayOfContacts[indexPath.row].imageUrl

            obj.name = self.arrayOfContacts[indexPath.row].name

            obj.id = self.arrayOfContacts[indexPath.row].chatId

            obj.email = self.arrayOfContacts[indexPath.row].email


            let dictionary = ["name": obj.name as AnyObject, "id": obj.id as AnyObject , "profileImageUrl": obj.profileImageUrl!,"fbuserid":self.arrayOfContacts[indexPath.row].userId!] as [String : AnyObject]
            let user = User(dictionary: dictionary as [String : AnyObject])
            self.showChatControllerForUser(user)
                
            }else{
                let alertController = UIAlertController(title: "Unblock", message: "Are you sure to Unblock this User", preferredStyle:UIAlertController.Style.alert)
                
                alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default)
                { action -> Void in
                    
                    if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                        
                        print(userIds)
                        
                        if let userId : String = userIds.value(forKey:"userid") as? String{
                            
                            let params = ["user_id": Int(userId)!, "friend_id" : objs.userId!] as [String : Any]
                            
                            self.loading.hide()
                            
                            self.loading.show("Please wait....", gifimagename: "foodloader")
                            
                            ApiService.callPost(url: URL.init(string: Endpoints().chatUnBlack)!, params:params as [String : Any],viewcontroller: self, finish: self.blockFinishPost)
                            
                        }
                    }
                })
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                { action -> Void in
                    
                    
                })
                
                self.present(alertController, animated: true, completion: nil)
                
                
                
            }

        }
          if objs.status == "Y"{
            
             editAction.backgroundColor = .black
            
           editAction.title = "chat"
            
          }else{
            
             editAction.backgroundColor = color2
            
            editAction.title = "Unblock"
            
        }
       
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Remove") { (rowAction, indexPath) in
           
            if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                
                
                let obj = self.arrayOfContacts[indexPath.row]
                
                if let userId : String = userIds.value(forKey:"userid") as? String{
                    
                    let friendId : Int = Int(obj.userId!)!
                    
                    
                    let params = ["userid": Int(userId)! , "friendid" : friendId] as [String : Any]

                    ApiService.callPost(url: URL.init(string: Endpoints().removeFriend)!, params:params as [String : Any],viewcontroller: self, finish: self.removeFriends)
                    
                   
                    self.deleteByID(id: obj.chatId ?? "")
                    
                }
            }
        }
        deleteAction.backgroundColor = .red
        
        return [editAction,deleteAction]
    }
    
    func convertDateFormatter(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let convertedDate = dateFormatter.date(from: date)
        return convertedDate!
    }
    
    

}

class Friends : NSObject{
    
     var email : String?
     var imageUrl : String?
     var mobile : String?
     var name : String?
     var userId : String?
     var updateTime : String?
     var chatId : String?
    var status : String?
   
}


extension FriendsListViewController: HSPopupMenuDelegate {
    func popupMenu(_ popupMenu: HSPopupMenu, didSelectAt index: Int) {
        
        
        if index == 0{
            
            
            if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                
                
                print(userIds)
                
            if let userName : String = userIds.value(forKey:"username") as? String{

            let appID = "1458083790"
            
          
             let someText:String = "\(userName) Invited you to the Gathering friends. Download TheMove and join now"
            let objectsToShare:URL = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)")!
            let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail , UIActivity.ActivityType.message]
            
            self.present(activityViewController, animated: true, completion: nil)
                }
                
            }
            
        }else if index == 1{
            
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let VC = mainStoryBoard.instantiateViewController(withIdentifier: "GoogleContactViewController") as! GoogleContactViewController
            VC.delegates = self
            self.present(VC, animated: true, completion: nil)
            
            
        }else{
            
            
            switch CNContactStore.authorizationStatus(for: .contacts){
            case .authorized:
                addcontact()
            case .notDetermined:
                contactStore.requestAccess(for: .contacts){succeeded, err in
                    guard err == nil && succeeded else{
                        return
                    }
                    
                    self.addcontact()
                }
            case .denied:
                
                contactStore.requestAccess(for: .contacts){succeeded, err in
                    guard err == nil && succeeded else{
                        return
                    }
                    
                    self.addcontact()
                }
        
                break
                
            
            case .restricted:
           
                break
            
            default:
                
                print("Not handled")
                
            }
        }
      
    }
    
    func addcontact(){
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactGivenNameKey
                , CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true, completion: nil)
    }
  
}
