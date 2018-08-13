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

class UserRequest: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [App]()
    var isiData : isi?
    
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
                    
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        self.fetchRequests{(requests) -> ()in
            self.requests = requests
            print("count request" + String(self.requests.count))
            self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Request"
        collectionView?.register(HistoryCell.self, forCellWithReuseIdentifier: RequestCellId)
        setupView()
    }
    
    private func setupView(){
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! HistoryCell
        
        
        cell.labelCountry.text = requests[indexPath.row].name
        if requests[indexPath.row].status == "0"{
            cell.LabelTgl.text = "Ditolak"
        }else if requests[indexPath.row].status == "1"{
            cell.LabelTgl.text = "Belum Diterima"
        }else if requests[indexPath.row].status == "2"{
            cell.LabelTgl.text = "Diterima"
        }else if requests[indexPath.row].status == "3"{
            cell.LabelTgl.text = "Sudah Dibelikan"
        }else if requests[indexPath.row].status == "4"{
            cell.LabelTgl.text = "Sudah Dikirim"
        }else if requests[indexPath.row].status == "5"{
            cell.LabelTgl.text = "Selesai"
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requests.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("asd")
        if let app : App = requests[indexPath.item] {
            
            let layout = UICollectionViewFlowLayout()
            let appDetailController = barangDetailControllerUser(collectionViewLayout: layout)
            appDetailController.app = app
            navigationController?.pushViewController(appDetailController, animated: true)
        }else{
            print("no app")
        }
        
    }
}

class HistoryCell: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Nama : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Status : "
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
    
    let LabelTgl : UILabel = {
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
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-4-[v0]-5-[v1]", views: labelA,labelCountry) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-4-[v0]-5-[v1]", views: labelB,LabelTgl) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-4-[v0]-4-[v1]", views: labelA,labelB)
        addConstraintsWithFormat("V:|-4-[v0]-4-[v1]", views: labelCountry,LabelTgl )
        addConstraintsWithFormat("V:|[v0(1)]", views: dividerLineView )
        
    }
    
}

