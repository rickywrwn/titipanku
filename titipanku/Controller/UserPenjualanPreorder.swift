//
//  UserPenjualanPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 13/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Alamofire
import AlamofireImage
import Hue

class UserPenjualanPreorder: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [VarOfferPreorder]()
    var app : App?
    var isiData : isi?
    var collectionview: UICollectionView!
    
    func fetchRequests(_ completionHandler: @escaping ([VarOfferPreorder]) -> ()) {
        print("asdads")
        if let emailNow : String = UserController.emailUser.email {
            
            print(emailNow)
            let urlString = "http://titipanku.xyz/api/GetUserPenjualanPreorder.php?email=\(String(describing: emailNow))"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.requests = try decoder.decode([VarOfferPreorder].self, from: data)
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
            self.collectionview.reloadData()
            SKActivityIndicator.dismiss()
        }
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.collectionView?.reloadData()
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
        
        //SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        let urlString = "http://titipanku.xyz/api/DetailPreorder.php?id=\(requests[indexPath.row].idPreorder)"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                let appDetail = try decoder.decode(App.self, from: data)
                //print(appDetail)
                self.app = appDetail
                
                DispatchQueue.main.async(execute: { () -> Void in
                    //SKActivityIndicator.dismiss()
                    
                    cell.labelCountry.text = appDetail.name
                })
                
            } catch let err {
                print(err)
            }
            
            
        }).resume()
        
        if let id : String = requests[indexPath.row].idPreorder {
            Alamofire.request("http://titipanku.xyz/uploads/p"+id+".jpg").responseImage { response in
                if let image = response.result.value {
                    cell.imageView.image = image
                }
            }
        }
        cell.LabelTgl.text = requests[indexPath.row].tglBeli
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
    
    @objc func showDetail(){
        if let app : App = app{
            let layout = UICollectionViewFlowLayout()
            let appDetailController = PreorderDetail(collectionViewLayout: layout)
            appDetailController.app = app
            present(appDetailController, animated: true, completion: {
            })
        }else{
            print("no app")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("asd")
        print(requests[indexPath.row].idPreorder)
        
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        let urlString = "http://titipanku.xyz/api/DetailPreorder.php?id=\(requests[indexPath.row].idPreorder)"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                let appDetail = try decoder.decode(App.self, from: data)
                //print(appDetail)
                self.app = appDetail
                
                DispatchQueue.main.async(execute: { () -> Void in
                    SKActivityIndicator.dismiss()
                    self.showDetail()
                })
                
            } catch let err {
                print(err)
            }
            
            
        }).resume()
        
    }
}



