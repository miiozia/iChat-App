//
//  MapAnnotation.swift
//  iChat
//
//  Created by Marta Miozga on 09/11/2024.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation{
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.coordinate = coordinate
    }
}
