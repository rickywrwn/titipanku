//
//  KomentarPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 29/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SKActivityIndicatorView

class KomentarPreorder: UIViewController,UITextFieldDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    
    var app: App?
    
    var comments  = [comment]()
    struct comment: Decodable {
        let id: String
        let email: String
        let isi: String
        let tanggal: String
    }
    
    @objc func handleReload(){
        SKActivityIndicator.show("Loading...")
        self.fetchRequests{(comments) -> ()in
            self.comments = comments
            print("count request" + String(self.comments.count))
            self.collectionview.reloadData()
            SKActivityIndicator.dismiss()
        }
    }
    
    var collectionview: UICollectionView!
    func fetchRequests(_ completionHandler: @escaping ([comment]) -> ()) {
        if let idPost = app?.id  {
            let urlString = "http://titipanku.xyz/api/GetDiskusiPreorder.php?idPost=\(String(describing: idPost))"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.comments = try decoder.decode([comment].self, from: data)
                    print(self.comments)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.comments)
                    })
                } catch let err {
                    print(err)
                    
                    self.collectionview.reloadData()
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
        
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
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    @objc func handlePost(){
        if(textField.text == ""){
            let alert = UIAlertController(title: "Peringatan", message: "Komentar Tidak Boleh Kosong", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else{
            
            self.textField.resignFirstResponder()
            SKActivityIndicator.show("Loading...")
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String,let isi = textField.text, let idPost = app?.id {
                print(emailNow)
                
                let parameter: Parameters = ["email": emailNow,"isi": isi,"idPost":idPost, "action" : "insert"]
                print(parameter)
                Alamofire.request("http://titipanku.xyz/api/PostDiskusiPreorder.php",method: .get, parameters: parameter).responseSwiftyJSON { dataResponse in
                    
                    //mencetak JON response
                    if let json = dataResponse.value {
                        
                        //mengambil json
                        print(json)
                        let cekSukses = json["success"].intValue
                        let pesan = json["message"].stringValue
                        
                        if cekSukses != 1 {
                            let alert = UIAlertController(title: "gagal", message: pesan, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(alert, animated: true)
                        }else{
                            let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                SKActivityIndicator.dismiss()
                                self.textField.text = ""
                                self.handleReload()
                            }))
                            
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.hideKeyboardWhenTappedAround()
        
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        self.fetchRequests{(comments) -> ()in
            self.comments = comments
            print("count request" + String(self.comments.count))
            self.collectionview.reloadData()
            SKActivityIndicator.dismiss()
        }
        
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
        navigationItem.title = "Diskusi"
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
        
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionview.register(NotificationCell.self, forCellWithReuseIdentifier: RequestCellId)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        self.view.addSubview(collectionview)
        
        self.collectionview.translatesAutoresizingMaskIntoConstraints = false
        self.collectionview.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: 0).isActive = true
        self.collectionview.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        self.collectionview.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: 0).isActive = true
        self.collectionview.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! NotificationCell
        
        if let id : String = comments[indexPath.row].email {
            Alamofire.request("http://titipanku.xyz/uploads/"+id+".jpg").responseImage { response in
                if let image = response.result.value {
                    cell.imageView.image = image
                }
            }
        }
        cell.labelA.text = comments[indexPath.row].isi
        cell.labelB.text = comments[indexPath.row].tanggal
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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




