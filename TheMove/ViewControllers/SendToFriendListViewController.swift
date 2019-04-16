//
//  SendToFriendListViewController.swift
//  TheMove
//
//  Created by User 2 on 4/8/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import PUGifLoading
import BRYXBanner
import CoreLocation

class SendToFriendListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var addingListView: UITableView!
    
       var arrayOfContacts : [Friends] = []
    
     let loading = PUGIFLoading()
    
    var lastSelectedIndexPath = NSIndexPath(row: -1, section: 0)
    
     var arrayOfids : [String] = []
    
    var messageStr : String?
    
     let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sending to Friends"
        
        if messageStr != "NOW"{
            
        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
            
            
            print(userIds)
            
            if let userId : String = userIds.value(forKey:"userid") as? String{
                
                let params = ["userid": Int(userId)!]
                
                loading.hide()
                
                loading.show("Please wait....", gifimagename: "foodloader")
                
                ApiService.callPost(url: URL.init(string: Endpoints().friendList)!, params:params as [String : Any],viewcontroller: self, finish: finishPost)
                
            }
        }
        }else{
            
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                guard let currentLocation = locationManager.location else {
                    return
                }
                
                if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                    
                    print(userIds)
                    
                    if let userId : String = userIds.value(forKey:"userid") as? String{
                        
                        let params = ["userid": Int(userId)! , "latitude":"\(currentLocation.coordinate.latitude)", "longitude": "\(currentLocation.coordinate.longitude)" , "kmradius" : 5] as [String : Any]
                        
                        ApiService.callPost(url: URL.init(string: Endpoints().locationUpdate)!, params:params as [String : Any],viewcontroller: self, finish: finishPost)
                        
                    }
                }
            }
 
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
        
        if let imageUrl = obj.imageUrl{
            
            if imageUrl == "None"{
                
                imageView.image = LetterImageGenerator.imageWith(name: obj.name)
                
            }else{
                
                imageView.kf.setImage(with: URL.init(string: imageUrl))
            }
        }else{
            
            imageView.image = LetterImageGenerator.imageWith(name: obj.name)
        }
        
        imageView.layer.cornerRadius = imageView.frame.height / 2
        
        
        imageView.layer.borderWidth = 1.0
        
        let color2 = UIColor(rgb: 0xFF8C00)
        
        imageView.layer.borderColor = color2.cgColor
        
        imageView.clipsToBounds = true
        
        
        
        if cell.isSelected
        {
            cell.isSelected = false
            if cell.accessoryType == UITableViewCell.AccessoryType.none
            {
                
                
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            else
            {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        let obj = arrayOfContacts[indexPath.row]
        
        if cell!.isSelected
        {
            cell!.isSelected = false
            
            if cell!.accessoryType == UITableViewCell.AccessoryType.none
            {
                cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
                
                arrayOfids.append(obj.userId ?? "")
            }
            else
            {
                cell!.accessoryType = UITableViewCell.AccessoryType.none
                
                arrayOfids.removeAll { $0 == obj.userId }
            }
            
            print(arrayOfids)
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
                
                
                print(json)
                
                let loginDetails : NSDictionary = json as! NSDictionary
                
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
                    if self.arrayOfContacts.count != 0 {
                        
                        self.addingListView.isHidden = false
                        
                        self.addingListView.delegate = self
                        
                        self.addingListView.dataSource = self
                        
                        self.addingListView.tableFooterView = UIView.init()
                        
                        self.addingListView.reloadData()
                        
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
    
    func convertDateFormatter(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let convertedDate = dateFormatter.date(from: date)
        return convertedDate!
    }
    
    func autohide()
    {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            
            self.loading.hide()
        }
    }
    
    
    func sendnotification(){
        
        if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
            
            
            if let userId : String = userIds.value(forKey:"userid") as? String , let userName =  userIds.value(forKey:"username") as? String {
                let params = ["title": userName ,"message": messageStr!
                    ,"userid":userId,"friendid": arrayOfids.joined(separator: ",")] as [String : Any]
                
                ApiService.callPost(url: URL.init(string: Endpoints().notificationUrl)!, params:params as [String : Any],viewcontroller: self, finish: sentNotification)
            }
        }
    }
    
    func sentNotification (message:String, data:Data?) -> Void
    {
        do
        {
            if let jsonData = data
            {
                let json = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                
                let loginDetails : NSDictionary = json as! NSDictionary
                
                print(loginDetails)
                DispatchQueue.main.async {
                    
                  self.popBack(3)
                    
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
    
    
    @IBAction func sentBtnAction(_ sender: Any) {
        
        sendnotification()
    }
    
    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
    
}
