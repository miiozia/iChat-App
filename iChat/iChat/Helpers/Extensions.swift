//
//  Extensions.swift
//  iChat
//
//  Created by Marta Miozga on 06/10/2024.
//

import Foundation
import UIKit

extension UIImage{
    var isPortrait : Bool {return size.height > size.width}
    var isLandscape : Bool {return size.width > size.height}
    var breath: CGFloat { return min(size.width, size.height)}
    var breathSize: CGSize {return CGSize(width: breath, height: breath)}
    var breathRectangle: CGRect {return CGRect(origin: .zero, size: breathSize)}
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breathSize, false, scale)
        defer{
            UIGraphicsEndImageContext()
        }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2 ) : 0 , y: isPortrait ? floor((size.height - size.width) / 2 ) : 0 ), size: breathSize)) else {
            return nil
        }
        UIBezierPath(ovalIn: breathRectangle).addClip()
        UIImage(cgImage: cgImage).draw(in: breathRectangle)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension Date {
    
    func showDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func showTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: self)
    }
    
    func interval(offComponent comp: Calendar.Component,from date: Date) -> Float{
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else{return 0}
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else{return 0}
        
        return Float(start - end)
    }
    
}



