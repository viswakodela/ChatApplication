//
//  Extensions.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/19/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        // Check cache for image first
        
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
            self.image = cachedImage as? UIImage
        }
        
        // Otherwise fireoff a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error ?? "Invalid URL")
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    //cell.imageView?.image = UIImage(data: data!)
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
                
            }
            }.resume()
    } 
}
