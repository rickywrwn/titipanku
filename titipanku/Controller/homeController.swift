//
//  homeController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 28/03/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

//struct postPreorder: Decodable {
//    let id: Int
//    let name: String
//    let category: String
//    let country: String
//    let price: Int
//    let imageName: String
//    let status : String
//
//}

class homeController: UICollectionViewController,UICollectionViewDelegateFlowLayout{
    
    fileprivate let cellId = "cellId"
    fileprivate let preorderCellId = "preorderCellId"
    fileprivate let headerId = "headerId"
    
//    var postPreorders = [postPreorder]()
    
    var featuredApps: FeaturedApps?
    var appCategories: [AppCategory]?
    
    var cekLogged : Bool = UserDefaults.standard.bool(forKey: "logged")
    
    @objc func tambahBtn() {
        
        print("It Works")
        let tambahCont = TambahViewController()
        present(tambahCont, animated: true, completion: {
            
        })

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if  cekLogged == true{
            print("masuk home")
        }else {
            print("out home")
            handleBack()
        }
        navigationItem.title = "Home"
        let rightButton = UIBarButtonItem(title: "Tambah", style: .plain, target: self, action: #selector(self.tambahBtn))
        
        self.navigationItem.rightBarButtonItem = rightButton
        AppCategory.fetchFeaturedApps { (featuredApps) -> () in
            self.featuredApps = featuredApps
            self.appCategories = featuredApps.categories
            self.collectionView?.reloadData()
        }
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: preorderCellId)
        collectionView?.register(Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        setupView()
    }
    
    func showAppDetailForApp(_ app: App) {
        print("pencet")
        let layout = UICollectionViewFlowLayout()
        let appDetailController = barangDetailController(collectionViewLayout: layout)
        appDetailController.app = app
        navigationController?.pushViewController(appDetailController, animated: true)
        
    }
    
    func showPreorderDetailForApp(_ app: App) {
        print("pencet")
        let layout = UICollectionViewFlowLayout()
        let appDetailController = PreorderDetail(collectionViewLayout: layout)
        appDetailController.app = app
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.item == 0 {
            let cell: CategoryCell
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
            cell.appCategory = appCategories?[indexPath.item]
            cell.homeController = self
            
            return cell
        }else if indexPath.item == 1 {
            let cell: CategoryCell
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: preorderCellId, for: indexPath) as! CategoryCell
            cell.appCategory = appCategories?[indexPath.item]
            cell.homeController = self
            
            return cell
        }
        
        let cell: CategoryCell
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
       
        
        return cell
    }
    
    //jangan lupa diganti 7
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = appCategories?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! Header
        
        header.appCategory = featuredApps?.bannerCategory
        
        return header
    }

    
    @objc func handleBack(){
        let homeCont = loginController()
        print("back from home")
        //dismiss(animated: true, completion: nil)
        present(homeCont, animated: true, completion: {
            
        })
    }
    
    
    //tampilan
    
    
    func setupView(){
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
}


class Header: CategoryCell {
    
    let cellId = "bannerCellId"
    
    override func setupViews() {
        appsCollectionView.dataSource = self
        appsCollectionView.delegate = self
        
        appsCollectionView.register(BannerCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(appsCollectionView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appsCollectionView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appsCollectionView]))
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AppCell
        cell.app = appCategory?.apps?[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 2 + 50, height: frame.height)
    }
    
    fileprivate class BannerCell: AppCell {
        fileprivate override func setupViews() {
            imageView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
            imageView.layer.borderWidth = 0.5
            imageView.layer.cornerRadius = 0
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
        }
    }
    
}












