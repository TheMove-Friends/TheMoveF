//
//  MapsViewController.swift
//  TheMove
//
//  Created by User 2 on 3/26/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import GoogleMaps



import PUGifLoading
import EFInternetIndicator

protocol TabbersDelegetes{
    
    func didTap(viewName : String)
    
}

class MapsViewController: UIViewController ,InternetStatusIndicable{
    var internetConnectionIndicator: InternetViewIndicator?
    
    @IBOutlet weak var hotelName: UILabel!
    
    @IBOutlet weak var hotelAddress: UILabel!
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    var hotelNameStr : String?
    
    var addressStr : String?
    
    var delegetes : TabbersDelegetes?
    
   let loading = PUGIFLoading()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startMonitoringInternet()
         self.navigationItem.title =  hotelNameStr
          loading.hide()
        
         loading.show("Please wait....", gifimagename: "foodloader")

         hotelName.text = hotelNameStr

         do {
            
            if let styleURL = Bundle.main.url(forResource: "GoogleStyle", withExtension: "json") {
                
                googleMapsView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                
                
            } else{
                
                NSLog("Unable to find style.json")
                
            }
        } catch {
            
            NSLog("One or more of the map styles failed to load. \(error)")
            
        }
        
        self.loadLocationOnMap()
      
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
        
    }

        
    func loadLocationOnMap() {
            if  let address = addressStr {
                let geocoder = CLGeocoder()
                
                geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                    if((error) != nil){
                        print("Error", error?.localizedDescription as Any)
                    }
                    if let placemark = placemarks?.first {
                        let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                        
                        print("lat", coordinates.latitude)
                        print("long", coordinates.longitude)
                        
                        let location = CLLocationCoordinate2D.init(latitude: coordinates.latitude, longitude: coordinates.longitude)
                        
                        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,longitude: location.longitude,zoom: 15.0)
                        self.googleMapsView.camera = camera
                        self.googleMapsView.animate(to: camera)
                        self.addMarker(location: location, title: self.hotelName.text!)
                    }
                })
            }
}

    func addMarker(location: CLLocationCoordinate2D, title: String) {
        let marker = GMSMarker()
        marker.position = location
        marker.title = title
        marker.appearAnimation = .none
        marker.map = googleMapsView
        
        getAdressName(coords: CLLocation.init(latitude: marker.position.latitude, longitude: marker.position.longitude))
    }
    
    func getAdressName(coords: CLLocation) {
        
        CLGeocoder().reverseGeocodeLocation(coords) { (placemark, error) in
            if error != nil {
                print("Hay un error")
            } else {
                
                let place = placemark! as [CLPlacemark]
                if place.count > 0 {
                    let place = placemark![0]
                    var adressString : String = ""
                    if place.thoroughfare != nil {
                        adressString = adressString + place.thoroughfare! + ", "
                    }
                    if place.subThoroughfare != nil {
                        adressString = adressString + place.subThoroughfare! + "\n"
                    }
                    if place.locality != nil {
                        adressString = adressString + place.locality! + " - "
                    }
                    if place.postalCode != nil {
                        adressString = adressString + place.postalCode! + "\n"
                    }
                    if place.subAdministrativeArea != nil {
                        adressString = adressString + place.subAdministrativeArea! + " - "
                    }
                    if place.country != nil {
                        
                        adressString = adressString + place.country!
                        
                    }
                    
                    self.hotelAddress.text = adressString
                    
                    self.autohide()
                }
            }
        }
    }

    @IBAction func chatBtnAction(_ sender: Any) {

        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController
        
        vc?.hotelName = hotelName.text
        
        self.navigationController?.pushViewController(vc!, animated: true)
      
    }
    
    @IBAction func friendsBtnAction(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SendToFriendListViewController") as? SendToFriendListViewController
        
        if let text = hotelName.text {
            
             vc?.messageStr = "NOW" + " \(text)"
            
        }

        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func autohide()
    {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            
            self.loading.hide()
            
        }
    }
}
