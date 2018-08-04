//
//  ExploreNegaraPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 03/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit

import UIKit
import SKActivityIndicatorView
import Alamofire
import AlamofireImage
import Hue

class ExploreNegaraPreorder: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [App]()
    var isiData : isi?
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let negara = isiData?.nama {
            
            let urlString = "http://titipanku.xyz/api/GetPreorderNegara.php?negara=\(String(describing: negara ))"
            
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
        self.fetchRequests{(requests) -> ()in
            self.requests = requests
            print("count Preorder" + String(self.requests.count))
            self.collectionView?.reloadData()
        }
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Preorder"
        collectionView?.register(RequestCell.self, forCellWithReuseIdentifier: RequestCellId)
        setupView()
    }
    
    private func setupView(){
        view.backgroundColor = .white
        let screenWidth = UIScreen.main.bounds.width
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -110).isActive = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return requests.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! RequestCell
        cell.app = requests[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hex: "#3867d6").cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2, height: 265)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let app : App = requests[indexPath.item] {
            print("pencet preorder")
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            let appDetailController = PreorderDetail(collectionViewLayout: layout)
            appDetailController.app = app
            navigationController?.pushViewController(appDetailController, animated: true)
        }
        
    }
}

