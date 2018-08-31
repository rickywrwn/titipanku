//
//  CategoryCell.swift
//  titipanku
//
//  Created by Ricky Wirawan on 17/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//


import UIKit
import AlamofireImage
import Alamofire
import Hue

var itung : Int = 0

class CategoryCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @objc func handleMoreBarang() {
       
        print("Barang")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMoreRequest"), object: nil)
    }
   
    @objc func handleMorePreoder() {
        
        print("Preorder")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMorePreorder"), object: nil)
    }
    
    @objc func handleMoreFlashsale() {
        
        print("Flashsale")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showMorePreorderBerdurasi"), object: nil)
    }
    
    var homeController: homeController?
    var appCategory: AppCategory? {
        didSet {
            if let name = appCategory?.name {
                nameLabel.text = name
            }
//            if itung == 1 {
//                btnMore.addTarget(self, action: #selector(handleMoreBarang), for: UIControlEvents.touchDown)
//                
//                
//            }else if itung == 2 {
//                btnMore.addTarget(self, action: #selector(handleMorePreoder), for: UIControlEvents.touchDown)
//                
//            }else {
//                btnMore.addTarget(self, action: #selector(handleMoreFlashsale), for: UIControlEvents.touchDown)
//                
//            }
            
//            itung += 1
            appsCollectionView.reloadData()
        }
    }
    
    fileprivate let cellId = "appCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Best New Apps"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let btnMore : UIButton = {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("a", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 20)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    let appsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupViews() {
        backgroundColor = UIColor.clear
        
        addSubview(appsCollectionView)
        addSubview(dividerLineView)
        addSubview(nameLabel)
        addSubview(btnMore)
        
        appsCollectionView.dataSource = self
        appsCollectionView.delegate = self
        
        appsCollectionView.register(AppCell.self, forCellWithReuseIdentifier: cellId)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[v0][v1]-20-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel,"v1": btnMore]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": dividerLineView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appsCollectionView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[nameLabel(30)][v0][v1(0.5)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appsCollectionView, "v1": dividerLineView, "nameLabel": nameLabel, "v2": btnMore]))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = appCategory?.apps?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AppCell
        cell.app = appCategory?.apps?[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: frame.height - 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 14, 0, 14)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if reuseIdentifier != "headerId"{
            if reuseIdentifier == "preorderCellId"{
                
                print("preorder")
                if let app = appCategory?.apps?[indexPath.item] {
                    homeController!.showPreorderDetailForApp(app)
                }
            }else if reuseIdentifier == "cellId"{
                print("barang")
                if let app = appCategory?.apps?[indexPath.item] {
                    homeController!.showAppDetailForApp(app)
                }
            }else if reuseIdentifier == "flashCellId"{
                print("masuk flashcell")
                if let app = appCategory?.apps?[indexPath.item] {
                    homeController!.showFlashSaleDetailForApp(app)
                }
            }
        }
        
    }
    
}

class AppCell: UICollectionViewCell {
    
   
    var time = 0.0
    var app: App? {
        didSet {
            if let name = app?.name {
                nameLabel.text = name
                let rect = NSString(string: name).boundingRect(with: CGSize(width: frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], context: nil)
                
                if rect.height > 20 {
                    categoryLabel.frame = CGRect(x: 0, y: frame.width + 38, width: frame.width, height: 20)
                    priceLabel.frame = CGRect(x: 0, y: frame.width + 56, width: frame.width, height: 20)
                } else {
                    categoryLabel.frame = CGRect(x: 0, y: frame.width + 22, width: frame.width, height: 20)
                    priceLabel.frame = CGRect(x: 0, y: frame.width + 40, width: frame.width, height: 20)
                }
                
                nameLabel.frame = CGRect(x: 0, y: frame.width + 5, width: frame.width, height: 40)
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
    
    func setupViews() {
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(categoryLabel)
        addSubview(priceLabel)
        
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        nameLabel.frame = CGRect(x: 0, y: frame.width + 2, width: frame.width, height: 40)
        categoryLabel.frame = CGRect(x: 0, y: frame.width + 38, width: frame.width, height: 20)
        priceLabel.frame = CGRect(x: 0, y: frame.width + 56, width: frame.width, height: 20)
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
