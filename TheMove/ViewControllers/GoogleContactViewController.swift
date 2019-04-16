//
//  GoogleContactViewController.swift
//  TheMove
//
//  Created by User 2 on 3/14/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import GoogleSignIn
import SDWebImage
import Alamofire
import Kingfisher
import PUGifLoading
import EFInternetIndicator

protocol googleContactDelegate{
    
    func didTap(friend : GoogleContact)
    
    func back()
    
}

class GoogleContactViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource , GIDSignInUIDelegate,GIDSignInDelegate,InternetStatusIndicable{
    var internetConnectionIndicator: InternetViewIndicator?
    
    
    var delegates : googleContactDelegate!

    @IBOutlet weak var googleContactListView: UITableView!
    
    var googleAuthStr : String?
    
     var arrayOfContacts : [GoogleContact] = []
    
     var animationsQueue = ChainedAnimationsQueue()
    
     let loading = PUGIFLoading()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startMonitoringInternet()
        
            googleContactListView.isHidden = true
        
            GIDSignIn.sharedInstance().uiDelegate = self
            
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().scopes = ["https://www.google.com/m8/feeds/"]
            GIDSignIn.sharedInstance().clientID = "123746515481-vei54uk68qfgctqm0c3qko7nfjfs81ae.apps.googleusercontent.com"
            GIDSignIn.sharedInstance().signIn()
     

    }
    
    func getGoogleFriendsList(googleAuth : String){
        
        loading.hide()
        
        loading.show("Please wait....", gifimagename: "foodloader")
        
        let urlString = ("https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=5000&access_token=\(googleAuth)")
   
        _ = Alamofire.request(urlString, method: .get, parameters: [:], encoding: URLEncoding.queryString, headers: ["Content-Type" :"application/json"]).responseJSON { (response) in
            
            let resp: NSDictionary = response.value as! NSDictionary
            
            let feedDict: NSDictionary = resp.value(forKey: "feed") as! NSDictionary
            
            let arrayOfcontact:[NSDictionary] = feedDict.value(forKey: "entry") as! [NSDictionary]
            
            self.arrayOfContacts.removeAll()
            
            for values in arrayOfcontact{
                
                print(values)
                
                let name: NSDictionary = values.value(forKey: "title") as! NSDictionary
                
                let images:[NSDictionary] = values.value(forKey: "link") as! [NSDictionary]
                
                
                let obj = GoogleContact()
                
                if let ggoogle : [NSDictionary] = values.value(forKey: "gd$email") as?  [NSDictionary] {
                    
                    obj.email = ggoogle[0].value(forKey: "address") as? String
            
              
                    
                    }
                  obj.name = name.value(forKey: "$t") as? String
                
                for image in images{
                    let rel: String = image.value(forKey: "rel") as! String
                    
                    if  rel == "http://schemas.google.com/contacts/2008/rel#photo"{
                        
                        obj.image = image.value(forKey: "href") as? String
                        
                    }
                }
                
                self.arrayOfContacts.append(obj)
                
                DispatchQueue.main.async {
                    
                    self.googleContactListView.isHidden = false
                    self.googleContactListView.delegate = self
                    self.googleContactListView.dataSource = self
                    
                    self.autohide()
                    self.googleContactListView.reloadData()
                    
                }
                
            }
        }
        
    }
    
    func autohide()
    {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            
            self.loading.hide()
        }
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        
        self.delegates.back()
        self.dismiss(animated: true, completion: nil)
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
        
        if obj.name != "" {
            
            label.text = obj.name
            
        }else{
            
             label.text = obj.email
            
        }

        let imageView = cell.viewWithTag(1) as! UIImageView

        if let images = obj.image{


            print("\(images)?access_token=\(String(describing: googleAuthStr!))")

            let url = URL(string:"\(images)?access_token=\(String(describing: googleAuthStr!))")

            let roundCorner = RoundCornerImageProcessor(cornerRadius: imageView.frame.width / 2)
            imageView.kf.setImage(with: url,
                                  options: [.processor(roundCorner),
                                            .cacheSerializer(FormatIndicatedCacheSerializer.png)])

        }
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) {
            
            self.delegates.didTap(friend: self.arrayOfContacts[indexPath.row])
        
        }
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
            
            
            googleAuthStr = userAuth.authentication.accessToken!
            
            getGoogleFriendsList(googleAuth: userAuth.authentication.accessToken)

        }
    }
}

class GoogleContact : NSObject{

    var name: String?
    
    var image : String?
    
    var email : String?
    
    var phone : String?
}
