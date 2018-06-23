//
//  LoginViewController.swift
//  ChatApplication
//
//  Created by Viswa Kodela on 6/10/18.
//  Copyright © 2018 Viswa Kodela. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    var messagesController = MessagesController()
    let containerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
        
    }()
    
    let loginButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
        
    }()
    
    @objc func handleLoginRegister() {
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }else{
            handleRegester()
        }
        
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text else {fatalError("Please enter your Email")}
        guard let password = passwordTextField.text else {fatalError("Please enter a valid Password")}
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error ?? "Email entered is not registered")
            }
            
            self.messagesController.fetchUserAndSetUpNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func handleRegester(){
        
        guard let email = emailTextField.text else{fatalError("No Email entered")}
        guard let password = passwordTextField.text else{fatalError("No password has been entered")}
        guard let name = nameTextField.text else{fatalError("Please enter your name")}
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if error != nil{
                print(error ?? "")
            }
            
            guard let uid = result?.user.uid else{fatalError("No uid for the User")}
            
            let imageID = NSUUID().uuidString
            // successfully authenticated user
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageID).jpeg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
//            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
            
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error ?? "Unknown error")
                    }
                    

                    storageRef.downloadURL(completion: { (url, err) in
                        if error != nil{
                            print(error ?? "")
                        }
                        
                        if let profileUrl = url?.absoluteString{
                            
                            let values = ["name": name, "email": email, "profileImageUrl": profileUrl]
                            self.registerUserIntoDatabasewith(uid: uid, values: values as [String : AnyObject])
                        }
                        
                    })

                })
            }
        }
    }
            
    private func registerUserIntoDatabasewith(uid: String, values: [String : AnyObject]) {
                
                var ref: DatabaseReference!
                ref = Database.database().reference()
                let usersReference = ref.child("users").child(uid)
//                let values = ["name": name, "email": email, "profileIMageUIRL": metedata.downloadUrl()]
                usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        print(error ?? "")
                    }
                    
//                    self.messagesController.fetchUserAndSetUpNavBarTitle()
                    self.messagesController.fetchUserAndSetUpNavBarTitle()
                    self.dismiss(animated: true, completion: nil)
                })
            }
    
    
    let nameTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
        
    }()
    
    let nameSeperator: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let emailTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
        
    }()
    
    let emailSeperator: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let passwordTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        return textField
        
    }()
    
    
    @objc func handleKeyboard() {
        nameTextField.endEditing(true)
        passwordTextField.endEditing(true)
        emailTextField.endEditing(true)
    }
    
    lazy var profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
        
    }()
    
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleLoginRegisterChange(){
        
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        
        loginButton.setTitle(title, for: .normal)
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            profileImageView.isHidden = true
        }else {
            profileImageView.isHidden = false
        }
        
        containerViewHeightAncher?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightAncher?.isActive = false
        nameTextFieldHeightAncher = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAncher?.isActive = true
        
        emailTextFieldHeightAncher?.isActive = false
        emailTextFieldHeightAncher = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAncher?.isActive = true
        
        passwordFieldHeightAncher?.isActive = false
        passwordFieldHeightAncher = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordFieldHeightAncher?.isActive = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(containerView)
        view.addSubview(loginButton)

        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        
        containerViewConstraints()
        registerButtonConstraints()
        imageViewConstraints()
        constraimtsForSegmewntedControl()
        
    }
    
    var containerViewHeightAncher: NSLayoutConstraint?
    var nameTextFieldHeightAncher: NSLayoutConstraint?
    var emailTextFieldHeightAncher: NSLayoutConstraint?
    var passwordFieldHeightAncher: NSLayoutConstraint?
    
    
    func containerViewConstraints(){
    
        //Constraints for containerView
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        containerViewHeightAncher = containerView.heightAnchor.constraint(equalToConstant: 150)
        containerViewHeightAncher?.isActive = true
        
        containerView.addSubview(nameTextField)
        containerView.addSubview(nameSeperator)
        containerView.addSubview(emailTextField)
        containerView.addSubview(emailSeperator)
        containerView.addSubview(passwordTextField)
        
        //Constraints for the TextField
        nameTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameTextFieldHeightAncher = nameTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAncher?.isActive = true
        
        //Constraints for Name Seperator
        nameSeperator.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        nameSeperator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperator.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        nameSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Constraints for the Email textField
        emailTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameSeperator.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        emailTextFieldHeightAncher = emailTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAncher?.isActive = true
        
        //Constraints for Email Seperator
        emailSeperator.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        emailSeperator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperator.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        emailSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Constraints for Password TextField
        passwordTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailSeperator.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        passwordFieldHeightAncher = passwordTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1/3)
        passwordFieldHeightAncher?.isActive = true
    
    }
    
    func registerButtonConstraints() {
        
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    

    
    func imageViewConstraints() {
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    func constraimtsForSegmewntedControl(){
        
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }
    
    @objc func handleProfileImageView() {
        
        print("picker tapped")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
        
        // Protocol for the UIImagePickerControllerDelegate
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            
            var userPickedImage: UIImage?
            
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                userPickedImage = editedImage
            }
            else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                userPickedImage = originalImage
            }
            
            if let selectedImage = userPickedImage{
                profileImageView.image = selectedImage as UIImage
            }
            
            dismiss(animated: true, completion: nil)
        }
    
        
        // Protocol for the UINAvigationControllerDelegate
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b:CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}


