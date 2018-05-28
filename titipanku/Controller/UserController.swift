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
    var users = [userDetail]()
    struct userDetail: Decodable {
        let name: String
        let email: String
        
    }
    var isiUser  : userDetail?
    
    fileprivate func fetchJSON() {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            print(emailNow)
            let urlString = "http://45.76.178.35/titipanku/DetailUser.php?email=\(String(describing: emailNow))"
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! UserDetailCell
        cell.labelEmail.text = isiUser?.email
        cell.logoutButton.addTarget(self, action: #selector(handleLogout), for: UIControlEvents.touchDown)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: view.frame.width, height: 170)
    }
    
}

class UserDetailCell: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.text = "Email : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let labelEmail : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
//        label.layer.borderWidth = 1
//        label.layer.borderColor = UIColor.green.cgColor
        return label
    }()
    
    let LabelNama : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let logoutButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
       // button.addTarget(self, action: #selector(handleLogout), for: UIControlEvents.touchDown)
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
        
        addSubview(labelA)
        addSubview(labelEmail)
        addSubview(logoutButton)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-10-[v1(50)]-1-[v0(300)]", views: labelEmail,labelA) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-4-[v0(100)]|", views: logoutButton)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v0(20)]", views: labelA)
        addConstraintsWithFormat("V:|[v0(20)]-4-[v1(50)]-4-[v2(1)]|", views: labelEmail,logoutButton,dividerLineView )
        
    }
    
}




