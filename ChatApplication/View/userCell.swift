//
//  userCell.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/23/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase


// We can also do it the other way by using the let cell = UITableViewCell(style: .subtitle, reuseidentifier: cellID)
class userCell: UITableViewCell {
    
    
    var message: Messages? {
        didSet {
            
          setupNameAndAvatar()
            
            detailTextLabel?.text = message?.text
            
            if let time = message?.timeStamp?.doubleValue{
                let timestampDate = Date(timeIntervalSince1970: time)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeStampLabel.text = dateFormatter.string(from: timestampDate)
            }
            
        }
    }
    
    private func setupNameAndAvatar() {
        
        guard let id = message?.chatPartnerId() else {return}
        let ref = Database.database().reference().child("users").child(id)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
                self.textLabel?.text = dictionary["name"] as? String
                if let profileUrl = dictionary["profileImageUrl"]{
                    self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileUrl as! String)
                }
            }
        }
        
    }
    
    let profileImageView: UIImageView = {
        
        let pi = UIImageView()
        pi.contentMode = .scaleAspectFill
        pi.layer.cornerRadius = 24
        pi.layer.masksToBounds = true
        pi.translatesAutoresizingMaskIntoConstraints = false
        return pi
        
    }()
    
    let timeStampLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 70, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 70, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeStampLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeStampLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeStampLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeStampLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeStampLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
