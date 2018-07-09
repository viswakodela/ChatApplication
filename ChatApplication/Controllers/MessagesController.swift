//
//  ViewController.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/10/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    

    let cellid = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.register(userCell.self, forCellReuseIdentifier: cellid)
        //var     ref.updateChildValues(["someValue": 123123])
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleLogOut))
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLoggedIn()
        
        
        
//        observeMessages()
        
        
        tableView.rowHeight = 72
        }
    
    
    
    var messages = [Messages]()
    var messageDictionary = [String : Messages]()
    
    
    private func observeUserMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref =  Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
//            print(snapshot)
            
            let userId = snapshot.key
            let messageRef = Database.database().reference().child("user-messages").child(uid).child(userId)
            messageRef.observe(.childAdded, with: { (snap) in
                
                let messageId = snap.key
                let messageReference = Database.database().reference().child("messages").child(messageId)
                
                messageReference.observe(.value, with: { (snapshot) in
                    
                    //                print(snapshot)
                    if let dictionary = snapshot.value as? [String : AnyObject]{
                        let message = Messages()
                        message.toId = dictionary["toId"] as? String
                        message.text = dictionary["text"] as? String
                        message.timeStamp = dictionary["timeStamp"] as? NSNumber
                        message.fromId = dictionary["fromId"] as? String
                        //                self.messages.append(message)
                        //                print(message.text)
                        
                        let chatPartnerId = message.chatPartnerId()
                        //MARK:- Lots of doubts
                        self.messageDictionary[chatPartnerId] = message
                        self.messages = Array(self.messageDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                        })
                    }
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    
                    
                }, withCancel: nil)
            }, withCancel: nil)
            return
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
//        print("reload Table")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func observeMessages(){
        
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject]{
                let message = Messages()
                message.toId = dictionary["toId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.fromId = dictionary["fromId"] as? String
//                self.messages.append(message)
//                print(message.text)
                
                if let toId = message.toId{
                    //MARK:- Lots of doubts
                    self.messageDictionary[toId] = message
                    self.messages = Array(self.messageDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid , for: indexPath) as! userCell
        
        let message = messages[indexPath.row]
     
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
//        print(message.text, message.toId, message.fromId)

        let chatPartnerId = message.chatPartnerId()
        
        let ref =  Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observe(.value, with: { (snap) in
            guard let dictionary = snap.value as? [String : AnyObject] else{return}
            let user = Users()
            user.id = chatPartnerId
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
            self.showChatController(user: user)
        }, withCancel: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        } else {
           fetchUserAndSetUpNavBarTitle()
        }
    }
    
    func fetchUserAndSetUpNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else{return}
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject]{
//                self.navigationItem.title = dictionary["name"] as? String
                
                let users = Users()
                users.name = dictionary["name"] as? String
                users.email = dictionary["email"] as? String
                users.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.setUpNavBarWithUser(user: users)
            }
            
            
        }, withCancel: nil)
    }
    
    func setUpNavBarWithUser(user: Users) {
        
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
//        titleView.backgroundColor =  UIColor.gray
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        titleView.backgroundColor = UIColor.red
        self.navigationItem.titleView = titleView
        
        
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.blue
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        if let profileUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileUrl)
        }
        
        titleView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel  = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(nameLabel)

        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
 
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    
    @objc func showChatController(user: Users) {
        
        
        let chatController = chatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
//        present(chatController, animated: true, completion: nil)
        self.navigationController?.pushViewController(chatController, animated: true)
        
    }
    
    @objc func handleLogOut() {
        
        do {
            try Auth.auth().signOut()
//            navigationItem.title = nil
        }catch {
            print("Logout Error")
        }
        let loginController = LoginViewController()
        //MARK:- This is nothing but delegating the messageController, We actually did this in the other way by naming it as var delegate: MessagesController? and call here as loginController.delegate = self
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageTableViewController()
        // MARK:- This is nothing but delegating the messageController, We actually did this in the other way by naming it as var delegate: MessagesController? and call here as newMessageController.delegate = self
        newMessageController.messageController = self
        let navBar = UINavigationController(rootViewController: newMessageController)
        newMessageController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButton))
        present(navBar, animated: true, completion: nil)
        
    }
    
    @objc func cancelBarButton() {
    
        dismiss(animated: true, completion: nil)
    }
    

}

