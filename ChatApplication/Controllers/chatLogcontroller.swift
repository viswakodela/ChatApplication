//
//  chatLogcontroller.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/22/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

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
                
//                print(snapshot)
                guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
                
                let message = Messages()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.toId = dictionary["toId"] as? String
                message.imageUrl = dictionary["imageUrl"] as? String
                message.imageHeight = dictionary["imageHeight"] as? NSNumber
                message.imageWidth = dictionary["imageWidth"] as? NSNumber
                message.videoUrl = dictionary["videoUrl"] as? String
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    
                    self.collectionView?.reloadData()
                    
                    let indexpath = NSIndexPath(item: self.messages.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexpath as IndexPath, at: .bottom, animated: true)
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
        
        cell.message = message
        
        // Delegating
        cell.chatControllerDelegate = self
        
        setUpCell(cell: cell, message: message)
        
        // Adjusting the buubles View's Width
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.textView.isHidden = true
        }
        
        if message.videoUrl != nil {
            cell.playButton.isHidden = false
        }
        else{
            cell.playButton.isHidden = true
        }
        
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
        
        let message = messages[indexPath.row]
        // Adjusting the bubble view's height
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // In Geometry, if two Rectangles are of same Height and Width
            // Then h1 / w1 = h2 / w2
            // Solution==>  h1 = h2 / w1 * w2
            height = CGFloat(imageHeight / imageWidth * 250)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 250, height: 1000)
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
    
    override var inputAccessoryView: UIView?{
        get{
            return containertView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    @objc func handleUploadButton() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // We selected a Video
            handleVideoUpload(videoUrl: videoUrl)
        }
        else {
             // We selected an Image
            handleImageUpload(info: info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    private func handleVideoUpload(videoUrl: NSURL) {
        
        let videoId = NSUUID().uuidString
        let storage = Storage.storage().reference().child("message_videos").child(videoId)
        storage.putFile(from: videoUrl as URL, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error ?? "")
            }
            storage.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error ?? "")
                }
                
                guard let thumbNailImage = self.thumbNailImageForVideoUrl(fileUrl: videoUrl) else{return}
                
                let imageId = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("thumbnailo-images").child(imageId)
                
                guard let thumbnailUploadData = UIImageJPEGRepresentation(thumbNailImage, 0.2) else{return}
                storageRef.putData(thumbnailUploadData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        print(error ?? "Unable to upload the Image to your Firebase Storage")
                    }
                    
                    storageRef.downloadURL(completion: { (urle, error) in
                        if error != nil {
                            print(error ?? "")
                        }
                        if let thumbNailimageUrl = urle?.absoluteString{
                            if let videoUrl = url?.absoluteString{
                                self.sendMessageWithImageUrl(imageUrl: thumbNailimageUrl, image: thumbNailImage, videoUrl: videoUrl)
                            }
                        }
                    })
                }
            })
        }
    }
    
    private func thumbNailImageForVideoUrl(fileUrl: NSURL) -> UIImage? {
        
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do{
            let thumbNailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbNailCGImage)
        }catch{
            print(error)
        }
        return nil
    }
    
    private func handleImageUpload(info: [String : Any]){
        
        var userPickedImage: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            userPickedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userPickedImage = originalImage
        }
        
        if let selectedImage = userPickedImage{
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
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
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image, videoUrl: nil)
//                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image, videoUrl: nil)
                }
            })
        }
    }
    
    func sendMessageWithImageUrl(imageUrl: String?, image: UIImage, videoUrl: String?){
        
        let ref = Database.database().reference().child("messages")
        let chinldRef = ref.childByAutoId()
        guard let toId = user?.id else {return}
        guard let fromId = Auth.auth().currentUser?.uid else{fatalError("No user Logged in")}
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        if let urlForImage = imageUrl {
            
            let values = ["toId": toId, "fromId": fromId, "timeStamp": timeStamp, "imageUrl" : urlForImage, "imageHeight": image.size.height, "imageWidth": image.size.width, "videoUrl": videoUrl as Any] as [String : AnyObject]

            
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
            
            // This is to make the messageTextField gets nil when ever the user hits the send button
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
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImagView: UIImageView?
    
    func performZoomInForStartingImageView(startingImagView: UIImageView){
        
        self.startingImagView = startingImagView
        self.startingImagView?.isHidden = true
        
        startingFrame = startingImagView.superview?.convert(startingImagView.frame, to: nil)
        
//        print(startingFrame)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImagView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageZoomOut(tapGesture:))))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0

            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.containertView.alpha = 0
                
                //math
                // h2 / w1 = h1 / w1
                // h2  = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    @objc func handleImageZoomOut(tapGesture: UITapGestureRecognizer){
    
        if let zoomOutImageView = tapGesture.view{
            
            UIView.animate(withDuration: 0.2, animations: {
                
                zoomOutImageView.layer.cornerRadius = 16
                zoomOutImageView.clipsToBounds = true
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.containertView.alpha = 1
            }) { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImagView?.isHidden = false
            }   
        }
    }
}
