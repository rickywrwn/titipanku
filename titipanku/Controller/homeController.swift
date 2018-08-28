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
import SKActivityIndicatorView

class homeController: UICollectionViewController,UICollectionViewDelegateFlowLayout{
    
    fileprivate let cellId = "cellId"
    fileprivate let preorderCellId = "preorderCellId"
    fileprivate let flashCellId = "flashCellId"
    fileprivate let headerId = "headerId"
    
    var featuredApps: FeaturedApps?
    var appCategories: [AppCategory]?
    
    var cekLogged : Bool = UserDefaults.standard.bool(forKey: "logged")
    
    @objc func tambahBtn() {
        print("It Works")
        let tambahCont = TambahViewController()
        present(tambahCont, animated: true, completion: {
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        //collectionView?.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UserController.emailUser.status = "sendiri"
        if  cekLogged == true{
            print("masuk home")
        }else {
            print("out home")
            handleBack()
        }
        navigationItem.title = "Home"
        let rightButton = UIBarButtonItem(title: "Tambah", style: .plain, target: self, action: #selector(self.tambahBtn))
        self.navigationItem.rightBarButtonItem = rightButton
       
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        AppCategory.fetchFeaturedApps { (featuredApps) -> () in
            self.featuredApps = featuredApps
            self.appCategories = featuredApps.categories
            SKActivityIndicator.dismiss()
            self.collectionView?.reloadData()
        }
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: preorderCellId)
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: flashCellId)
        collectionView?.register(Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        NotificationCenter.default.addObserver(self, selector: #selector(showMoreRequest), name: NSNotification.Name(rawValue: "showMoreRequest"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMorePreorder), name: NSNotification.Name(rawValue: "showMorePreorder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMorePreorderBerdurasi), name: NSNotification.Name(rawValue: "showMorePreorderBerdurasi"), object: nil)
        
        setupView()
    }
    
    @objc func showMoreRequest() {
        print("pencet Request")
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let appDetailController = AllRequest(collectionViewLayout: layout)
        //navigationController?.pushViewController(appDetailController, animated: true)
        present(appDetailController, animated: true, completion: {
        })
    }
    @objc func showMorePreorder() {
        print("pencet Preorder ")
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let appDetailController = AllPreorder(collectionViewLayout: layout)
        present(appDetailController, animated: true, completion: {
        })
        
    }
    @objc func showMorePreorderBerdurasi() {
        print("pencet Durasi")
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let appDetailController = AllPreorderBerdurasi(collectionViewLayout: layout)
        present(appDetailController, animated: true, completion: {
        })
        
    }
    
    func showAppDetailForApp(_ app: App) {
        print("pencet")
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let appDetailController = barangDetailController(collectionViewLayout: layout)
        appDetailController.app = app
        //navigationController?.pushViewController(appDetailController, animated: true)
        present(appDetailController, animated: true, completion: {
        })
    }
    
    func showPreorderDetailForApp(_ app: App) {
        print("pencet preorder")
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let appDetailController = PreorderDetail(collectionViewLayout: layout)
        appDetailController.app = app
        present(appDetailController, animated: true, completion: {
        })
    }
    
    func showFlashSaleDetailForApp(_ app: App) {
        print("pencet preorder 2 gan")
        let layout = UICollectionViewFlowLayout()
        let appDetailController = PreorderDetail(collectionViewLayout: layout)
        appDetailController.app = app
        present(appDetailController, animated: true, completion: {
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell: CategoryCell
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
            cell.appCategory = appCategories?[indexPath.item]
            cell.btnMore.setTitle(String("More"), for: .normal)
            cell.btnMore.addTarget(self, action: #selector(showMoreRequest), for: UIControlEvents.touchDown)
            cell.homeController = self
            
            return cell
        }else if indexPath.item == 1 {
            let cell: CategoryCell
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: preorderCellId, for: indexPath) as! CategoryCell
            cell.appCategory = appCategories?[indexPath.item]
            cell.btnMore.setTitle(String("More"), for: .normal)
            cell.btnMore.addTarget(self, action: #selector(showMorePreorder), for: UIControlEvents.touchDown)
            cell.homeController = self
            
            return cell
        }else if indexPath.item == 2 {
            let cell: CategoryCell
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: flashCellId, for: indexPath) as! CategoryCell
            cell.appCategory = appCategories?[indexPath.item]
            cell.homeController = self
            cell.btnMore.setTitle(String("More"), for: .normal)
            cell.btnMore.addTarget(self, action: #selector(showMorePreorderBerdurasi), for: UIControlEvents.touchDown)
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












