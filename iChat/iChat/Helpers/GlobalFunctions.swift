//
//  GlobalFunctions.swift
//  iChat
//
//  Created by Marta Miozga on 05/10/2024.
//

import Foundation
import UIKit
import AVFoundation
func fileNameFrom(fileUrl: String)-> String{
    
    let name = ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
    
    return name
    
}

func timeCalculation(_ date: Date) -> String {
    var elapsed = ""
    let seconds = Date().timeIntervalSince(date)
    if seconds < 60 {
        elapsed = "Just now"
    } else if seconds < 60 * 60 {
        let minutes = Int(seconds / 60)
        let minText = minutes > 1 ? "mins" : "min"
        elapsed = " \(minutes) \(minText)"
        
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60*60))
        let hourText = hours > 1 ? "hours" : "hour"
        elapsed = " \(hours) \(hourText)"
        
    }else {
        elapsed = date.showDate()
    }
    return elapsed
}

func videoThumbNail(video: URL) -> UIImage{
    let asset = AVURLAsset(url: video, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    var image: CGImage?
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }catch let error as NSError{
        print("error making thumbnail", error.localizedDescription)
        
    }
    if image != nil {
        return UIImage(cgImage: image!)
    }
    else {
        return UIImage(named: "photoPlaceholder")!
    }
}
