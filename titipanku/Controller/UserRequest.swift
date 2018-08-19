//
//  UserRequest.swift
//  titipanku
//
//  Created by Ricky Wirawan on 24/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Alamofire
import AlamofireImage
import Hue

class UserRequest: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [App]()
    var isiData : isi?
    var collectionview: UICollectionView!
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            let urlString = "http://titipanku.xyz/api/GetRequestUser.php?email=\(String(describing: emailNow))"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.requests = try decoder.decode([App].self, from: data)
                    print(self.requests)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.requests)
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
        self.fetchRequests{(requests) -> ()in
            self.requests = requests
            print("count request" + String(self.requests.count))
            self.collectionview.reloadData()
            SKActivityIndicator.dismiss()
        }
        navigationItem.title = "Request"
        
    }
    
    private func setupView(){
        let screenWidth = UIScreen.main.bounds.width
        print(screenWidth)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 220, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: 700)
        
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionview.register(HistoryCell.self, forCellWithReuseIdentifier: RequestCellId)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        self.view.addSubview(collectionview)
        
        self.collectionview.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(collectionView!)
//        //collectionView?.widthAnchor.constraint(equalToConstant: 300).isActive = true
//        //collectionView?.backgroundColor = UIColor.green
        self.collectionview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.collectionview.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
//        //collectionView?.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: screenWidth / -2).isActive = true
//
        self.collectionview.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: screenWidth / -2).isActive = true
//        //collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        self.collectionview.heightAnchor.constraint(equalToConstant: 600).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! HistoryCell
        
        if let id = requests[indexPath.row].id {
            Alamofire.request("http://titipanku.xyz/uploads/b"+id+".jpg").responseImage { response in
                if let image = response.result.value {
                    cell.imageView.image = image
                }
            }
        }
        cell.labelCountry.text = requests[indexPath.row].name
        cell.LabelTgl.text = requests[indexPath.row].tglPost
        if requests[indexPath.row].status == "0"{
            cell.LabelStatus.text = "Ditolak"
        }else if requests[indexPath.row].status == "1"{
            cell.LabelStatus.text = "Belum Diterima"
        }else if requests[indexPath.row].status == "2"{
            cell.LabelStatus.text = "Diterima"
        }else if requests[indexPath.row].status == "3"{
            cell.LabelStatus.text = "Sudah Dibelikan"
        }else if requests[indexPath.row].status == "4"{
            cell.LabelStatus.text = "Sudah Dikirim"
        }else if requests[indexPath.row].status == "5"{
            cell.LabelStatus.text = "Selesai"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requests.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("asd")
        if let app : App = requests[indexPath.item] {
            
            let layout = UICollectionViewFlowLayout()
            let appDetailController = barangDetailController(collectionViewLayout: layout)
            appDetailController.app = app
            navigationController?.pushViewController(appDetailController, animated: true)
        }else{
            print("no app")
        }
        
    }
}

class HistoryCell: BaseCell {
    
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
        label.text = "Nama : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    let labelCountry : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        //        label.layer.borderWidth = 1
        //        label.layer.borderColor = UIColor.green.cgColor
        return label
    }()
    
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Tanggal : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    let LabelTgl : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    let labelC : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Status : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    let LabelStatus : UILabel = {
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
        addSubview(labelCountry)
        addSubview(LabelTgl)
        addSubview(labelC)
        addSubview(LabelStatus)
        addSubview(imageView)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-5-[v2(100)]-10-[v0]-5-[v1]", views: labelA,labelCountry,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-5-[v2(100)]-10-[v0]-5-[v1]", views: labelB,LabelTgl,imageView)
        addConstraintsWithFormat("H:|-5-[v2(100)]-10-[v0]-5-[v1]", views: labelC,LabelStatus,imageView)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-5-[v0(100)]", views: imageView)
        addConstraintsWithFormat("V:|-15-[v0]-5-[v1]-5-[v2]", views: labelA,labelB,labelC)
        addConstraintsWithFormat("V:|-15-[v0]-5-[v1]-5-[v2]", views: labelCountry,LabelTgl,LabelStatus )
        addConstraintsWithFormat("V:|[v0(1)]", views: dividerLineView )
        
    }
    
}

