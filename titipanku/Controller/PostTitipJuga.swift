//
//  PostTitipJuga.swift
//  titipanku
//
//  Created by Ricky Wirawan on 12/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SKActivityIndicatorView

class PostTitipJuga: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    var app: App?
    var sizeDesc : Float = 0
    
    struct varDetail {
        static var gambarBarang: UIImage?
        static var namaBarang = ""
        static var qty = ""
        static var desc = ""
        static var kategori = ""
        static var url = ""
        static var status = 0
    }
    
    struct varKarateristik {
        static var ukuran = ""
        static var berat = ""
        static var status = 0
    }
    
    struct varNegara {
        static var negara = ""
        static var provinsi = ""
        static var kota = ""
        static var idKota = ""
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
    fileprivate let inputCellId5 = "inputCellId5"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print(app)
        print(sizeDesc)
        if let imageName = self.app?.ImageName {
            print("image name")
            print(imageName)
            Alamofire.request("http://titipanku.xyz/uploads/"+imageName).responseImage { response in
                //debugPrint(response)
                //let nama = self.app?.name
                //print("gambar : "+imageName)
                if let image = response.result.value {
                    //print("image downloaded: \(image)")
                   PostTitipJuga.varDetail.gambarBarang = image
                    self.collectionView?.reloadData()
                }
            }
        }
        PostTitipJuga.varDetail.namaBarang = (app?.name)!
        PostTitipJuga.varDetail.desc = (app?.description)!
        PostTitipJuga.varDetail.qty = (app?.qty)!
        PostTitipJuga.varDetail.kategori = (app?.category)!
        if app?.url != ""{
            PostTitipJuga.varDetail.url = (app?.url)!
        }else{
            PostTitipJuga.varDetail.url = "Tidak Ada"
        }
        PostTitipJuga.varDetail.status = 1
        
        PostTitipJuga.varKarateristik.ukuran = (app?.ukuran)!
        PostTitipJuga.varKarateristik.berat = (app?.berat)!
        PostTitipJuga.varKarateristik.status = 1
        
        PostTitipJuga.varNegara.negara = (app?.country)!
        PostTitipJuga.varNegara.kota = (app?.kotaKirim)!
        PostTitipJuga.varNegara.idKota = (app?.idKota)!
        PostTitipJuga.varNegara.provinsi = (app?.provinsi)!
        PostTitipJuga.varNegara.status = 1
        
        PostTitipJuga.varHarga.harga = (app?.price)!
        PostTitipJuga.varHarga.status = 1
        
        print("Post Barang")
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(InputCell1.self, forCellWithReuseIdentifier: inputCellId1)
        collectionView?.register(InputCell2.self, forCellWithReuseIdentifier: inputCellId2)
        collectionView?.register(InputCell3.self, forCellWithReuseIdentifier: inputCellId3)
        collectionView?.register(InputCell4.self, forCellWithReuseIdentifier: inputCellId4)
        collectionView?.register(InputCell5.self, forCellWithReuseIdentifier: inputCellId5)
        
        
        print(varDetail.namaBarang.self)
        
        setupView()
        //untuk melakukan reload collectionview dari controller lain
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadTitip"), object: nil)
        self.collectionView?.reloadData()
    }
    
    @objc func loadList(){
        //load data here
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1, for: indexPath) as! InputCell1
            
            if varDetail.status != 0 {
                cell.BarangImageView.isHidden = false
                cell.labelNama.isHidden = false
                cell.labelQty.isHidden = false
                cell.descText.isHidden = false
                cell.labelKategori.isHidden = false
                cell.deskripsi.isHidden = false
                
                cell.BarangImageView.image = varDetail.gambarBarang
                cell.labelNama.text = "Nama : " + varDetail.namaBarang
                cell.labelQty.text = "Jumlah : " + varDetail.qty
                cell.descText.text = varDetail.desc
                cell.labelKategori.text = "Kategori : " + varDetail.kategori
                if varDetail.url != "" {
                    cell.labelUrl.isHidden = false
                    cell.labelUrl.text = "URL Referensi : " + varDetail.url
                }
                
            }else{
//                cell.BarangImageView.isHidden = true
//                cell.labelNama.isHidden = true
//                cell.labelQty.isHidden = true
//                cell.descText.isHidden = true
//                cell.labelKategori.isHidden = true
//                cell.labelUrl.isHidden = true
//                cell.deskripsi.isHidden = true
            }
            
            return cell
            
        }else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId2, for: indexPath) as! InputCell2
            
            if varKarateristik.status != 0 {
                cell.labelUkuran.isHidden = false
                cell.labelBerat.isHidden = false
                
                cell.labelUkuran.text = "Ukuran : " + varKarateristik.ukuran
                cell.labelBerat.text = "Berat : " + varKarateristik.berat
            }else{
//                cell.labelUkuran.isHidden = true
//                cell.labelBerat.isHidden = true
            }
            
            return cell
            
        }else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId3, for: indexPath) as! InputCell3
            
            if varNegara.status != 0 {
                cell.labelNegara.isHidden = false
                cell.LabelProvinsi.isHidden = false
                cell.LabelKota.isHidden = false
                
                cell.labelNegara.text = "Negara Pembelian : " + varNegara.negara
                cell.LabelProvinsi.text = "Provinsi Pengiriman : " + varNegara.provinsi
                cell.LabelKota.text = "Kota Pengiriman : " + varNegara.kota
            }else{
//                cell.labelNegara.isHidden = true
//                cell.LabelProvinsi.isHidden = true
//                cell.LabelKota.isHidden = false
            }
            
            return cell
            
        }else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId4, for: indexPath) as! InputCell4
            
            if varHarga.status != 0 {
                cell.labelHarga.isHidden = false
                
                cell.labelHarga.text = "Harga Barang : " + varHarga.harga
            }else{
//                cell.labelHarga.isHidden = true
            }
            
            return cell
            
        }else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId5, for: indexPath) as! InputCell5
            
            
            return cell
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1, for: indexPath) as! InputCell1
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: view.frame.width, height: CGFloat(270+tinggiDesc))
        }else if indexPath.row == 1 {
            return CGSize(width: view.frame.width, height: 100)
        }else if indexPath.row == 2 {
            return CGSize(width: view.frame.width, height: 130)
        }else if indexPath.row == 3 {
            return CGSize(width: view.frame.width, height: 100)
        }
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
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor(hex: "#4373D8")
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePostBarang), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    @objc func handlePostBarang(){
        if(varDetail.status != 1 && varKarateristik.status != 1 && varNegara.status != 1 && varHarga.status != 1){
            let alert = UIAlertController(title: "Message", message: "Data Harus Terisi Semua", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else{
            
            SKActivityIndicator.show("Loading...")
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                print(emailNow)
                
                let parameter: Parameters = ["email": emailNow,"name": varDetail.namaBarang, "description":varDetail.desc, "category":varDetail.kategori, "country": varNegara.negara, "price":varHarga.harga, "url": varDetail.url,"qty": varDetail.qty, "ukuran": varKarateristik.ukuran, "berat":varKarateristik.berat, "kotaKirim":varNegara.kota , "idKota": varNegara.idKota ,"provinsi":varNegara.provinsi ,"action" : "insert","action2" : "tidak"]
                print(parameter)
                Alamofire.request("http://titipanku.xyz/api/PostBarang.php",method: .post, parameters: parameter).responseSwiftyJSON { dataResponse in
                    
                    //mencetak JON response
                    if let json = dataResponse.value {
                        
                        //mengambil json
                        print(json)
                        let cekSukses = json["success"].intValue
                        let pesan = json["message"].stringValue
                        print(cekSukses)
                        print(pesan)
                        if cekSukses != 1 {
                            let alert = UIAlertController(title: "gagal", message: pesan, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            self.present(alert, animated: true)
                        }else{
                            print("masuk")
                            let imgData = UIImageJPEGRepresentation(varDetail.gambarBarang!, 0.1)!
                            
                            let parameters = ["name": "Frank","action" : "insert","action2" : "upload"]
                            print(parameters)
                            //userfile adalah parameter post untuk file yg ingin di upload
                            Alamofire.upload(multipartFormData: { multipartFormData in
                                multipartFormData.append(imgData, withName: "userfile",fileName: "file.jpg", mimeType: "image/jpg")
                                for (key, value) in parameters {
                                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                                }
                            },
                                             to:"http://titipanku.xyz/api/PostBarang.php")
                            { (result) in
                                switch result {
                                case .success(let upload, _, _):
                                    
                                    upload.uploadProgress(closure: { (progress) in
                                        print("Upload Progress: \(progress.fractionCompleted)")
                                    })
                                    
                                    upload.responseJSON { response in
                                        print(response.result.value)
                                    }
                                    
                                case .failure(let encodingError):
                                    print(encodingError)
                                }
                            }
                            
                            let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                SKActivityIndicator.dismiss()
                                self.handleBack()
                            }))
                            
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
        
        PostTitipJuga.varDetail.namaBarang = ""
        PostTitipJuga.varDetail.desc = ""
        PostTitipJuga.varDetail.qty = ""
        PostTitipJuga.varDetail.kategori = ""
        PostTitipJuga.varDetail.url = ""
        PostTitipJuga.varDetail.status = 0
        
        PostTitipJuga.varKarateristik.ukuran = ""
        PostTitipJuga.varKarateristik.berat = ""
        PostTitipJuga.varKarateristik.status = 0
        
        PostTitipJuga.varNegara.negara = ""
        PostTitipJuga.varNegara.kota = ""
        PostTitipJuga.varNegara.idKota = ""
        PostTitipJuga.varNegara.provinsi = ""
        PostTitipJuga.varNegara.status = 0
        
        PostTitipJuga.varHarga.harga = ""
        PostTitipJuga.varHarga.status = 0
    }
    
    @objc private func handleBack(){
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    private func setupView(){
        
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
        navigationItem.title = "Titip Juga"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        collectionView?.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - 64))
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        view.backgroundColor = .white
        let screenWidth = UIScreen.main.bounds.width
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -110).isActive = true
        
        
        //PostButton
        view.addSubview(postButton)
        postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor ).isActive = true
        postButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
    }
    
    @objc func showAddDetail(){
        let addDetail = AddDetailTitip()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showAddKarateristik(){
        let addDetail = AddKarateristikTitip()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showNegaraBarang(){
        let addDetail = AddNegaraTitip()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showHargaBarang(){
        let addDetail = AddHargaTitip()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
}

