//
//  ExploreNegaraPreorder.swift
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

class ExploreNegaraPreorder: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let PreorderCellId = "PreorderCellId"
    var preorders = [App]()
    var isiData : isi?
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let negara = isiData?.nama{
            let urlString = "http://titipanku.xyz/api/GetExploreNegaraPreorder.php?negara=\(String(describing: negara))"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.preorders = try decoder.decode([App].self, from: data)
                    print(self.preorders)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.preorders)
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
        self.fetchRequests{(preorders) -> ()in
            self.preorders = preorders
            print("count request" + String(self.preorders.count))
            self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
        collectionView?.backgroundColor = UIColor.white
        print(self.preorders)
        collectionView?.register(RequestCell.self, forCellWithReuseIdentifier: PreorderCellId)
        setupView()
    }
    
    private func setupView(){
        view.backgroundColor = .white
        let screenWidth = UIScreen.main.bounds.width
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        //collectionView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: screenWidth/2).isActive = true
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: 600).isActive = true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return preorders.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreorderCellId, for: indexPath) as! RequestCell
        cell.app = preorders[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hex: "#d1d8e0").cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2-7, height: 265)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("asd")
        if let app : App = preorders[indexPath.item] {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            let addDetail = PreorderDetail(collectionViewLayout: layout)
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
