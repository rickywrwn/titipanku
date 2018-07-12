//
//  OfferController3.swift
//  titipanku
//
//  Created by Ricky Wirawan on 12/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit

class OfferController3 :  UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var app: App? {
        didSet {
            
            if app?.Screenshots != nil {
                return
            }
            
            if let id = app?.id {
                let urlString = "http://titipanku.xyz/api/DetailBarang.php?id=\(id)"
                
                URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                    
                    guard let data = data else { return }
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    do {
                        
                        let decoder = JSONDecoder()
                        let appDetail = try decoder.decode(App.self, from: data)
                        //print(appDetail)
                        self.app = appDetail
                        
                        
                    } catch let err {
                        print(err)
                    }
                    
                    
                }).resume()
            }
        }
    }
    
    fileprivate let CellId = "CellId"
    fileprivate let OfferNextCellId = "OfferNextCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Bantu Belikan 3"
        collectionView?.backgroundColor = UIColor.white
        print("Bantu belikan Barang Loaded")
        
        collectionView?.register(AppDetailCell3.self, forCellWithReuseIdentifier: CellId)
        collectionView?.register(OfferNextCell3.self, forCellWithReuseIdentifier: OfferNextCellId)
        
    }
    
    func showOffer(_ app: App) {
        print("pencet")
        let layout = UICollectionViewFlowLayout()
        let appDetailController = OfferController2(collectionViewLayout: layout)
        appDetailController.app = app
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId, for: indexPath) as! AppDetailCell3
            
            cell.nameLabel.text = app?.name
            
            
            cell.qtyLabel.text = "Jumlah Barang : " + (app?.qty)!
            cell.ukuranLabel.text = "Ukuran Barang : " + (app?.ukuran)!
            cell.beratLabel.text = "Berat Barang : " + (app?.berat)!
            return cell
        }else if indexPath.row == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OfferNextCellId, for: indexPath) as! OfferNextCell3
            
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId, for: indexPath) as! AppDetailCell3
        
        cell.nameLabel.text = app?.name
        
        
        cell.qtyLabel.text = "Jumlah Barang : " + (app?.qty)!
        cell.ukuranLabel.text = "Ukuran Barang : " + (app?.ukuran)!
        cell.beratLabel.text = "Berat Barang : " + (app?.berat)!
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 300)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.gray.cgColor
        
        //self.showOffer(self.app!)
        
        
    }
    
}


class AppDetailCell3: BaseCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "harga"
        label.font = UIFont.systemFont(ofSize: 21)
        return label
    }()
    
    let qtyLabel: UILabel = {
        let label = UILabel()
        label.text = "qty"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let ukuranLabel: UILabel = {
        let label = UILabel()
        label.text = "ukuran"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let beratLabel: UILabel = {
        let label = UILabel()
        label.text = "berat"
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
        
        addSubview(nameLabel)
        addSubview(qtyLabel)
        addSubview(ukuranLabel)
        addSubview(beratLabel)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: nameLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: qtyLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: ukuranLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: beratLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-15-[v0]-5-[v1]-5-[v2]-5-[v3]-25-[v4(1)]|", views: nameLabel ,qtyLabel,ukuranLabel,beratLabel,dividerLineView )
        
    }
    
}

class OfferNextCell3: BaseCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Berikutnya"
        label.font = UIFont.systemFont(ofSize: 21)
        return label
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-150-[v0(150)]-150-|", views: nameLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v0(50)][v1(1)]|", views: nameLabel,dividerLineView )
        
    }
    
}

