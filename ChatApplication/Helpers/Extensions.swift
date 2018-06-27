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
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        if let profileurl = url {
            URLSession.shared.dataTask(with: profileurl, completionHandler: { (data, response, error) in
                
                //download hit an error so lets return out
                if error != nil {
                    print(error ?? "")
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        
                        self.image = downloadedImage
                    }
                })
                
            }).resume()
        }
        
    }
    
}

//extension UIImageView {
//
//    func loadImageUsingCacheWithUrlString(urlString: String) {
//
//        self.image = nil
//
//        // Check cache for image first
//
//        if let cachedImage = imageCache.object(forKey: urlString as AnyObject){
//
//            // self is refering to the ProfileImageView of the userCell or what ever the imageView we are using
//            self.image = cachedImage as? UIImage
//        }
//
//        // Otherwise fire off a new download
//        if let url = URL(string: urlString) {
//
//            URLSession.shared.dataTask(with: url) { (data, response, error) in
//                if error != nil{
//                    print(error ?? "Invalid URL")
//                }
//
//                DispatchQueue.main.async(execute:  {
//                    if let data = data {
//                        if let downloadedImage = UIImage(data: data){
//                            //cell.imageView?.image = UIImage(data: data!)
//                            imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
//                            self.image = downloadedImage
//                        }
//                    }
//                })
//                }.resume()
//        }
//
//    }
//}
