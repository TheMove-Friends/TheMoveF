//
//  HomeTabbarViewController.swift
//  TheMove
//
//  Created by User 2 on 3/5/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import BRYXBanner
import EFInternetIndicator
import CoreLocation

class HomeTabbarViewController: UITabBarController ,InternetStatusIndicable,CLLocationManagerDelegate{
    var internetConnectionIndicator: InternetViewIndicator?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.startMonitoringInternet()
        
        locationManager.requestWhenInUseAuthorization()

        locationFunctions()
        timerSetup()
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
        
         self.tabBarController?.navigationController?.navigationBar.isHidden = false
       
    }
    
    func timerSetup(){
        
        DispatchQueue.global(qos: .background).sync {
            
            let timer = Timer.scheduledTimer(timeInterval: 60 * 10, target: self, selector: #selector(locationFunctions), userInfo: nil, repeats: true)
            
            print(timer)
            
            
        }
    }
    
    @objc func locationFunctions(){
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locationManager.location else {
                return
            }
            
            if let userIds : NSDictionary = UserDefaults.standard.dictionary(forKey: "loginDetails")! as NSDictionary {
                
                
                print(userIds)
                
                if let userId : String = userIds.value(forKey:"userid") as? String{
                    
                    let params = ["userid": Int(userId)! , "latitude":"\(currentLocation.coordinate.latitude)", "longitude": "\(currentLocation.coordinate.longitude)"] as [String : Any]
                    
                    ApiService.callPost(url: URL.init(string: Endpoints().updateTime)!, params:params as [String : Any],viewcontroller: self, finish: addFriendsApi)
                    
                }
            }
        }
    }
 
    func addFriendsApi(message:String, data:Data?) -> Void
    {
        
        do
        {
            if let jsonData = data
            {
                print(jsonData)
                
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
    
    
    

}

