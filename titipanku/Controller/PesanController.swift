//
//  PesanController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 23/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SKActivityIndicatorView
import Firebase
import FirebaseDatabase

struct chatroom: Decodable {
    let id: String
    let emailA: String
    let emailB: String
    let tanggal: String
    let jenis: String
    let tujuan: String
    let idTujuan: String
}
class PesanController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    
    var chats  = [chatroom]()
    
    
    @objc func handleReload(){
        SKActivityIndicator.show("Loading...")
        self.fetchRequests{(chats) -> ()in
            self.chats = chats
            print("count request" + String(self.chats.count))
            self.collectionChat.reloadData()
            SKActivityIndicator.dismiss()
        }
    }
    
    var collectionChat: UICollectionView!
    func fetchRequests(_ completionHandler: @escaping ([chatroom]) -> ()) {
        if let email = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            let urlString = "http://titipanku.xyz/api/GetChatroom.php?email=\(String(describing: email))"
            
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
                    
                    self.collectionChat.reloadData()
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.hideKeyboardWhenTappedAround()
        
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        self.fetchRequests{(chats) -> ()in
            self.chats = chats
            print(self.chats)
            self.collectionChat.reloadData()
            SKActivityIndicator.dismiss()
        }
        
        setupView()
    }
    
    private func setupView(){
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: 700)
        
        collectionChat = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionChat.register(ChatroomCell.self, forCellWithReuseIdentifier: RequestCellId)
        collectionChat.dataSource = self
        collectionChat.delegate = self
        collectionChat.showsVerticalScrollIndicator = false
        collectionChat.backgroundColor = UIColor.white
        self.view.addSubview(collectionChat)
        
        self.collectionChat.translatesAutoresizingMaskIntoConstraints = false
        self.collectionChat.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        self.collectionChat.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        self.collectionChat.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: 0).isActive = true
        self.collectionChat.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
       
    }
    
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! ChatroomCell
        
        if let id : String = chats[indexPath.row].id,let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let emailA : String =  chats[indexPath.row].emailA, let emailB : String =  chats[indexPath.row].emailB, let jenis : String = chats[indexPath.row].jenis {
            
            if emailNow == emailA{
                cell.labelA.text = emailB
                Alamofire.request("http://titipanku.xyz/uploads/"+emailB+".jpg").responseImage { response in
                    if let image = response.result.value {
                        cell.imageView.image = image
                    }
                }
            }else{
                cell.labelA.text = emailA
                Alamofire.request("http://titipanku.xyz/uploads/"+emailA+".jpg").responseImage { response in
                    if let image = response.result.value {
                        cell.imageView.image = image
                    }
                }
            }
            
            if jenis == "masalah"{
                cell.labelA.textColor = UIColor.red
            }
        }
        cell.labelB.text = chats[indexPath.row].tanggal
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chats.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if let chat : chatroom = chats[indexPath.item] {
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
            view.window!.layer.add(transition, forKey: kCATransition)
            present(addDetail, animated: false, completion: nil)
        }else{
            print("no app")
        }
    }
}

class ChatroomCell: BaseCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "coba")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    let labelB : UILabel = {
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
        addSubview(imageView)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-5-[v1(100)]-10-[v0]", views: labelA,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-5-[v1(100)]-10-[v0]", views: labelB,imageView)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-5-[v0(100)]", views: imageView)
        addConstraintsWithFormat("V:|-15-[v0]-5-[v1]", views: labelA,labelB)
        addConstraintsWithFormat("V:|[v0(1)]", views: dividerLineView )
        
    }
    
}


