//
//  LocationManager.swift
//  iChat
//
//  Created by Marta Miozga on 08/11/2024.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate{
    
static let shared = LocationManager()
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    
    private override init(){
       super.init()
    requestLocationAccess()
    }
    
    func requestLocationAccess(){
        
        if locationManager == nil{
            print("auth location manager")
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
           
        }else {
            print("we have location manager")
        }
    }
    
    func startLocatizationUpdating(){
        locationManager!.startUpdatingLocation()
    }
    
    func stopLocalizationUpdating(){
        if locationManager != nil{
            locationManager?.stopUpdatingLocation()
        }
    }
    
    //MARK: - delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined{
            self.locationManager!.requestWhenInUseAuthorization()
        }
    }
}

