//
//  ViewController.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/10/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        ref.updateChildValues(["someValue": 123123])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(handleLogOut))
        
        if Auth.auth().currentUser == nil {
            handleLogOut()
        }
        
    }
    
    @objc func handleLogOut() {
        
        do {
            try Auth.auth().signOut()
        }catch {
            print("Logout Error")
        }
        
        
        let loginController = LoginViewController()
        
        present(loginController, animated: true, completion: nil)
    }

}

