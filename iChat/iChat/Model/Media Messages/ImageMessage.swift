//
//  ImageMessage.swift
//  iChat
//
//  Created by Marta Miozga on 06/11/2024.
//

import Foundation
import MessageKit

class ImageMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path: String){
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
        
    }
    
}
