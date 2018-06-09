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

class UserController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var cekLogged : Bool = UserDefaults.standard.bool(forKey: "logged")
    struct userDetail: Decodable {
        let name: String
        let email: String
        let tanggalDaftar: String
        
    }
    var isiUser  : userDetail?
    
    fileprivate func fetchJSON() {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            print(emailNow)
            let urlString = "http://localhost/titipanku/DetailUser.php?email=\(String(describing: emailNow))"
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
                        
                        self.collectionView?.reloadData()
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                    }
                }
                }.resume()
        }
    }
    
    fileprivate let userCellId = "userCellId"
    fileprivate let buttonCellId = "btnCellId"
    fileprivate let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        self.title = "User"
        navigationItem.title = "Profile"
        print("User Loaded")
        fetchJSON()
        collectionView?.alwaysBounceVertical = true

        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(UserDetailCell.self, forCellWithReuseIdentifier: userCellId)
        collectionView?.register(UserButton.self, forCellWithReuseIdentifier: buttonCellId)
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
        print("diskusi")
        let layout = UICollectionViewFlowLayout()
        let komentarController = UserTripList(collectionViewLayout: layout)
        navigationController?.pushViewController(komentarController, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! UserDetailCell
           
            
            cell.labelEmail.text = isiUser?.email
            cell.LabelNama.text = isiUser?.name
             cell.LabelTanggal.text = isiUser?.tanggalDaftar
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buttonCellId, for: indexPath) as! UserButton
            cell.diskusiButton.addTarget(self, action: #selector(handleLogout), for: UIControlEvents.touchDown)
            cell.diskusiButton1.addTarget(self, action: #selector(handleTrip), for: UIControlEvents.touchDown)
            
            return cell
        }
        //untuk screenshot
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotsCell
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: view.frame.width, height: 170)
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
//        label.layer.borderWidth = 1
//        label.layer.borderColor = UIColor.green.cgColor
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
        
        addConstraintsWithFormat("H:|-4-[v2(100)]-20-[v1]-1-[v0]", views: labelEmail,labelA,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-4-[v2(100)]-20-[v0]-1-[v1]", views: labelB,LabelNama,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-4-[v2(100)]-20-[v0]-1-[v1]", views: labelC,LabelTanggal,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-25-[v0(100)]", views: imageView)
        addConstraintsWithFormat("V:|-30-[v0]-4-[v1]-4-[v2]", views: labelA,labelB,labelC)
        addConstraintsWithFormat("V:|-30-[v0]-4-[v1]-4-[v2]", views: labelEmail,LabelNama,LabelTanggal )
        addConstraintsWithFormat("V:|-155-[v0(1)]", views:dividerLineView )
        
    }
    
}


class UserButton: BaseCell {
    
    let diskusiButton : UIButton = {
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let diskusiButton1 : UIButton = {
        let button = UIButton()
        button.setTitle("Trip", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(diskusiButton)
        addSubview(diskusiButton1)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-30-[v0(150)]-4-[v1(150)]-30-|", views: diskusiButton, diskusiButton1)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v0(50)]", views: diskusiButton )
        addConstraintsWithFormat("V:|[v0(50)][v1(1)]|", views: diskusiButton1,dividerLineView )
        
    }
    
}




