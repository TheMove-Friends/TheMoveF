//
//  OfflineViewController.swift
//  TheMove
//
//  Created by User 2 on 3/20/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import EFInternetIndicator

class OfflineViewController: UIViewController ,InternetStatusIndicable{
    var internetConnectionIndicator: InternetViewIndicator?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startMonitoringInternet()

    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }

    @IBAction func cancelBtnAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    @IBAction func connectToInternetBtnAction(_ sender: Any) {
        
       openAppSpecificSettings()
    }
    
     func openAppSpecificSettings() {
        
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                return
        }
    }
    
}
