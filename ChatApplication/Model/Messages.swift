//
//  Messages.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/23/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase

class Messages: NSObject {

    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    
    var imageUrl: String?
    
    func chatPartnerId() -> String {
        var chatPartnerId: String?
        
//        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
        
        if fromId == Auth.auth().currentUser?.uid {
            chatPartnerId = toId
        }else {
            chatPartnerId = fromId
        }
        return chatPartnerId!
    }
    
}
