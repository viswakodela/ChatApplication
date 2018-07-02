//
//  chatLogcontroller.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/22/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase

class chatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user: Users? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    } 
    
    
    var messages = [Messages]()
    
    func observeMessages() {

        guard let id = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(id)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let ref = Database.database().reference().child("messages").child(messageId)
            ref.observe(.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
                
                let message = Messages()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.toId = dictionary["toId"] as? String
                
                if message.chatPartnerId() == self.user?.id{
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                } 
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    lazy var messageTextField: UITextField = {
        
        let texField = UITextField()
        texField.placeholder = "Eneter Message..."
        texField.delegate = self
        texField.translatesAutoresizingMaskIntoConstraints = false
        return texField
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setUpInputsComponents()
    }
    

    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    let cellId = "cellId"
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        

        // Modify the buubles View's Width
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
//        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    
    
    func setUpInputsComponents() {

        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
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
        guard let toId = user?.id else {return}
        guard let fromId = Auth.auth().currentUser?.uid else{fatalError("No user Logged in")}
        let timeStamp = Int(Date().timeIntervalSince1970)
        let values = ["text" : messageTextField.text!, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String : AnyObject]
//        chinldRef.updateChildValues(values)
        
        chinldRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error ?? "")
            }
            
            let messageRef = Database.database().reference().child("user-messages").child(fromId)
            
            let messageId = chinldRef.key
            messageRef.updateChildValues([messageId : 1])
            
            let recepientUserMessageRef = Database.database().reference().child("user-messages").child(toId)
            
            recepientUserMessageRef.updateChildValues([messageId : 1])
            
        }
        
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
