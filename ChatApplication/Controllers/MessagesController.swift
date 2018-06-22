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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //var     ref.updateChildValues(["someValue": 123123])
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleLogOut))
        let image = UIImage(named: "Icon-Small")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLoggedIn()
        }
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        } else {
           fetchUserAndSetUpNavBarTitle()
        }
    }
    
    func fetchUserAndSetUpNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else{fatalError("No user found")}
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
        
        
        
        let titleView = UIView()
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
            profileImageView.loadImageUsingCacheWithUrlString(profileUrl)
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
 
        
    }
    
    @objc func handleLogOut() {
        
        do {
            try Auth.auth().signOut()
//            navigationItem.title = nil
        }catch {
            print("Logout Error")
        }
        let loginController = LoginViewController()
        //MARK:- Doubts here
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageTableViewController()
        let navBar = UINavigationController(rootViewController: newMessageController)
        newMessageController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButton))
        present(navBar, animated: true, completion: nil)
        
    }
    
    @objc func cancelBarButton() {
    
        dismiss(animated: true, completion: nil)
    }
    

}

