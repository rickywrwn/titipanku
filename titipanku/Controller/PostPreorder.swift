//
//  PostPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 31/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON

class PostPreorder: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    struct varDetail {
        static var namaBarang = ""
        static var qty = ""
        static var desc = ""
        static var kategori = ""
        static var status = 0
    }
    
    struct varKarateristik {
        static var berat = ""
        static var status = 0
    }
    
    struct varNegara {
        static var negara = ""
        static var kota = ""
        static var deadline = ""
        static var status = 0
    }
    
    struct varHarga {
        static var harga = ""
        static var countdownText = ""
        static var countdownValue = ""
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
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(InputCell1Pre.self, forCellWithReuseIdentifier: inputCellId1)
        collectionView?.register(InputCell2Pre.self, forCellWithReuseIdentifier: inputCellId2)
        collectionView?.register(InputCell3Pre.self, forCellWithReuseIdentifier: inputCellId3)
        collectionView?.register(InputCell4Pre.self, forCellWithReuseIdentifier: inputCellId4)
        
        setupView()
         NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
    }
    
    @objc func loadList(){
        //load data here
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1, for: indexPath) as! InputCell1Pre
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.gray.cgColor
            border.frame = CGRect(x: 40, y: cell.frame.size.height - width, width:  cell.frame.size.width , height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            return cell
            
        }else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId2, for: indexPath) as! InputCell2Pre
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.gray.cgColor
            border.frame = CGRect(x: 40, y: cell.frame.size.height - width, width:  cell.frame.size.width , height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            
            return cell
            
        }else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId3, for: indexPath) as! InputCell3Pre
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.gray.cgColor
            border.frame = CGRect(x: 40, y: cell.frame.size.height - width, width:  cell.frame.size.width , height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            return cell
            
        }else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId4, for: indexPath) as! InputCell4Pre
            let border = CALayer()
            let width = CGFloat(1.0)
            border.borderColor = UIColor.gray.cgColor
            border.frame = CGRect(x: 40, y: cell.frame.size.height - width, width:  cell.frame.size.width , height: cell.frame.size.height)
            
            border.borderWidth = width
            cell.layer.addSublayer(border)
            cell.layer.masksToBounds = true
            return cell
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1, for: indexPath) as! InputCell1Pre
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //mengatur height postbarang dan preorder karena salah
        
        if TambahViewController.varTambah.statusTambah == "preorder"{
            print("height preorer")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
            return CGSize(width: view.frame.width, height: 100)
        }else if TambahViewController.varTambah.statusTambah == "barang"{
            print("height barang")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
            
            if indexPath.row == 0 && PostBarang.varDetail.status != 0 {
                
                return CGSize(width: view.frame.width, height: 300)
            }else if indexPath.row == 1 && PostBarang.varKarateristik.status != 0 {
                
                return CGSize(width: view.frame.width, height: 200)
            }else if indexPath.row == 2 && PostBarang.varNegara.status != 0 {
                
                return CGSize(width: view.frame.width, height: 200)
            }else if indexPath.row == 3 && PostBarang.varHarga.status != 0 {
                
                return CGSize(width: view.frame.width, height: 100)
            }
            
        }
        print("atur height")
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("Num: \(indexPath.row)")
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
        button.setTitle("Post Titipan Berdurasi", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor.blue
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePostBarang), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    @objc func handlePostBarang(){
        
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            print(emailNow)
            
            let parameters: Parameters = ["email": emailNow,"name": varDetail.namaBarang, "description":varDetail.desc, "category":varDetail.kategori, "country": varNegara.negara,"kota": varNegara.kota, "price":varHarga.harga, "qty": varDetail.qty, "berat":varKarateristik.berat, "deadline":varNegara.deadline ,"action" : "insert"]
            
            Alamofire.request("http://localhost/titipanku/PostPreorder.php",method: .post, parameters: parameters).responseSwiftyJSON { dataResponse in
                
                //mencetak JSON response
                if let json = dataResponse.value {
                    print("JSON: \(json)")
                }
                
                //mengambil json
                let json = JSON(dataResponse.value)
                
                let cekSukses = json["success"].intValue
                let pesan = json["message"].stringValue
                
                if cekSukses != 1 {
                    let alert = UIAlertController(title: "Message", message: "gagal", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        let appDetailController = TambahViewController()
                        appDetailController.handleBack()
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
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -110).isActive = true
        
        
        view.addSubview(postButton)
        postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor ).isActive = true
        postButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        //postButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        postButton.topAnchor.constraint(greaterThanOrEqualTo: (collectionView?.bottomAnchor)!, constant: 50).isActive = true
        
    }
    
    @objc func showAddDetail(){
        let addDetail = AddDetailPreorder()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showAddKarateristik(){
        let addDetail = AddKarateristikPreorder()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showNegaraBarang(){
        let addDetail = AddNegaraPreorder()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showHargaBarang(){
        let addDetail = AddHargaPreorder()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
}


class InputCell1Pre: BaseCell {
    
    let angkaImg: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "satu")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Detail Barang  "
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "next")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        addSubview(imageView)
        addSubview(angkaImg)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        addConstraintsWithFormat("V:|-30-[v0(50)]|", views: imageView)
        addConstraintsWithFormat("V:|-25-[v0(50)]|", views: angkaImg)
        
    }
    
}

class InputCell2Pre: BaseCell {
    
    let angkaImg: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "dua")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Karateristik Barang  "
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "next")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        addSubview(imageView)
        addSubview(angkaImg)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        addConstraintsWithFormat("V:|-30-[v0(50)]|", views: imageView)
        addConstraintsWithFormat("V:|-25-[v0(50)]|", views: angkaImg)
        
    }
    
}

class InputCell3Pre: BaseCell {
    
    let angkaImg: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "tiga")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Negara Pembelian"
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "next")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        addSubview(imageView)
        addSubview(angkaImg)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        addConstraintsWithFormat("V:|-30-[v0(50)]|", views: imageView)
        addConstraintsWithFormat("V:|-25-[v0(50)]|", views: angkaImg)
        
    }
    
}

class InputCell4Pre: BaseCell {
    
    let angkaImg: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "empat")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Harga "
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "next")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        addSubview(imageView)
        addSubview(angkaImg)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        addConstraintsWithFormat("V:|-30-[v0(50)]|", views: imageView)
        addConstraintsWithFormat("V:|-25-[v0(50)]|", views: angkaImg)
        
    }
    
}
