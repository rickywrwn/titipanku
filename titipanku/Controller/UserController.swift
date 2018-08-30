//
//  UserController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 16/04/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import SKActivityIndicatorView

class UserController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var chats  = [chatroom]()
    var cekLogged : Bool = UserDefaults.standard.bool(forKey: "logged")
    struct userDetail: Decodable {
        let name: String
        let email: String
        let tanggalDaftar: String
        
    }
    var isiUser  : userDetail?
    struct emailUser {
        static var email = ""
        static var status = ""
    }
    func fetchChatroom(_ completionHandler: @escaping ([chatroom]) -> ()) {
        if let emailA = UserDefaults.standard.value(forKey: "loggedEmail") as? String ,let emailB : String = emailUser.email{
            let urlString = "http://titipanku.xyz/api/GetChatUser.php?emailA=\(String(describing: emailA))&emailB=\(String(describing: emailB))"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.chats = try decoder.decode([chatroom].self, from: data)
                    print(self.chats)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.chats)
                    })
                } catch let err {
                    print(err)
                    
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
        
    }
    fileprivate func fetchJSON() {
        if let emailNow : String = emailUser.email {
            print(emailNow)
            let urlString = "http://titipanku.xyz/api/DetailUser.php?email=\(String(describing: emailNow))"
            guard let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { (data, _, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        print("Failed to get data from url:", err)
                        return
                    }
                    
                    guard let data = data else { return }
                    print(data)
                    do {
                        // link in description for video on JSONDecoder
                        let decoder = JSONDecoder()
                        // Swift 4.1
                        self.isiUser = try decoder.decode(userDetail.self, from: data)
                        print(self.isiUser)
                        
                        self.userCollectionView.reloadData()
                        SKActivityIndicator.dismiss()
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                        SKActivityIndicator.dismiss()
                    }
                }
                }.resume()
        }
    }
    
    fileprivate let userCellId = "userCellId"
    fileprivate let cellId = "cellId"
    fileprivate let activityCellId = "activityCellId"
    
    var userCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor.white
        return cv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let status : String = emailUser.status{
            if status == "sendiri"{
                emailUser.email = emailNow
            }
        }
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        self.title = "User"
        print("User Loaded")
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        fetchJSON()
        
        view.addSubview(userCollectionView)
        userCollectionView.alwaysBounceVertical = true
        userCollectionView.delegate = self
        userCollectionView.dataSource = self
        userCollectionView.backgroundColor = UIColor.white
        userCollectionView.register(UserDetailCell.self, forCellWithReuseIdentifier: userCellId)
        userCollectionView.register(UserActivityCell.self, forCellWithReuseIdentifier: activityCellId)
        
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
        navigationItem.title = "Profile"
        if emailUser.status != "sendiri"{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chat", style: .done, target: self, action: #selector(handleChat))
            self.fetchChatroom{(chats) -> ()in
                self.chats = chats
                SKActivityIndicator.dismiss()
            }
        }
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        userCollectionView.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: 5).isActive = true
        userCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        userCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        userCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    @objc func handleChat(){
        if self.chats.count > 0{
            if let idChatroom : String = self.chats[0].id {
                
                let parameters: Parameters = ["idChatroom": idChatroom]
                print(parameters)
                Alamofire.request("http://titipanku.xyz/api/SetChatUser.php",method: .get, parameters: parameters).responseJSON {
                    response in
                    
                    //mencetak JSON response
                    if let json = response.result.value {
                        print("JSON: \(json)")
                    }
                    
                    //mengambil json
                    let json = JSON(response.result.value)
                    print(json)
                    let cekSukses = json["success"].intValue
                    
                    if cekSukses != 1 {
                        let alert = UIAlertController(title: "Message", message: "gagal", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                    }else{
                        if let chat : chatroom = self.chats[0] {
                            let layout = UICollectionViewFlowLayout()
                            layout.minimumInteritemSpacing = 0
                            layout.minimumLineSpacing = 0
                            let addDetail = ChatController()
                            addDetail.chat = chat
                            let transition = CATransition()
                            transition.duration = 0.3
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromRight
                            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            self.present(addDetail, animated: false, completion: nil)
                        }else{
                            print("no app")
                        }
                    }
                }
            }
        }else{
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                print(emailNow)
                let parameters: Parameters = ["emailA": emailNow,"emailB": emailUser.email ,"action" : "insert"]
                print(parameters)
                Alamofire.request("http://titipanku.xyz/api/PostChat.php",method: .get, parameters: parameters).responseJSON {
                    response in
                    
                    //mencetak JSON response
                    if let json = response.result.value {
                        print("JSON: \(json)")
                    }
                    
                    //mengambil json
                    let json = JSON(response.result.value)
                    print(json)
                    let cekSukses = json["success"].intValue
                    
                    if cekSukses != 1 {
                        let alert = UIAlertController(title: "Message", message: "gagal", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                    }else{
                        self.fetchChatroom{(chats) -> ()in
                            self.chats = chats
                            if let chat : chatroom = self.chats[0] {
                                let layout = UICollectionViewFlowLayout()
                                layout.minimumInteritemSpacing = 0
                                layout.minimumLineSpacing = 0
                                let addDetail = ChatController()
                                addDetail.chat = chat
                                let transition = CATransition()
                                transition.duration = 0.3
                                transition.type = kCATransitionPush
                                transition.subtype = kCATransitionFromRight
                                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                                self.view.window!.layer.add(transition, forKey: kCATransition)
                                self.present(addDetail, animated: false, completion: nil)
                            }else{
                                print("no app")
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    //logout
    @objc func handleLogout(){
        UserDefaults.standard.set(false, forKey:"logged")
        UserDefaults.standard.synchronize()
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 0
        let loginCont = loginController()
        present(loginCont, animated: true, completion: {
            
        })
    }
    
    @objc func handleTrip(){
        let layout = UICollectionViewFlowLayout()
        let tripListCont = UserTripList(collectionViewLayout: layout)
        present(tripListCont, animated: true, completion: {
        })
        
    }
    
    @objc func handleReview(){
        let layout = UICollectionViewFlowLayout()
        let tripListCont = UserReview(collectionViewLayout: layout)
        present(tripListCont, animated: true, completion: {
        })
        
    }
    
    @objc func handlePembelian(){
        let tripListCont = UserPembelian()
        present(tripListCont, animated: true, completion: {
        })
        
    }
    
    @objc func handlePenjualan(){
        let tripListCont = UserPenjualan()
        present(tripListCont, animated: true, completion: {
        })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! UserDetailCell
           
            cell.labelEmail.text = isiUser?.email
            cell.LabelNama.text = isiUser?.name
            cell.LabelTanggal.text = isiUser?.tanggalDaftar
            if emailUser.status == "sendiri" {
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                Alamofire.request("http://titipanku.xyz/uploads/"+emailNow+".jpg").responseImage { response in
                    if let image = response.result.value {
                        cell.imageView.image = image
                        self.userCollectionView.reloadData()
                    }
                }
            }
            }else{
                if let emailNow : String = emailUser.email {
                    Alamofire.request("http://titipanku.xyz/uploads/"+emailNow+".jpg").responseImage { response in
                        if let image = response.result.value {
                            cell.imageView.image = image
                            self.userCollectionView.reloadData()
                        }
                    }
                }
            }
            
            return cell
        }else if indexPath.item == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! UserActivityCell
            cell.labelNama.text = "Review"
            
            return cell
        }else if indexPath.item == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! UserActivityCell
            cell.labelNama.text = "Postinganku"
            
            return cell
        }else if indexPath.item == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! UserActivityCell
            cell.labelNama.text = "Penawaranku"
            
            return cell
        }else if indexPath.item == 4{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! UserActivityCell
            cell.labelNama.text = "Trip"
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! UserDetailCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row == 0{
            
            return CGSize(width: view.frame.width, height: 170)
        }
        return CGSize(width: view.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.gray.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cell?.layer.backgroundColor = UIColor.white.cgColor
            if indexPath.row == 1{
                self.handleReview()
            }else if indexPath.row == 2{
                self.handlePembelian()
            }else if indexPath.row == 3{
                self.handlePenjualan()
            }else if indexPath.row == 4{
                self.handleTrip()
            }
        }
    }
}

class UserDetailCell: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Email : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Nama : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let labelC : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Bergabung Sejak : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.backgroundColor = UIColor.green
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let labelEmail : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        return label
    }()
    
    let LabelNama : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let LabelTanggal : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        addSubview(labelB)
        addSubview(labelC)
        addSubview(imageView)
        addSubview(labelEmail)
        addSubview(LabelNama)
        addSubview(LabelTanggal)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-5-[v2(100)]-20-[v1]-1-[v0]", views: labelEmail,labelA,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-5-[v2(100)]-20-[v0]-1-[v1]", views: labelB,LabelNama,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-5-[v2(100)]-20-[v0]-1-[v1]", views: labelC,LabelTanggal,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-25-[v0(100)]", views: imageView)
        addConstraintsWithFormat("V:|-30-[v0]-5-[v1]-5-[v2]", views: labelA,labelB,labelC)
        addConstraintsWithFormat("V:|-30-[v0]-5-[v1]-5-[v2]", views: labelEmail,LabelNama,LabelTanggal )
        addConstraintsWithFormat("V:|-155-[v0(1)]", views:dividerLineView )
        
    }
    
}


class UserActivityCell: BaseCell {
    
    let labelNama : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "next")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelNama)
        addSubview(imageView)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-10-[v0]-4-[v1(30)]-15-|", views: labelNama, imageView)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v0]", views: labelNama )
        addConstraintsWithFormat("V:|[v0(30)][v1(1)]|", views: imageView,dividerLineView)
        
    }
    
}



