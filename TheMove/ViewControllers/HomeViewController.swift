//
//  HomeViewController.swift
//  TheMove
//
//  Created by User 2 on 3/5/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import SDWebImage
import BRYXBanner
import PUGifLoading
import EFInternetIndicator

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate,UINavigationControllerDelegate,TabbersDelegetes,InternetStatusIndicable {
    var internetConnectionIndicator: InternetViewIndicator?
    
    
    @IBOutlet weak var hotelListView: UITableView!
    
    var banner = Banner()
    
    var hotelsArray: [Hotels] = []
    
    var animationsQueue = ChainedAnimationsQueue()
    
     let loading = PUGIFLoading()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startMonitoringInternet()
      
        hotelListView.isHidden = true
        
       self.navigationItem.largeTitleDisplayMode = .always
        
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationController?.navigationBar.barStyle  = .black
        
        hotelListView.register(UINib.init(nibName: "HotelTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
       
        hotelListView.backgroundColor = UIColor.black
        
        loading.hide()
        
        loading.show("Please wait....", gifimagename: "foodloader")
        
       
      ApiService.callGet(url: URL.init(string: "http://goflexi.in/ecommerce/APP/API/user/restaurants")!, params: [:],viewcontroller: self, finish: finishPost)
        
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.tabBarController?.navigationController?.navigationBar.isHidden = false
        
        self.tabBarController?.navigationItem.title = "Bars"
        
        hotelListView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    
        
    }
    override func viewDidLayoutSubviews() {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func autohide()
    {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            
            self.loading.hide()
        }
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return .none
    }
    
    func finishPost (message:String, data:Data?) -> Void
    {
        self.autohide()
        do {
            
            if let jsonData = data
            {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any] { // as? data type
                print(json)
                
                
                if let restaurantsDict = json["restaurants"] as? NSDictionary {
                    
                   
                    print(restaurantsDict)
                    
                    for rest in restaurantsDict{
                       
                        let values : NSDictionary = rest.value as! NSDictionary
                        
                        let hotelObj = Hotels()
                        
                        hotelObj.hotelId = values.value(forKey: "id") as? String
                        hotelObj.hotelTitle = values.value(forKey: "name") as? String
                        hotelObj.hotelImageUrl = values.value(forKey: "image") as? String
                        
                        hotelObj.hotelAddress = values.value(forKey: "address") as? String
                        
                        hotelsArray.append(hotelObj)
                    }
                    DispatchQueue.main.async {
                        self.hotelListView.isHidden = false
                        self.hotelListView.reloadData()
                    }
                  
                }
                }
                
            }else{
                
                DispatchQueue.main.async {
                    
                    self.banner = Banner(title: "Oops", subtitle: message, image: UIImage(named: "Offline"), backgroundColor: UIColor.red)
                    self.banner.dismissesOnTap = true
                    self.banner.show()
    
                }
 
            }
        } catch {
            
            print("error")
            
        }
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotelsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : HotelTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HotelTableViewCell
     
        let color2 = UIColor(rgb: 0xFF8C00)
        
        cell.centerView.backgroundColor = UIColor.brown
        
        let obj = hotelsArray[indexPath.row]
        
        cell.titleLabel.text = obj.hotelTitle
        
        cell.titleLabel.textColor = .white
        
        if let images = obj.hotelImageUrl{
            cell.hotelImageView.sd_setImage(with: URL.init(string: images ), placeholderImage: UIImage(named: "profile"),options: SDWebImageOptions(rawValue: 0), completed: { (img, err, cacheType, imgURL) in
                
                if err != nil{
                    print(err!)
                }
            })
        }
        
        cell.centerView.layer.cornerRadius = 10
        
        cell.centerView.layer.masksToBounds = true
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 150
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = hotelsArray[indexPath.row]
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let initialViewControlleripad  = mainStoryBoard.instantiateViewController(withIdentifier: "MapsViewController") as! MapsViewController
        
        initialViewControlleripad.hotelNameStr = obj.hotelTitle
        
        initialViewControlleripad.addressStr = obj.hotelAddress
        
        initialViewControlleripad.delegetes = self
        
        self.navigationController?.pushViewController(initialViewControlleripad, animated: true)
        
    }
    func didTap(viewName : String){
        
        
        print(viewName)
        
        if viewName == "friends"{
            
            self.tabBarController?.selectedViewController = tabBarController?.viewControllers?[1]
            
            self.tabBarController?.selectedViewController?.navigationItem.title = "friends"
            
        }else{
            
            self.tabBarController?.selectedViewController = tabBarController?.viewControllers?[2]
            
            self.tabBarController?.selectedViewController?.navigationItem.title = "Chats"
        }
    }
}


class Hotels: NSObject {
   
    var hotelTitle: String?
    
    var hotelImageUrl: String?
    
    var hotelId : String?
    
    var hotelAddress : String?
}


