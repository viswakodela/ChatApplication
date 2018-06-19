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

//        ref.updateChildValues(["someValue": 123123])
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleLogOut))
        let image = UIImage(named: "Icon-Small")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLoggedIn()
        }
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject]{
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
            }, withCancel: nil)
        }
    }
    
    
    @objc func handleLogOut() {
        
        do {
            try Auth.auth().signOut()
//            navigationItem.title = nil
        }catch {
            print("Logout Error")
        }
        let loginController = LoginViewController()
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

