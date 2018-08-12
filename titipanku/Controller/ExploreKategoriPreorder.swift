//
//  ExploreKategoriPreorder.swift
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

class ExploreKategoriPreorder: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [App]()
    var isiData : isi?
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let negara = isiData?.nama{
            let urlString = "http://titipanku.xyz/api/GetExploreKategoriPreorder.php?negara=\(String(describing: negara))"
            
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
        collectionView?.register(RequestCell1.self, forCellWithReuseIdentifier: RequestCellId)
        setupView()
    }
    
    private func setupView(){
        view.backgroundColor = .white
        let screenWidth = UIScreen.main.bounds.width
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        //collectionView?.backgroundColor = UIColor.green
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        //collectionView?.centerXAnchor.constraint(equalTo: view.centerXAnchor/-4 ).isActive = true
        //collectionView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -400).isActive = true
        //collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: 600).isActive = true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return requests.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! RequestCell1
        cell.app = requests[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hex: "#d1d8e0").cgColor
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("asd")
        if let app : App = requests[indexPath.item] {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            let addDetail = barangDetailController(collectionViewLayout: layout)
            addDetail.app = app
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            present(addDetail, animated: false, completion: nil)
        }else{
            print("no app")
        }
        
    }
}
