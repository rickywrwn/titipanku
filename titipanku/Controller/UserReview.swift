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
        let reviewer: String
        
    }
    
    func fetchRequests(_ completionHandler: @escaping ([review]) -> ()) {
        if let emailNow : String = UserController.emailUser.email {
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
        collectionView?.register(ReviewCell.self, forCellWithReuseIdentifier: RequestCellId)
        view.backgroundColor = .white
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.collectionView?.reloadData()
    }
    
    private func setupView(){
        let backButton : UIButton = {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            button.setTitle("Cancel", for: .normal)
            button.setTitleColor(button.tintColor, for: .normal) // You can change the TitleColor
            button.addTarget(self, action: #selector(handleBack), for: UIControlEvents.touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        
        //collectionView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: screenWidth/4).isActive = true
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        //backButton
        view.addSubview(backButton)
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
    }
    
    @objc public func handleBack(){
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! ReviewCell
        if let email : String = reviews[indexPath.row].reviewer  {
            Alamofire.request("http://titipanku.xyz/uploads/"+email+".jpg").responseImage { response in
                if let image = response.result.value {
                    cell.imageView.image = image
                }
            }
        }
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

class ReviewCell: BaseCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "coba")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Rating : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    let labelCountry : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        //        label.layer.borderWidth = 1
        //        label.layer.borderColor = UIColor.green.cgColor
        return label
    }()
    
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Review : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    let LabelTgl : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        addSubview(labelB)
        addSubview(labelCountry)
        addSubview(LabelTgl)
        addSubview(imageView)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-5-[v2(100)]-10-[v0]-5-[v1]", views: labelA,labelCountry,imageView) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-5-[v2(100)]-10-[v0]-5-[v1]", views: labelB,LabelTgl,imageView)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-5-[v0(100)]", views: imageView)
        addConstraintsWithFormat("V:|-15-[v0]-5-[v1]", views: labelA,labelB)
        addConstraintsWithFormat("V:|-15-[v0]-5-[v1]", views: labelCountry,LabelTgl )
        addConstraintsWithFormat("V:|[v0(1)]", views: dividerLineView )
        
    }
    
}





