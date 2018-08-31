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
        static var gambarBarang: UIImage?
        static var namaBarang = ""
        static var brand = ""
        static var qty = ""
        static var desc = ""
        static var kategori = ""
        static var url = ""
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
        static var provinsi = ""
        static var idKota = ""
        static var status = 0
    }
    
    struct varHarga {
        static var harga = ""
        static var status = 0
    }
    
    struct varDurasi {
        static var countdownText = ""
        static var countdownValue = 0.0
        static var batasWaktu = ""
        static var statusBatas = 0
        static var status = 0
    }
    
    fileprivate let inputCellId1Pre = "inputCellId1Pre"
    fileprivate let inputCellId2Pre = "inputCellId2Pre"
    fileprivate let inputCellId3Pre = "inputCellId3Pre"
    fileprivate let inputCellId4Pre = "inputCellId4Pre"
    fileprivate let inputCellId5Pre = "inputCellId5Pre"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("Post Barang")
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(InputCell1Pre.self, forCellWithReuseIdentifier: inputCellId1Pre)
        collectionView?.register(InputCell2Pre.self, forCellWithReuseIdentifier: inputCellId2Pre)
        collectionView?.register(InputCell3Pre.self, forCellWithReuseIdentifier: inputCellId3Pre)
        collectionView?.register(InputCell4Pre.self, forCellWithReuseIdentifier: inputCellId4Pre)
        collectionView?.register(InputCell5Pre.self, forCellWithReuseIdentifier: inputCellId5Pre)
        
        setupView()
         NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
    }
    
    @objc func loadList(){
        //load data here
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1Pre, for: indexPath) as! InputCell1Pre
            
            if varDetail.status != 0 {
                cell.BarangImageView.isHidden = false
                cell.labelNama.isHidden = false
                cell.labelBrand.isHidden = false
                cell.labelQty.isHidden = false
                cell.descText.isHidden = false
                cell.labelKategori.isHidden = false
                cell.deskripsi.isHidden = false
                
                cell.BarangImageView.image = varDetail.gambarBarang
                cell.labelNama.text = "Nama : " + varDetail.namaBarang
                cell.labelBrand.text = "Brand : " + varDetail.brand
                cell.labelQty.text = "Jumlah : " + varDetail.qty
                cell.descText.text = varDetail.desc
                cell.labelKategori.text = "Kategori : " + varDetail.kategori
                if varDetail.url != "" {
                    cell.labelUrl.isHidden = false
                    cell.labelUrl.text = "URL Referensi : " + varDetail.url
                }
                
            }else{
                cell.BarangImageView.isHidden = true
                cell.labelNama.isHidden = true
                cell.labelBrand.isHidden = true
                cell.labelQty.isHidden = true
                cell.descText.isHidden = true
                cell.labelKategori.isHidden = true
                cell.labelUrl.isHidden = true
                cell.deskripsi.isHidden = true
                
            }
            
            return cell
            
        }else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId2Pre, for: indexPath) as! InputCell2Pre
            
            if varKarateristik.status != 0 {
                cell.labelBerat.isHidden = false
                
                cell.labelBerat.text = "Berat : " + varKarateristik.berat
            }else{
                cell.labelBerat.isHidden = true
            }
            
            return cell
            
        }else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId3Pre, for: indexPath) as! InputCell3Pre
            
            if varNegara.status != 0 {
                cell.labelNegara.isHidden = false
                cell.LabelProvinsi.isHidden = false
                cell.LabelKota.isHidden = false
                cell.LabelDeadline.isHidden = false
                
                cell.labelNegara.text = "Negara Pembelian : " + varNegara.negara
                cell.LabelProvinsi.text = "Provinsi Pengiriman : " + varNegara.provinsi
                cell.LabelKota.text = "Kota Pengiriman : " + varNegara.kota
                cell.LabelDeadline.text = "Tanggal Pulang : " + varNegara.deadline
            }else{
                cell.labelNegara.isHidden = true
                cell.LabelProvinsi.isHidden = true
                cell.LabelKota.isHidden = true
                cell.LabelDeadline.isHidden = true
            }
            
            return cell
            
        }else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId4Pre, for: indexPath) as! InputCell4Pre
            
            if varHarga.status != 0 {
                cell.labelHarga.isHidden = false
                cell.labelHarga.text = "Harga Barang : " + varHarga.harga

            }else{
                cell.labelHarga.isHidden = true
                
            }
            
            return cell
            
        }else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId5Pre, for: indexPath) as! InputCell5Pre
            
            if varDurasi.status != 0 {
                if varDurasi.statusBatas != 0{
                    cell.labelHarga.isHidden = false
                    cell.labelCountdown.isHidden = false
                    cell.labelHarga.text = "Durasi : Ya"
                    cell.labelCountdown.text = "Batas Waktu : " + varDurasi.countdownText
                }else{
                    
                    cell.labelCountdown.isHidden = true
                    cell.labelHarga.isHidden = false
                    cell.labelHarga.text = "Durasi : Tidak" 
                }
            }else{
                cell.labelCountdown.isHidden = true
                cell.labelHarga.isHidden = true
            }
            
            return cell
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1Pre, for: indexPath) as! InputCell1Pre
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //mengatur height postbarang dan preorder karena salah
        
        if TambahViewController.varTambah.statusTambah == "preorder"{
            print("height preorer")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
            if indexPath.row == 0 && PostPreorder.varDetail.status != 0 {
                
                return CGSize(width: view.frame.width, height: 350)
            }else if indexPath.row == 1 && PostPreorder.varKarateristik.status != 0 {
                
                return CGSize(width: view.frame.width, height: 120)
            }else if indexPath.row == 2 && PostPreorder.varNegara.status != 0 {
                
                return CGSize(width: view.frame.width, height: 160)
            }else if indexPath.row == 3 && PostPreorder.varHarga.status != 0 {
                
                return CGSize(width: view.frame.width, height: 120)
            }else if indexPath.row == 4 && PostPreorder.varHarga.status != 0 {
                
                return CGSize(width: view.frame.width, height: 120)
            }
        }else if TambahViewController.varTambah.statusTambah == "barang"{
            print("height barang")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
            
            if indexPath.row == 0 && PostBarang.varDetail.status != 0 {
                
                return CGSize(width: view.frame.width, height: 350)
            }else if indexPath.row == 1 && PostBarang.varKarateristik.status != 0 {
                
                return CGSize(width: view.frame.width, height: 120)
            }else if indexPath.row == 2 && PostBarang.varNegara.status != 0 {
                
                return CGSize(width: view.frame.width, height: 140)
            }else if indexPath.row == 3 && PostBarang.varHarga.status != 0 {
            
                return CGSize(width: view.frame.width, height: 100)
            }else if indexPath.row == 4{
                
                return CGSize(width: view.frame.width, height: 0)
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
            }else if indexPath.row == 4{
                self.showDurasiBarang()
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
        
        if(varDetail.status != 1 && varKarateristik.status != 1 && varNegara.status != 1 && varHarga.status != 1){
            let alert = UIAlertController(title: "Message", message: "Data Harus Terisi Semua", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else{
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                
                print(emailNow)
                
                let parameters: Parameters = ["email": emailNow,"name": varDetail.namaBarang, "description":varDetail.desc, "category":varDetail.kategori, "country": varNegara.negara,"kota": varNegara.kota, "price":varHarga.harga, "qty": varDetail.qty, "berat":varKarateristik.berat, "deadline":varNegara.deadline ,"url": varDetail.url,"idKota":varNegara.idKota, "provinsi":varNegara.provinsi, "batasWaktu":varDurasi.batasWaktu, "countdownText":varDurasi.countdownText,"countdownValue":varDurasi.countdownValue,"brand":varDetail.brand ,"action" : "insert","action2" : "tidak"]
                
                Alamofire.request("http://titipanku.xyz/api/PostPreorder.php",method: .post, parameters: parameters).responseSwiftyJSON { dataResponse in
                    
                    //mencetak JSON response
                    if let json = dataResponse.value {
                        // print("JSON: \(json)")
                    }
                    
                    //mengambil json
                    let json = JSON(dataResponse.value)
                    
                    let cekSukses = json["success"].intValue
                    let pesan = json["message"].stringValue
                    print(varDurasi.countdownText)
                    if cekSukses != 1 {
                        let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                    }else{
                        
                        let imgData = UIImageJPEGRepresentation(varDetail.gambarBarang!, 0.1)!
                        
                        let parameters = ["email": emailNow,"name": "Frank","action" : "insert","action2" : "upload"]
                        //userfile adalah parameter post untuk file yg ingin di upload
                        Alamofire.upload(multipartFormData: { multipartFormData in
                            multipartFormData.append(imgData, withName: "userfile",fileName: "file.jpg", mimeType: "image/jpg")
                            for (key, value) in parameters {
                                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                            }
                        },
                                         to:"http://titipanku.xyz/api/PostPreorder.php")
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
                        
                        
                        // alert
                        let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            let appDetailController = TambahViewController()
                            appDetailController.handleBack()
                            self.handleBack()
                        }))
                        
                        self.present(alert, animated: true)
                        
                        
                        PostPreorder.varDetail.gambarBarang = nil
                        PostPreorder.varDetail.namaBarang = ""
                        PostPreorder.varDetail.brand = ""
                        PostPreorder.varDetail.desc = ""
                        PostPreorder.varDetail.qty = ""
                        PostPreorder.varDetail.kategori = ""
                        PostPreorder.varDetail.url = ""
                        PostPreorder.varDetail.status = 0
                        
                        PostPreorder.varKarateristik.berat = ""
                        PostPreorder.varKarateristik.status = 0
                        
                        PostPreorder.varNegara.negara = ""
                        PostPreorder.varNegara.kota = ""
                        PostPreorder.varNegara.idKota = ""
                        PostPreorder.varNegara.provinsi = ""
                        PostPreorder.varNegara.deadline = ""
                        PostPreorder.varNegara.status = 0
                        
                        PostPreorder.varHarga.harga = ""
                        PostPreorder.varHarga.status = 0
                        
                        PostPreorder.varDurasi.batasWaktu = ""
                        PostPreorder.varDurasi.countdownText = ""
                        PostPreorder.varDurasi.countdownValue = 0.0
                        PostPreorder.varDurasi.status = 0
                    }
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
        postButton.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
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
    
    @objc func showDurasiBarang(){
        let addDetail = AddDurasiPreorder()
        
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
    
    //lazy var supaya mau akses self
    lazy var BarangImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "coba")
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let labelNama : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Nama barang "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let labelBrand : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Brand "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let labelQty : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "qty barang "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let deskripsi : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Deskripsi : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let descText : UITextView = {
        let textField = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.text = "desc"
        //textField.layer.borderWidth = 1
        //textField.layer.cornerRadius = 3
        //textField.layer.borderColor =  UIColor.gray.cgColor
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.inputView = UIView();
        return textField
    }()
    
    let labelKategori : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "kategori barang "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let labelUrl : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Url Barang"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        addSubview(imageView)
        addSubview(angkaImg)
        addSubview(BarangImageView)
        addSubview(labelNama)
        addSubview(labelQty)
        addSubview(deskripsi)
        addSubview(descText)
        addSubview(labelKategori)
        addSubview(labelUrl)
        addSubview(labelBrand)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        addConstraintsWithFormat("H:|-80-[v0(100)]|", views: BarangImageView)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelNama)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelBrand)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelQty)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelKategori)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelUrl)
        addConstraintsWithFormat("H:|-80-[v0]-5-[v1]-30-|", views: deskripsi,descText)
        
        addConstraintsWithFormat("V:|[v0(50)]", views: angkaImg)
        addConstraintsWithFormat("V:|-15-[v0]", views: labelA)
        addConstraintsWithFormat("V:|[v0(50)]-5-[v3(100)]-5-[v1]-5-[v6]-5-[v2]-5-[v4]-5-[v5]", views: imageView,labelNama,labelKategori,BarangImageView,labelUrl,deskripsi,labelQty,labelBrand)
        addConstraintsWithFormat("V:|-243-[v0]|", views: descText)
        
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
    
    let labelBerat : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Berat Barang  "
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
        addSubview(imageView)
        addSubview(angkaImg)
        addSubview(labelBerat)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelBerat)
        addConstraintsWithFormat("H:|-30-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-10-[v0(50)]", views: angkaImg)
        addConstraintsWithFormat("V:|-25-[v0]", views: labelA)
        addConstraintsWithFormat("V:|-10-[v0(50)]-5-[v1]|", views: imageView,labelBerat)
        addConstraintsWithFormat("V:|[v0(1)]|", views: dividerLineView)
        
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
    
    let labelNegara : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Negara Barang  "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let LabelProvinsi : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Provinsi Barang  "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let LabelKota : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Kota Barang  "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let LabelDeadline : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Tanggal Kembali"
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
        addSubview(imageView)
        addSubview(angkaImg)
        addSubview(labelNegara)
        addSubview(LabelProvinsi)
        addSubview(LabelKota)
        addSubview(LabelDeadline)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelNegara)
        addConstraintsWithFormat("H:|-80-[v0]|", views: LabelProvinsi)
        addConstraintsWithFormat("H:|-80-[v0]|", views: LabelKota)
        addConstraintsWithFormat("H:|-80-[v0]|", views: LabelDeadline)
        addConstraintsWithFormat("H:|-30-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-10-[v0(50)]", views: angkaImg)
        addConstraintsWithFormat("V:|-25-[v0]", views: labelA)
        addConstraintsWithFormat("V:|-10-[v0(50)]-5-[v1]-5-[v3]-5-[v2]-5-[v4]|", views: imageView,labelNegara,LabelKota,LabelProvinsi,LabelDeadline)
        addConstraintsWithFormat("V:|[v0(1)]|", views: dividerLineView)
        
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
    
    let labelHarga : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Harga Barang  "
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
        addSubview(imageView)
        addSubview(angkaImg)
        addSubview(labelHarga)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelHarga)
        addConstraintsWithFormat("H:|-30-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-10-[v0(50)]", views: angkaImg)
        addConstraintsWithFormat("V:|-25-[v0]", views: labelA)
        addConstraintsWithFormat("V:|-10-[v0(50)]-5-[v1]|", views: imageView,labelHarga)
        addConstraintsWithFormat("V:|[v0(1)]|", views: dividerLineView)
        
    }
    
}


class InputCell5Pre: BaseCell {
    
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
        label.text = "Durasi "
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    let labelHarga : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Durasi :   "
        label.font = UIFont.systemFont(ofSize: 15)
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
    
    let labelCountdown : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "countdown Barang  "
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
        addSubview(imageView)
        addSubview(labelHarga)
        addSubview(angkaImg)
        addSubview(labelCountdown)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelHarga)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelCountdown)
        addConstraintsWithFormat("H:|-30-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-10-[v0(50)]", views: angkaImg)
        addConstraintsWithFormat("V:|-25-[v0]", views: labelA)
        addConstraintsWithFormat("V:|-10-[v0(50)]-5-[v1]-5-[v2]|", views: imageView,labelHarga,labelCountdown)
        addConstraintsWithFormat("V:|[v0(1)]|", views: dividerLineView)
        
    }
    
}
