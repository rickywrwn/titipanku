//
//  PostBarang.swift
//  titipanku
//
//  Created by Ricky Wirawan on 29/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PostBarang: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    struct varDetail {
        static var namaBarang = ""
        static var qty = ""
        static var desc = ""
        static var kategori = ""
        static var status = 0
    }
    
    struct varKarateristik {
        static var ukuran = ""
        static var berat = ""
        static var status = 0
    }
    
    struct varNegara {
        static var negara = ""
        static var kota = ""
        static var status = 0
    }
    
    struct varHarga {
        static var harga = ""
        static var status = 0
    }
    
    fileprivate let inputCellId1 = "inputCellId1"
    fileprivate let inputCellId2 = "inputCellId2"
    fileprivate let inputCellId3 = "inputCellId3"
    fileprivate let inputCellId4 = "inputCellId4"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("Post Barang")
        setupView()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(InputCell1.self, forCellWithReuseIdentifier: inputCellId1)
        collectionView?.register(InputCell2.self, forCellWithReuseIdentifier: inputCellId2)
        collectionView?.register(InputCell3.self, forCellWithReuseIdentifier: inputCellId3)
        collectionView?.register(InputCell4.self, forCellWithReuseIdentifier: inputCellId4)
        
        print(varDetail.namaBarang.self)
        
    }
   
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1, for: indexPath) as! InputCell1
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.gray.cgColor
            border.frame = CGRect(x: 40, y: cell.frame.size.height - width, width:  cell.frame.size.width , height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            return cell
            
        }else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId2, for: indexPath) as! InputCell2
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.gray.cgColor
            border.frame = CGRect(x: 40, y: cell.frame.size.height - width, width:  cell.frame.size.width , height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            
            return cell
            
        }else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId3, for: indexPath) as! InputCell3
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.gray.cgColor
            border.frame = CGRect(x: 40, y: cell.frame.size.height - width, width:  cell.frame.size.width , height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            return cell
            
        }else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId4, for: indexPath) as! InputCell4
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.gray.cgColor
            border.frame = CGRect(x: 40, y: cell.frame.size.height - width, width:  cell.frame.size.width , height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            return cell
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1, for: indexPath) as! InputCell1
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.gray.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cell?.layer.backgroundColor = UIColor.white.cgColor
            if indexPath.row == 0{
                self.showAddDetail()
            }else if indexPath.row == 1{
                self.showAddKarateristik()
            }else if indexPath.row == 2{
                self.showNegaraBarang()
            }else if indexPath.row == 3{
                self.showHargaBarang()
            }
        }
        
    }
    
    let postButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Post Barang", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePostBarang), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    @objc func handlePostBarang(){
        
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            print(emailNow)
            
            let parameters: Parameters = ["email": emailNow,"name": varDetail.namaBarang, "description":varDetail.desc, "category":varDetail.kategori, "country": varNegara.negara, "price":varHarga.harga, "qty": varDetail.qty, "ukuran": varKarateristik.ukuran, "berat":varKarateristik.berat, "kotaKirim":varNegara.kota ,"action" : "insert"]
            
            Alamofire.request("http://localhost/titipanku/PostBarang.php",method: .get, parameters: parameters).responseSwiftyJSON { dataResponse in
                
                //mencetak JSON response
                if let json = dataResponse.value {
                    print("JSON: \(json)")
                }
                
                //mengambil json
                let json = JSON(dataResponse.value)
                print(json)
                let cekSukses = json["success"].intValue
                let pesan = json["message"].stringValue
                
                if cekSukses != 1 {
                    let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.handleBack()
                    }))
                    
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
    
    @objc private func handleBack(){
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupView(){
        view.backgroundColor = .white
        let screenWidth = UIScreen.main.bounds.width
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        collectionView?.heightAnchor.constraint(equalToConstant: 200).isActive = true
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -155).isActive = true
        
        
        //PostButton
        view.addSubview(postButton)
        postButton.centerXAnchor.constraint(equalTo: (collectionView?.centerXAnchor)! ).isActive = true
        postButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    @objc func showAddDetail(){
        let addDetail = AddDetailBarang()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)

    }
    
    @objc func showAddKarateristik(){
        let addDetail = AddKarateristikBarang()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showNegaraBarang(){
        let addDetail = AddNegaraBarang()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showHargaBarang(){
        let addDetail = AddHargaBarang()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
}


class InputCell1: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Detail Barang  "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        
        addConstraintsWithFormat("H:|-50-[v0]-5-|", views: labelA) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        
    }
    
}

class InputCell2: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Karateristik Barang  "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        
        addConstraintsWithFormat("H:|-50-[v0]-5-|", views: labelA) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        
    }
    
}

class InputCell3: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Negara Pembelian"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        
        addConstraintsWithFormat("H:|-50-[v0]-5-|", views: labelA) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        
    }
    
}

class InputCell4: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Harga "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        
        addConstraintsWithFormat("H:|-50-[v0]-5-|", views: labelA) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        
    }
    
}
