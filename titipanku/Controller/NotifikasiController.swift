//
//  NotifikasiController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 23/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Alamofire
import AlamofireImage
import Hue

class NotifikasiController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    var notifications  = [notifikasiDetail]()
    struct notifikasiDetail: Decodable {
        let id: String
        let name: String
        let email: String
        let idTujuan: String
        let jenis: String
        let tanggal: String
        
    }
    var collectionview: UICollectionView!
    func fetchRequests(_ completionHandler: @escaping ([notifikasiDetail]) -> ()) {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String  {
            let urlString = "http://titipanku.xyz/api/GetNotifikasiUser.php?email=\(String(describing: emailNow))"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.notifications = try decoder.decode([notifikasiDetail].self, from: data)
                    print(self.notifications)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.notifications)
                    })
                } catch let err {
                    print(err)
                    
                    self.collectionview.reloadData()
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
        
    }
    var app: App?
    func fetchDetail(idRequest : String, completionHandler: @escaping (App) -> ()) {
        if let id : String = idRequest  {
            let urlString = "http://titipanku.xyz/api/DetailBarang.php?id=\(id)"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.app = try decoder.decode(App.self, from: data)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.app!)
                    })
                } catch let err {
                    print(err)
                    
                    self.collectionview.reloadData()
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        self.fetchRequests{(notifications) -> ()in
            self.notifications = notifications
            print("count request" + String(self.notifications.count))
            self.collectionview.reloadData()
            SKActivityIndicator.dismiss()
        }
        
    }
    
    private func setupView(){
        let screenWidth = UIScreen.main.bounds.width
        print(screenWidth)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 220, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: 700)
        
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionview.register(NotificationCell.self, forCellWithReuseIdentifier: RequestCellId)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        self.view.addSubview(collectionview)
        
        self.collectionview.translatesAutoresizingMaskIntoConstraints = false
        self.collectionview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        self.collectionview.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        self.collectionview.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: screenWidth / -2).isActive = true
        self.collectionview.heightAnchor.constraint(equalToConstant: 600).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! NotificationCell
        
        if let id : String = notifications[indexPath.row].idTujuan {
            Alamofire.request("http://titipanku.xyz/uploads/b"+id+".jpg").responseImage { response in
                if let image = response.result.value {
                    cell.imageView.image = image
                }
            }
        }
        cell.labelA.text = notifications[indexPath.row].name
        cell.labelB.text = notifications[indexPath.row].tanggal

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SKActivityIndicator.show("Loading...")
        self.fetchDetail(idRequest: notifications[indexPath.row].idTujuan,completionHandler: {(app) -> () in
            self.app = app
            print(app)
            if let appe : App = self.app {

                let layout = UICollectionViewFlowLayout()
                let appDetailController = barangDetailController(collectionViewLayout: layout)
                appDetailController.app = appe
                self.present(appDetailController, animated: true, completion: {
                    SKActivityIndicator.dismiss()
                })
            }else{
                print("no app")
                SKActivityIndicator.dismiss()
            }
            
        })
    }
    
}

class NotificationCell: BaseCell {
    
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
        label.text = "Nama"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Tanggal"
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

