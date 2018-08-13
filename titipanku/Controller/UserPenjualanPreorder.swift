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

class UserPenjualanPreorder: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [VarOfferPreorder]()
    var app : App?
    var isiData : isi?
    
    func fetchRequests(_ completionHandler: @escaping ([VarOfferPreorder]) -> ()) {
        print("asdads")
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            
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
            self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Request"
        collectionView?.register(HistoryCell.self, forCellWithReuseIdentifier: RequestCellId)
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.collectionView?.reloadData()
    }
    
    private func setupView(){
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
    
    @objc func showDetail(){
        if let app : App = app{
            let layout = UICollectionViewFlowLayout()
            let appDetailController = PreorderDetail(collectionViewLayout: layout)
            appDetailController.app = app
            navigationController?.pushViewController(appDetailController, animated: true)
        }else{
            print("no app")
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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



