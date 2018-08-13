//
//  UserReview.swift
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

class UserReview: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"

    var reviews = [review]()
    struct review: Decodable {
        let id: String
        let review: String
        let rating: String
        
    }
    
    func fetchRequests(_ completionHandler: @escaping ([review]) -> ()) {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            print(emailNow)
            let urlString = "http://titipanku.xyz/api/GetReview.php?email=\(String(describing: emailNow))"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.reviews = try decoder.decode([review].self, from: data)
                    print(self.reviews)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.reviews)
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
            self.reviews = requests
            print("count request" + String(self.reviews.count))
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
        cell.labelCountry.text = reviews[indexPath.row].rating
        cell.LabelTgl.text = reviews[indexPath.row].review
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}



