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
import Hue

class ChatController: UIViewController,UITextFieldDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    
    var collectionChat: UICollectionView!
    var arrText = [String]()
    var arrEmail = [String]()
    var chat : chatroom?
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! ChatCell
        
        if let id : String = arrEmail[indexPath.row],let text : String = arrText[indexPath.row],let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String{
            cell.labelKiri.text = text
            cell.LabelKanan.text = text
            cell.LabelKanan.isHidden = false
            cell.labelKiri.isHidden = false
            
            if id == emailNow{
                cell.labelKiri.isHidden = true
            }else{
                cell.LabelKanan.isHidden = true
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrEmail.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 50)
    }
    
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
        textField.textAlignment = .left
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
                let text = value?["text"] as? String ?? ""
                self.arrEmail.append(email)
                self.arrText.append(text)
                print(self.arrEmail)
                print(self.arrText)
                self.collectionChat.reloadData()
                //self.scrollToBottom()
                
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
            
            textField.text = ""
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
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: 700)
        
        collectionChat = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionChat.register(ChatCell.self, forCellWithReuseIdentifier: RequestCellId)
        collectionChat.dataSource = self
        collectionChat.delegate = self
        collectionChat.showsVerticalScrollIndicator = false
        collectionChat.backgroundColor = UIColor.white
        self.view.addSubview(collectionChat)
        
        self.collectionChat.translatesAutoresizingMaskIntoConstraints = false
        self.collectionChat.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: 0).isActive = true
        self.collectionChat.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        self.collectionChat.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: 0).isActive = true
        self.collectionChat.heightAnchor.constraint(equalToConstant: 600).isActive = true
        
        view.addSubview(textField)
        textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 300).isActive = true
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
    
    func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(
            x: 0,
            y: self.collectionChat.contentSize.height
                - self.collectionChat.bounds.size.height
                + self.collectionChat.contentInset.bottom)
        self.collectionChat.setContentOffset(bottomOffset, animated: animated)
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    var offsetY:CGFloat = 0
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -225, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -225, up: false)
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

class ChatCell: BaseCell {
    
    let labelKiri : UILabelPadding = {
        let label = UILabelPadding()
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        label.numberOfLines = 5
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIColor.gray.cgColor
        return label
    }()
    
    let LabelKanan : UILabelPadding = {
        let label = UILabelPadding()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 5
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIColor(hex: "#3867d6").cgColor

        return label
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelKiri)
        addSubview(LabelKanan)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-5-[v0(170)][v1(170)]-10-|", views: labelKiri,LabelKanan) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|-5-[v0]", views: labelKiri)
        addConstraintsWithFormat("V:|-5-[v0]", views: LabelKanan)
        
    }
    
}

class UILabelPadding: UILabel {
    
    let padding = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
    
    
}




