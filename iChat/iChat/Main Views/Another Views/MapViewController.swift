//
//  MapViewController.swift
//  iChat
//
//  Created by Marta Miozga on 09/11/2024.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    
    //MARK: - Vars
    var location: CLLocation?
    var mapView: MKMapView!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle()
        configureMapView()
        confgureMapButton()
        
    }
    
    //MARK: - configuration
    
    private func configureMapView(){
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        if location != nil{
            mapView.setCenter(location!.coordinate, animated: false)
            mapView.addAnnotation(MapAnnotation(title: nil, coordinate: location!.coordinate))
        }
        view.addSubview(mapView)
    }
    
    private func confgureMapButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))
    }
    
    private func configureTitle(){
        self.title = "Map View"
    }

    //MARK: - actions
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
}
