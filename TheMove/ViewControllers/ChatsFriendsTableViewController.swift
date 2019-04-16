//
//  ChatsFriendsTableViewController.swift
//  TheMove
//
//  Created by User 2 on 3/1/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import Kingfisher
import BRYXBanner
import PUGifLoading
import EFInternetIndicator

class ChatsFriendsTableViewController: UITableViewController,InternetStatusIndicable {
    var internetConnectionIndicator: InternetViewIndicator?
    
    var userArray : [Person] = []
    
     private lazy var channelRef: DatabaseReference = Database.database().reference().child("users")
    
     var arrayOfContacts : [Friends] = []
    
     var isMapsCall : Bool?
    
     let loading = PUGIFLoading()
    
    var canTransitionToLarge = false
    var canTransitionToSmall = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startMonitoringInternet()
        
       self.tabBarController?.navigationItem.rightBarButtonItems  = nil
        
        tableView.register(UINib(nibName: "ChatsTableViewCell", bundle: nil), forCellReuseIdentifier: "cells")
        
        
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
     
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.rightBarButtonItems  = nil
        
        if isMapsCall == true{
          
            isMapsCall = false
            self.navigationItem.title = "Chats"
            
        }else{
            
              self.tabBarController?.navigationItem.title = "Chats"
        }
        
        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
            
            print(userIds)
            
            if let userId : String = userIds.value(forKey:"userid") as? String{
                
                let params = ["userid": Int(userId)!]
                
                loading.hide()
                
                loading.show("Please wait....", gifimagename: "foodloader")
                
                ApiService.callPost(url: URL.init(string: Endpoints().chatList)!, params:params as [String : Any],viewcontroller: self, finish: finishPost)
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
                    
                    self.tableView.isHidden = false
                    self.tableView.tableFooterView = UIView.init()
                        
                    self.tableView.reloadData()
                        
                    }else{
                        
                        let labelView = UIView.init(frame: self.tableView.frame)
                        
                        let message = UILabel()
                        message.text = "No Chats"
                        message.translatesAutoresizingMaskIntoConstraints = false
                        message.lineBreakMode = .byWordWrapping
                        message.numberOfLines = 0
                        message.textAlignment = .center
                        message.frame = CGRect.init(x: 0, y:  self.view.frame.height / 3, width: self.tableView.frame.width, height: 50)
                        
                        labelView.addSubview(message)
                        self.tableView.tableFooterView = labelView
                        
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
                let json = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                
                let loginDetails : NSDictionary = json as! NSDictionary
                
                print(loginDetails)
                
                
                DispatchQueue.main.async {
                    
                    if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                        
                        print(userIds)
                        
                        if let userId : String = userIds.value(forKey:"userid") as? String{
                            
                            let params = ["userid": Int(userId)!]
                            
                            self.loading.hide()
                            
                            self.loading.show("Please wait....", gifimagename: "foodloader")
                            
                            ApiService.callPost(url: URL.init(string: Endpoints().chatList)!, params:params as [String : Any],viewcontroller: self, finish: self.finishPost)
                            
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
    
    func autohide()
    {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            
            self.loading.hide()
        }
    }
    
    func processLogin(_ user:AnyObject?,_ username: String,_ email: String,_ userId: String,_ photodataurl: String) {
        guard let uid = user?.user.uid else {
            return
        }
        
        UserDefaults.standard.set(userId, forKey: "UserID")
        UserDefaults.standard.set(uid, forKey: "ChatID")
        UserDefaults.standard.synchronize()
        
        let values = ["name": username, "email": email]
        
        self.registerUserIntoDatabaseWithUID(uid,username,userId,photodataurl,values: values as [String : AnyObject])
        
    }
    
     func registerUserIntoDatabaseWithUID(_ uid: String,_ username: String,_ userId: String,_ photodataurl: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
            
            print(ref)
        
        })
    }
    
    
    func fetchUser(){
        
        Database.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
            
            let dict : NSDictionary = snapshot.value as! NSDictionary
            
            let obj = Person()
            
            obj.id = snapshot.key
            
            obj.email = dict.value(forKey: "email") as? String
            
            obj.name = dict.value(forKey: "name") as? String
            
            obj.profileImageUrl = dict.value(forKey: "profileImageUrl") as? String
            
            self.userArray.append(obj)
            
            DispatchQueue.main.async {
                
             self.tableView.reloadData()
                
            }
        }, withCancel: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayOfContacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cells", for: indexPath) as! ChatsTableViewCell

