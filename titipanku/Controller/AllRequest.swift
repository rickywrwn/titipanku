//
//  AllRequest.swift
//  titipanku
//
//  Created by Ricky Wirawan on 02/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Alamofire
import AlamofireImage
import Hue

class AllRequest: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [App]()
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        let urlString = "http://titipanku.xyz/api/GetAllRequest.php"
        
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
            print("count request" + String(self.requests.count))
            self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Request"
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
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            let appDetailController = barangDetailController(collectionViewLayout: layout)
            appDetailController.app = app
            navigationController?.pushViewController(appDetailController, animated: true)
        }
        
    }
}

class RequestCell: BaseCell {
    
    var app: App? {
        didSet {
            if let name = app?.name {
                nameLabel.text = name
                let rect = NSString(string: name).boundingRect(with: CGSize(width: frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], context: nil)
                
                if rect.height > 20 {
                    categoryLabel.frame = CGRect(x: 15, y: frame.width + 33, width: frame.width, height: 20)
                    priceLabel.frame = CGRect(x:15, y: frame.width + 51, width: frame.width, height: 20)
                } else {
                    categoryLabel.frame = CGRect(x: 15, y: frame.width + 17, width: frame.width, height: 20)
                    priceLabel.frame = CGRect(x: 15, y: frame.width + 35, width: frame.width, height: 20)
                }
                
                nameLabel.frame = CGRect(x: 15, y: frame.width - 5, width: frame.width, height: 40)
                nameLabel.sizeToFit()
                
            }
            
            categoryLabel.text = app?.country
            if let price = app?.price {
                priceLabel.text = "Rp \(price)"
            } else {
                priceLabel.text = ""
            }
            
            //async get image dari web
            DispatchQueue.main.async{
                
                if let imageName = self.app?.ImageName {
                    Alamofire.request("http://titipanku.xyz/uploads/"+imageName).responseImage { response in
                        //debugPrint(response)
                        //let nama = self.app?.name
                        //print("gambar : "+imageName)
                        if let image = response.result.value {
                            //print("image downloaded: \(image)")
                            self.imageView.image = image
                        }
                    }
                }
                
                
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hex: "#4b7bec")
        return label
    }()
    
    override func setupViews() {
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(categoryLabel)
        addSubview(priceLabel)
        
        imageView.frame = CGRect(x: 15, y: 15, width: frame.width-25, height: frame.width-25)
        nameLabel.frame = CGRect(x: 15, y: frame.width - 2, width: frame.width-100, height: 40)
        categoryLabel.frame = CGRect(x: 15, y: frame.width + 33, width: frame.width-100, height: 20)
        priceLabel.frame = CGRect(x: 15, y: frame.width + 51, width: frame.width-100, height: 20)
        
    }
    
}
