//
//  ChatController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 29/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SKActivityIndicatorView
import Firebase
import FirebaseDatabase

class ChatController: UIViewController,UITextFieldDelegate{
    fileprivate let RequestCellId = "RequestCellId"
    
    var chat : chatroom?
    let postButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor.blue
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePost), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    let textField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    func observeMessages(){
        if let chatId = chat?.id {
            let ref = Database.database().reference().child("messages").child(chatId)
            ref.observe(.childAdded, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                print(value)
                let email = value?["email"] as? String ?? ""
                print(email)
                // ...
            }, withCancel: nil)
            
        }
    }
    
    @objc func handlePost(){
        if(textField.text == ""){
            let alert = UIAlertController(title: "Peringatan", message: "Komentar Tidak Boleh Kosong", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else{
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                self.textField.resignFirstResponder()
                let ref = Database.database().reference().child("messages").child((chat?.id)!)
                let childRef = ref.childByAutoId()
                let value = ["text": textField.text!,"email":emailNow]
                childRef.updateChildValues(value)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.hideKeyboardWhenTappedAround()
        
        observeMessages()
        setupView()
    }
    
    private func setupView(){
        //supaya navbar full
        // Create the navigation bar
        let screenSize: CGRect = UIScreen.main.bounds
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 0))
        navbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navbar)
        navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        navbar.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        // Offset by 20 pixels vertically to take the status bar into account
        navbar.backgroundColor = UIColor(hex: "#3867d6")
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Chat"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        //collectionView?.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - 64))
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        view.addSubview(textField)
        textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.font = UIFont.systemFont(ofSize: 25)
        textField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        textField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -70).isActive = true
        
        textField.delegate = self
        
        //PostButton
        view.addSubview(postButton)
        postButton.topAnchor.constraint(greaterThanOrEqualTo: textField.topAnchor, constant: 0).isActive = true
        postButton.leftAnchor.constraint(greaterThanOrEqualTo: textField.rightAnchor, constant: 0).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    var offsetY:CGFloat = 0
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -215, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -215, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}


