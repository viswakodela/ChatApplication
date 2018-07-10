//
//  chatLogcontroller.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/22/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase

class chatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: Users? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    } 
    
    
    var messages = [Messages]()
    
    func observeMessages() {

        guard let id = Auth.auth().currentUser?.uid else {return}
        
        guard let toId = user?.id else{return}
        
        let userMessageRef = Database.database().reference().child("user-messages").child(id).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
//            print(snapshot)
            let messageId = snapshot.key
            let ref = Database.database().reference().child("messages").child(messageId)
            ref.observe(.value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
                
                let message = Messages()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.toId = dictionary["toId"] as? String
                message.imageUrl = dictionary["imageUrl"] as? String
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }

//                Check Episode 16 if any doubts
//                if message.chatPartnerId() == self.user?.id{
//                    self.messages.append(message)
//
//                    DispatchQueue.main.async {
//                        self.collectionView?.reloadData()
//                    }
//                }
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    lazy var messageTextField: UITextField = {
        
        let texField = UITextField()
        texField.placeholder = "Enter Message..."
        texField.delegate = self
        
        texField.translatesAutoresizingMaskIntoConstraints = false
        return texField
    }()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
        
        collectionView?.addGestureRecognizer(tapGesture)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
//        setUpInputsComponents()
    }
    

    @objc func handleGesture() {
        messageTextField.endEditing(true)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    let cellId = "cellId"
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        

        // Adjusting the buubles View's Width
        if let text = message.text{
           cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
        }
        
        setUpCell(cell: cell, message: message)
        
        return cell
         
    }
    
    private func setUpCell(cell: ChatMessageCell, message: Messages){
        
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else{
            cell.messageImageView.isHidden = true
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            // blue Bubble
            cell.bubbleView.backgroundColor = UIColor(r: 0, g: 137, b: 249)
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }else{
            //white Bubble
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
           
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        // Adjusting the bubble view's height
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
    
    lazy var containertView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = #imageLiteral(resourceName: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadButton)))
        containerView.addSubview(uploadImageView)
        
        
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
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
        
        
        
        messageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
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
        
        
        return containerView
    }()
    
    @objc func handleUploadButton() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var userPickedImage: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            userPickedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userPickedImage = originalImage
        }
        
        if let selectedImage = userPickedImage{
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirebaseStorageUsingImage(image: UIImage){
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message-images").child(imageName)
        guard let uploadData = UIImageJPEGRepresentation(image, 0.2) else{return}
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error ?? "Unable to upload the Image to your Firebase Storage")
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error ?? "")
                }
                if let imageUrl = url?.absoluteString{
                    self.sendMessageWithImageUrl(imageUrl: imageUrl)
                }
            })
        }
    }
    
    func sendMessageWithImageUrl(imageUrl: String){
        let ref = Database.database().reference().child("messages")
        let chinldRef = ref.childByAutoId()
        guard let toId = user?.id else {return}
        guard let fromId = Auth.auth().currentUser?.uid else{fatalError("No user Logged in")}
        let timeStamp = Int(Date().timeIntervalSince1970)
        let values = ["imageUrl" : imageUrl, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String : AnyObject]
        //        chinldRef.updateChildValues(values)
        
        chinldRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error ?? "")
            }
            
            // This is to make the messageTextField gets nil when evr the user hits the send button
            self.messageTextField.text = nil
            
            let messageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = chinldRef.key
            messageRef.updateChildValues([messageId : 1])
            
            let recepientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            
            recepientUserMessageRef.updateChildValues([messageId : 1])
            
        }
    }
    
    override var inputAccessoryView: UIView?{
        get {
            return containertView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
//    func setUpInputsComponents() {
//
//        let containerView = UIView()
//        containerView.backgroundColor = UIColor.white
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(containerView)
//
//        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//
//        let sendButton = UIButton(type: .system)
//        sendButton.setTitle("Send", for: .normal)
//        sendButton.tintColor = UIColor.blue
//        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(sendButton)
//
//
//
//        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//
//
//        containerView.addSubview(messageTextField)
//
//
//
//        messageTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
//        messageTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
////        messageTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        messageTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//
//        let seperaterLineView = UIView()
//        seperaterLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
//        seperaterLineView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(seperaterLineView)
//
//        seperaterLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        seperaterLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//        seperaterLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
//        seperaterLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
//
//    }
    
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
            
            // This is to make the messageTextField gets nil when evr the user hits the send button
            self.messageTextField.text = nil
            
            let messageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = chinldRef.key
            messageRef.updateChildValues([messageId : 1])
            
            let recepientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            
            recepientUserMessageRef.updateChildValues([messageId : 1])
            
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