         let obj = arrayOfContacts[indexPath.row]
        
        if let imageUrl = obj.imageUrl{
            
            if imageUrl == "None"{
                
                 cell.imagesView.image = LetterImageGenerator.imageWith(name: obj.name)
                
            }else{
                
                cell.imagesView.kf.setImage(with: URL.init(string: imageUrl))
                
            }
    
        }else{
            
          cell.imagesView.image = LetterImageGenerator.imageWith(name: obj.name)
            
        }
      
        cell.imagesView.layer.cornerRadius = cell.imagesView.frame.width / 2
        
        cell.imagesView.layer.borderWidth = 1.0
        
         let color2 = UIColor(rgb: 0xFF8C00)
        
         cell.imagesView.layer.borderColor = color2.cgColor
        
        cell.imagesView.layer.masksToBounds = true
        
         cell.nameLabel.text = obj.name
        
         cell.emailLabel.text = obj.email

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
          let obj = arrayOfContacts[indexPath.row]
        
            if obj.status == "Y"{
                
            let obj = Person()
            
            obj.profileImageUrl = self.arrayOfContacts[indexPath.row].imageUrl
            
            obj.name = self.arrayOfContacts[indexPath.row].name
            
            obj.id = self.arrayOfContacts[indexPath.row].chatId
            
            obj.email = self.arrayOfContacts[indexPath.row].email
            
            
            let dictionary = ["name": obj.name as AnyObject, "id": obj.id as AnyObject , "profileImageUrl": obj.profileImageUrl!,"fbuserid":self.arrayOfContacts[indexPath.row].userId!] as [String : AnyObject]
                
            let user = User(dictionary: dictionary as [String : AnyObject])
            self.showChatControllerForUser(user)
             }else{
                
                
                let alertController = UIAlertController(title: "Unblock", message: "Please unblock to continue chat ", preferredStyle:UIAlertController.Style.alert)
                
                alertController.addAction(UIAlertAction(title: "Unblock", style: UIAlertAction.Style.default)
                { action -> Void in
                    
                    if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                        
                        print(userIds)
                        
                        if let userId : String = userIds.value(forKey:"userid") as? String{
                            
                            let params = ["user_id": Int(userId)!, "friend_id" : obj.userId!] as [String : Any]
                            
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
         let color2 = UIColor(rgb: 0xFF8C00)
        
         let obj = arrayOfContacts[indexPath.row]
        
        let editAction = UITableViewRowAction(style: .normal, title: "block") { (rowAction, indexPath) in
            
                if obj.status ==  "N"{
                    
                    let alertController = UIAlertController(title: "Unblock", message: "Are you sure to Unblock this User", preferredStyle:UIAlertController.Style.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default)
                    { action -> Void in
                        
                        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                            
                            print(userIds)
                            
                            if let userId : String = userIds.value(forKey:"userid") as? String{
                                
                                let params = ["user_id": Int(userId)!, "friend_id" : obj.userId!] as [String : Any]
                                
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
                
                
                    
                
            }else{
                    
                    let alertController = UIAlertController(title: "Block" , message: "Are you sure to block this User", preferredStyle:UIAlertController.Style.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default)
                    { action -> Void in
                        
                        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                            
                            print(userIds)
                            
                            if let userId : String = userIds.value(forKey:"userid") as? String{
                                
                                let params = ["user_id": Int(userId)!, "friend_id" : obj.userId!] as [String : Any]
                                
                                self.loading.hide()
                                
                                self.loading.show("Please wait....", gifimagename: "foodloader")
                                
                                ApiService.callPost(url: URL.init(string: Endpoints().chatBlack)!, params:params as [String : Any],viewcontroller: self, finish: self.blockFinishPost)
                                
                            }
                        }
                        
                      
                    })
                    
                    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                    { action -> Void in
                        
                        
                    })
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    
                
            }
          
            
            
        }
  
        if obj.status ==  "N"{
            
             editAction.title = "UnBlock"
             editAction.backgroundColor = .red
            
        }else{
            editAction.backgroundColor = color2
             editAction.title = "Block"
        }
    
    
        
        return [editAction]
    }
    
   
    func showChatControllerForUser(_ user: User) {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
