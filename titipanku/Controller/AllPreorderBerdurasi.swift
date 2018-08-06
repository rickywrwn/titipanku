//
//  AllPreorderBerdurasi.swift
//  titipanku
//
//  Created by Ricky Wirawan on 03/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Alamofire
import AlamofireImage
import Hue
import SKActivityIndicatorView

class AllPreorderBerdurasi: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [App]()
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        let urlString = "http://titipanku.xyz/api/GetAllPreorderBerdurasi.php"
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        self.fetchRequests{(requests) -> ()in
            self.requests = requests
            print("count Preorder" + String(self.requests.count))
            self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Preorder Berdurasi"
        collectionView?.register(RequestCell.self, forCellWithReuseIdentifier: RequestCellId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return requests.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! RequestCell
        cell.app = requests[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hex: "#d1d8e0").cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2, height: 265)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let app : App = requests[indexPath.item] {
            print("pencet preorder 2 gan")
            let layout = UICollectionViewFlowLayout()
            let appDetailController = FlashsaleDetail(collectionViewLayout: layout)
            appDetailController.app = app
            navigationController?.pushViewController(appDetailController, animated: true)
        }
        
    }
}



