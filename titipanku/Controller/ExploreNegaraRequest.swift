//
//  ExploreNegaraRequest.swift
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

class ExploreNegaraRequest: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [App]()
    var isiData : isi?
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let negara = isiData?.nama{
            let urlString = "http://titipanku.xyz/api/GetExploreNegaraRequest.php?negara=\(String(describing: negara))"
            
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

class RequestCell1: BaseCell {
    
    var app: App? {
        didSet {
            if let name = app?.name {
                nameLabel.text = name
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
        
        addConstraintsWithFormat("H:|-4-[v0(100)]|", views: imageView)
        addConstraintsWithFormat("H:|-4-[v0]|", views: nameLabel)
        addConstraintsWithFormat("H:|-4-[v0]|", views: categoryLabel)
        addConstraintsWithFormat("H:|-4-[v0]|", views: priceLabel)
        
        addConstraintsWithFormat("V:|-4-[v0(100)]|", views: imageView)
        addConstraintsWithFormat("V:|-4-[v0]|", views: nameLabel)
        addConstraintsWithFormat("V:|-4-[v0]|", views: categoryLabel)
        addConstraintsWithFormat("V:|-4-[v0]|", views: priceLabel)
        
    }
    
}


