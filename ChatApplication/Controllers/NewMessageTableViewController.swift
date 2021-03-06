//
//  NewMessageTableViewController.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/16/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {
    
    let cellID = "cellID"
    var users = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(userCell.self, forCellReuseIdentifier: cellID)
        tableView.rowHeight = 72
        fetchUser()
    }
    
    func fetchUser() {
        
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let user = Users()
                user.id = snapshot.key
                user.email = dictionary["email"] as? String
                user.name = dictionary["name"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.users.append(user)
                // This will crash because it is bcakground thread, So lets call Dispatch queue async to fix
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! userCell
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        
        if let profileImageUrl = users[indexPath.row].profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
        
    }
    
    weak var messageController: MessagesController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true) {
            
             let usr = self.users[indexPath.row]
            self.messageController?.showChatController(user: usr)
        }
    }
}


