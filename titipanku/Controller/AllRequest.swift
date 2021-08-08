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
    
    struct userDetail: Decodable {
        let email: String
        let name: String
        let saldo: String
        let valueSaldo: String
        let berat: String
        let ukuran: String
    }
    var isiUser  : userDetail?
    
    fileprivate func fetchJSON() {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            print(emailNow)
            let urlString = "http://titipanku.xyz/api/DetailUser.php?email=\(String(describing: emailNow))"
            guard let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { (data, _, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        print("Failed to get data from url:", err)
                        return
                    }
                    
                    guard let data = data else { return }
                    print(data)
                    do {
                        // link in description for video on JSONDecoder
                        let decoder = JSONDecoder()
                        // Swift 4.1
                        self.isiUser = try decoder.decode(userDetail.self, from: data)
                        print(self.isiUser)
                        
                        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
                        self.fetchRequests{(requests) -> ()in
                            self.requests = requests
                            print("count request" + String(self.requests.count))
                            self.collectionView?.reloadData()
                            SKActivityIndicator.dismiss()
                        }
                   
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                        
                        SKActivityIndicator.dismiss()
                    }
                }
                }.resume()
        }
    }
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            
            let urlString = "http://titipanku.xyz/api/GetAllRequest.php?email=\(String(describing: emailNow))"
            print(urlString)
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
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchJSON()
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
        navigationItem.title = "Permintaan"
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
        
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Permintaan"
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
            present(appDetailController, animated: true, completion: {
            })
        }
        
    }
}

class RequestCell: BaseCell {
    var time = 0.0
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
            
            if app?.batasWaktu == "1", let cdValue : Double = app?.cdValue{
                var timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
                
                time = cdValue
                let hours = Int(time) / 3600
                let minutes = Int(time) / 60 % 60
                let seconds = Int(time) % 60
                categoryLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            }else{
                
                categoryLabel.text = app?.country
            }
            
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
    
    @objc func updateCounter() {
        //you code, this is an example
        time = time - 1
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        //print(String(format:"%02i:%02i:%02i", hours, minutes, seconds))
        categoryLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
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
