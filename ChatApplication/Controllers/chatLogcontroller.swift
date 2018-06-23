//
//  chatLogcontroller.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/22/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase

class chatLogController: UICollectionViewController, UITextFieldDelegate {
    
    lazy var messageTextField: UITextField = {
        
        let texField = UITextField()
        texField.placeholder = "Eneter Message..."
        texField.delegate = self
        texField.translatesAutoresizingMaskIntoConstraints = false
        return texField
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "Chat Log Controller"
        collectionView?.backgroundColor = UIColor.white
        
        
        
        setUpInputsComponents()
    }
    
    
    func setUpInputsComponents() {

        let containerView = UIView()
//        containerView.backgroundColor = UIColor.red
        containerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)

        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.tintColor = UIColor.blue
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        

        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true


        containerView.addSubview(messageTextField)
        

        
        messageTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
//        messageTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperaterLineView = UIView()
        seperaterLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperaterLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperaterLineView)
        
        seperaterLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperaterLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperaterLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperaterLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
       
    }
    
    @objc func handleSend() {
        
//        print(messageTextField.text)
//        let ref: DatabaseReference!
        let ref = Database.database().reference().child("messages")
        let chinldRef = ref.childByAutoId()
        
        let values = ["text" : messageTextField.text!, "name" : ""]
        chinldRef.updateChildValues(values)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
