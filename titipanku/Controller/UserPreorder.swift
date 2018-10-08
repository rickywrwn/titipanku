//
//  UserPreorder.swift
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

class UserPreorder: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "PreorderCellId"
    var requests = [App]()
    var isiData : isi?
    var collectionview: UICollectionView!
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let emailNow : String = UserController.emailUser.email  {
            let urlString = "http://titipanku.xyz/api/GetPreorderUser.php?email=\(String(describing: emailNow))"
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
                if self.requests.count <= 0 {
                    let alert = UIAlertController(title: "Message", message: "Tidak ada data untuk ditampilkan", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
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
            if self.requests.count <= 0 {
                let alert = UIAlertController(title: "Message", message: "Tidak ada Data untuk ditampilkan", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func setupView(){
        let screenWidth = UIScreen.main.bounds.width
        print(screenWidth)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: 700)
        
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionview.register(HistoryCell.self, forCellWithReuseIdentifier: RequestCellId)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        self.view.addSubview(collectionview)
        
        self.collectionview.translatesAutoresizingMaskIntoConstraints = false
        self.collectionview.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        self.collectionview.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: 0).isActive = true
        self.collectionview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        self.collectionview.heightAnchor.constraint(equalToConstant: 600).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! HistoryCell
        
        if let id = requests[indexPath.row].id {
            Alamofire.request("http://titipanku.xyz/uploads/p"+id+".jpg").responseImage { response in
                //debugPrint(response)
                //let nama = self.app?.name
                //print("gambar : "+imageName)
                if let image = response.result.value {
                    //print("image downloaded: \(image)")
                    cell.imageView.image = image
                }
            }
        }
        cell.labelCountry.text = requests[indexPath.row].name
        cell.LabelTgl.text = requests[indexPath.row].tglPost
        if requests[indexPath.row].status == "1"{
            cell.LabelStatus.text = "Buka"
        }else if requests[indexPath.row].status == "5"{
            cell.LabelStatus.text = "Tutup"
        }else{
            cell.LabelStatus.text = requests[indexPath.row].status
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
            let appDetailController = PreorderDetail(collectionViewLayout: layout)
            appDetailController.app = app
            present(appDetailController, animated: true, completion: {
            })
        }else{
            print("no app")
        }
        
    }
}
