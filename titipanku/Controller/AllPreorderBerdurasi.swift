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
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //supaya navbar full
        // Create the navigation bar
        let screenSize: CGRect = UIScreen.main.bounds
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 0))
        navbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navbar)
        navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        navbar.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        // Offset by 20 pixels vertically to take the status bar into account
        navbar.backgroundColor = UIColor(hex: "#3867d6")
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Preorder"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        collectionView?.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - 64))
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        self.fetchRequests{(requests) -> ()in
            self.requests = requests
            print("count Preorder" + String(self.requests.count))
            self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Preorder"
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
            print("pencet preorder")
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            let appDetailController = PreorderDetail(collectionViewLayout: layout)
            appDetailController.app = app
            present(appDetailController, animated: true, completion: {
            })
        }
        
    }
}
