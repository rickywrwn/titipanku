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

class UserPreorder: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "PreorderCellId"
    var requests = [App]()
    var isiData : isi?
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
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
        cell.LabelTgl.text = requests[indexPath.row].status
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
