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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("Post Barang")
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(InputCell1.self, forCellWithReuseIdentifier: inputCellId1)
        collectionView?.register(InputCell2.self, forCellWithReuseIdentifier: inputCellId2)
        collectionView?.register(InputCell3.self, forCellWithReuseIdentifier: inputCellId3)
        collectionView?.register(InputCell4.self, forCellWithReuseIdentifier: inputCellId4)
        

        print(varDetail.namaBarang.self)
        
        setupView()
        //untuk melakukan reload collectionview di controller lain
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
        
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
                cell.labelUrl.isHidden = false
                
                cell.BarangImageView.image = varDetail.gambarBarang
                cell.labelNama.text = "Nama : " + varDetail.namaBarang
                cell.labelQty.text = "Jumlah : " + varDetail.qty
                cell.descText.text = varDetail.desc
                cell.labelKategori.text = "Kategori : " + varDetail.kategori
                cell.labelUrl.text = "URL Referensi : " + varDetail.url
                
            }else{
                cell.BarangImageView.isHidden = true
                cell.labelNama.isHidden = true
                cell.labelQty.isHidden = true
                cell.descText.isHidden = true
                cell.labelKategori.isHidden = true
                cell.labelUrl.isHidden = true
                
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
                cell.labelUkuran.isHidden = true
                cell.labelBerat.isHidden = true
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
                cell.labelNegara.isHidden = true
                cell.LabelProvinsi.isHidden = true
                cell.LabelKota.isHidden = false
            }
            
            return cell
            
        }else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId4, for: indexPath) as! InputCell4
           
            if varHarga.status != 0 {
                cell.labelHarga.isHidden = false
                
                cell.labelHarga.text = "Harga Barang : " + varHarga.harga
            }else{
                cell.labelHarga.isHidden = true
            }
            
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
            
            let parameter: Parameters = ["email": emailNow,"name": varDetail.namaBarang, "description":varDetail.desc, "category":varDetail.kategori, "country": varNegara.negara, "price":varHarga.harga, "url": varDetail.url,"qty": varDetail.qty, "ukuran": varKarateristik.ukuran, "berat":varKarateristik.berat, "kotaKirim":varNegara.kota , "idKota": varNegara.idKota ,"provinsi":varNegara.provinsi ,"action" : "insert","action2" : "tidak"]

            Alamofire.request("http://titipanku.xyz/api/PostBarang.php",method: .post, parameters: parameter).responseSwiftyJSON { dataResponse in

                //mencetak JON response
                if let json = dataResponse.value {
                    
                    //mengambil json
                    print(json)
                    let cekSukses = json["success"].intValue
                    let pesan = json["message"].stringValue
                    
                    if cekSukses != 1 {
                        let alert = UIAlertController(title: "gagal", message: pesan, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                    }else{
                        let imgData = UIImageJPEGRepresentation(varDetail.gambarBarang!, 0.1)!
                        
                        let parameters = ["name": "Frank","action" : "insert","action2" : "upload"]
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
                            self.handleBack()
                        }))
                        
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
        
        PostBarang.varDetail.namaBarang = ""
        PostBarang.varDetail.desc = ""
        PostBarang.varDetail.qty = ""
        PostBarang.varDetail.kategori = ""
        PostBarang.varDetail.url = ""
        PostBarang.varDetail.status = 0
        
        PostBarang.varKarateristik.ukuran = ""
        PostBarang.varKarateristik.berat = ""
        PostBarang.varKarateristik.status = 0
        
        PostBarang.varNegara.negara = ""
        PostBarang.varNegara.kota = ""
        PostBarang.varNegara.idKota = ""
        PostBarang.varNegara.provinsi = ""
        PostBarang.varNegara.status = 0
        
        PostBarang.varHarga.harga = ""
        PostBarang.varHarga.status = 0
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
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
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
    let labelQty : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "qty barang "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let descText : UITextView = {
        let textField = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 3
        textField.text = "desc"
        textField.layer.borderColor =  UIColor.gray.cgColor
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
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
        addSubview(descText)
        addSubview(labelKategori)
        addSubview(labelUrl)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        addConstraintsWithFormat("H:|-80-[v0(100)]|", views: BarangImageView)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelNama)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelQty)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelKategori)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelUrl)
        addConstraintsWithFormat("H:|-80-[v0]-30-|", views: descText)
        
        addConstraintsWithFormat("V:|[v0(50)]", views: angkaImg)
        addConstraintsWithFormat("V:|-15-[v0]", views: labelA)
        addConstraintsWithFormat("V:|[v0(50)]-5-[v5(100)]-5-[v1]-5-[v2]-5-[v3]-5-[v6]-5-[v4]|", views: imageView,labelNama,labelQty,labelKategori,descText,BarangImageView,labelUrl)
        
    }
    
}

class InputCell2: BaseCell {
    
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
    
    let labelUkuran : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Ukuran Barang  "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
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
        addSubview(labelUkuran)
        addSubview(labelBerat)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelUkuran)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelBerat)
        addConstraintsWithFormat("H:|-30-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-10-[v0(50)]", views: angkaImg)
        addConstraintsWithFormat("V:|-25-[v0]", views: labelA)
        addConstraintsWithFormat("V:|-10-[v0(50)]-5-[v1]-5-[v2]|", views: imageView,labelUkuran,labelBerat)
        addConstraintsWithFormat("V:|[v0(1)]|", views: dividerLineView)
        
    }
    
}

class InputCell3: BaseCell {
    
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
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-30-[v2(50)]-5-[v0][v1(50)]-10-|", views: labelA,imageView,angkaImg)
        addConstraintsWithFormat("H:|-80-[v0]|", views: labelNegara)
        addConstraintsWithFormat("H:|-80-[v0]|", views: LabelProvinsi)
        addConstraintsWithFormat("H:|-80-[v0]|", views: LabelKota)
        addConstraintsWithFormat("H:|-30-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-10-[v0(50)]", views: angkaImg)
        addConstraintsWithFormat("V:|-25-[v0]", views: labelA)
        addConstraintsWithFormat("V:|-10-[v0(50)]-5-[v1]-5-[v3]-5-[v2]|", views: imageView,labelNegara,LabelKota,LabelProvinsi)
        addConstraintsWithFormat("V:|[v0(1)]|", views: dividerLineView)
        
    }
    
}

class InputCell4: BaseCell {
    
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
