//
//  ConfirmAcceptedOffer.swift
//  titipanku
//
//  Created by Ricky Wirawan on 05/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyPickerPopover
import SwiftyJSON
import Alamofire_SwiftyJSON
import MidtransKit

class ConfirmAcceptedOffer :  UIViewController, UITableViewDelegate,UIImagePickerControllerDelegate, UITableViewDataSource,UINavigationControllerDelegate {
    
    var selectedHarga : String = ""
    var idOffer : String = ""
    var arrNama = [String]()
    var arrHarga = [String]()
    var statusTable : Int = 0
    var prvv : raja?
    var kota : rajaKota?
    var midtrans : Midtrans?
    var orderId : String = ""
    var cekGambar = false
    struct Midtrans: Decodable {
        let orderId: String
    }
    
    struct userDetail: Decodable {
        let saldo: String
        let valueSaldo: String
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
                        //self.labelB.text = "Rp " + (self.isiUser?.saldo)!
                        
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                    }
                }
                }.resume()
        }
    }
    
    struct country: Decodable {
        let name: String
    }
    
    struct raja: Decodable {
        let rajaongkir: prov
    }
    struct prov: Decodable {
        let results: [province]
    }
    struct province: Decodable {
        let province_id: String
        let province: String
    }
    
    struct rajaKota: Decodable {
        let rajaongkir: hasilKota
    }
    struct hasilKota: Decodable {
        let results: [city]
    }
    struct city: Decodable {
        let city_id: String
        let city_name: String
        let province_id: String
    }
    
    var varOffer: VarOffer? {
        didSet {
            
        }
        
    }
    
    //    var detailOffer : VarOffer?
    //
    //    func fetchOffer() {
    //
    //        DispatchQueue.main.async {
    //        let urlString = "http://titipanku.xyz/api/ShowOfferDetail.php?idOffer=\(self.idOffer)"
    //        guard let url = URL(string: urlString) else { return }
    //        URLSession.shared.dataTask(with: url) { (data, _, err) in
    //            DispatchQueue.main.async {
    //                if let err = err {
    //                    print("Failed to get data from url:", err)
    //                    return
    //                }
    //
    //                guard let data = data else { return }
    //                do {
    //                    let decoder = JSONDecoder()
    //                    self.detailOffer = try decoder.decode(VarOffer.self, from: data)
    //                    print(self.detailOffer)
    //                } catch let jsonErr {
    //                    print("Failed to decode:", jsonErr)
    //                }
    //            }
    //            }.resume()
    //        }
    //    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        print("Bantu belikan Barang Loaded")
        ongkirText.isHidden = false
        labelOngkir.isHidden = false
        //print(app)
        //fetchOffer()
        //fetchOrderId()
        fetchJSON()
        labelTgl.text = self.varOffer?.tglPulang
        labelHarga.text = self.varOffer?.hargaPenawaran
        labelKota.text = self.app?.qty
        //labelOngkir.text = (self.varOffer?.jenisOngkir)! + "+" + (self.varOffer?.hargaOngkir)!
        ongkirText.text =  (self.varOffer?.jenisOngkir)! + " - " + (self.varOffer?.hargaOngkir)!
        let total = Int((self.varOffer?.valueHarga)!)! + Int((self.varOffer?.hargaOngkir)!)!
        labelTotal.text = "Rp. " + String(total)
        label4.isHidden = false
        print(varOffer)
        setupView()
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
        navigationItem.title = "Penawaran"
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Titip Juga", style: .plain, target: self, action: #selector(handleTitip))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(btnCancel))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        //print(detailOffer)
    }
    
    @objc private func btnCancel(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchOrderId(){
        let urlString = "http://titipanku.xyz/api/GetMaxOffer.php"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                self.midtrans = try decoder.decode(Midtrans.self, from: data)
                print("midtrans")
                print(self.midtrans)
                DispatchQueue.main.async(execute: { () -> Void in
                    
                })
                
            } catch let err {
                print(err)
            }
            
        }) .resume()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 3{
            print("Num: \(indexPath.row)")
            ongkirText.text = "JNE " + arrNama[indexPath.row] + " - Rp. " + arrHarga[indexPath.row]
            ongkirTableView.isHidden = true
            selectedHarga = arrHarga[indexPath.row]
            label4.isHidden = false
            let total = Int(selectedHarga)! + Int((varOffer?.valueHarga)!)!
            labelTotal.text = String(total)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNama.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let paket = arrNama[indexPath.row]
        let harga = arrHarga[indexPath.row]
        cell.textLabel?.text = paket + " - " + harga
        
        return cell
    }
    
    
    func fetchOngkir(){
        //kalau post dengan header encoding harus URLencoding
        let headers = [
            "key": "590ad699c8c798373e2053a28c7edd1e",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        if let berat = app?.berat,let myInt = Int(berat) , let origin = varOffer?.idKota, let destination = app?.idKota{
            print(myInt)
            let parameters: Parameters = ["origin": origin,"destination": destination, "weight" : myInt, "courier" : "jne"]
            print (parameters)
            Alamofire.request("https://api.rajaongkir.com/starter/cost",method: .post, parameters: parameters,encoding: URLEncoding.default, headers: headers)
                .responseSwiftyJSON { dataResponse in
                    
                    
                    if let json = dataResponse.value {
                        print(json)
                        let hasil = json["rajaongkir"]["results"][0]["costs"]
                        self.arrNama = []
                        self.arrHarga = []
                        for i in 0 ..< hasil.count {
                            let servis = hasil[i]["service"]
                            let harga = hasil[i]["cost"][0]["value"]
                            print(servis.stringValue)
                            print(harga.stringValue)
                            self.arrNama.append(servis.stringValue)
                            self.arrHarga.append(harga.stringValue)
                            print(self.arrNama)
                            print(self.arrHarga)
                            self.ongkirTableView.reloadData()
                        }
                        self.ongkirTableView.reloadData()
                        print(hasil.count)
                    }
            }
        }
        
    }
    
    @objc func ongkirTapped(_ textField: UITextField) {
        
        fetchOngkir()
        ongkirTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        ongkirTableView.dataSource = self
        ongkirTableView.delegate = self
        ongkirTableView.tag = 3
        self.view.addSubview(ongkirTableView)
        ongkirTableView.topAnchor.constraint(equalTo: ongkirText.bottomAnchor, constant: 12).isActive = true
        ongkirTableView.leftAnchor.constraint( equalTo: ongkirText.leftAnchor).isActive = true
        ongkirTableView.rightAnchor.constraint(equalTo: ongkirText.rightAnchor).isActive = true
        ongkirTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        ongkirTableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        ongkirTableView.layer.borderWidth = 1
        ongkirTableView.layer.borderColor = UIColor.black.cgColor
        ongkirTableView.isHidden = false
    }
    
    @objc func imgTapped(_ imageView: UIImageView) {
        print("tapped gambar")
        
        let alert = UIAlertController(title: "Choose one of the following:", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.openCamera()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print(info)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            imageView.image = selectedImage
            cekGambar = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func sendNotif(){
        if let idTujuan = self.app?.email{
            let parameters: Parameters = ["idTujuan": idTujuan,"pesan": "Traveler Sudah Membelikan Barangmu"]
            print(parameters)
            Alamofire.request("http://titipanku.xyz/api/notif.php",method: .get, parameters: parameters).responseJSON {
                response in
                
                //mengambil json
                let json = JSON(response.result.value)
                print(json)
            }
        }
    }
    
    @objc func handleTerimaOffer(){
        
        if(ongkirText.text == "" || cekGambar == false){
            let alert = UIAlertController(title: "Message", message: "Data Harus Terisi Semua", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else if(ongkirText.text == "JNE Tidak Ada - Rp 0"){
            let alert = UIAlertController(title: "Message", message: "JNE Tidak Mendukung Daerah Anda", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        } else{
            
            // create the alert
            let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin ?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ya", style: UIAlertActionStyle.default, handler: { action in
               
                if let emailNow = self.app?.email, let idOffer = self.varOffer?.id, let idRequest = self.app?.id , let idPenawar = self.varOffer?.idPenawar{
                    
                    let parameter: Parameters = ["idOffer": idOffer,"email":emailNow,"idRequest": idRequest,"idPenawar":idPenawar,"action":"confirm","action2" : "tidak"]
                    print (parameter)
                    Alamofire.request("http://titipanku.xyz/api/SetOffer.php",method: .get, parameters: parameter).responseJSON {
                        response in
                        
                        //mengambil json
                        let json = JSON(response.result.value)
                        print(json)
                        let cekSukses = json["success"].intValue
                        let pesan = json["message"].stringValue
                        
                        if cekSukses != 1 {
                            let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                            
                            self.present(alert, animated: true)
                        }else{
                            
                            let imgData = UIImageJPEGRepresentation(self.imageView.image!, 0.1)!
                            
                            let parameters = ["name": "Frank","idOffer": idOffer,"action" : "confirm","action2" : "upload"]
                            print(parameters)
                            //userfile adalah parameter post untuk file yg ingin di upload
                            Alamofire.upload(multipartFormData: { multipartFormData in
                                multipartFormData.append(imgData, withName: "userfile",fileName: "file.jpg", mimeType: "image/jpg")
                                for (key, value) in parameters {
                                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                                }
                            },
                                             to:"http://titipanku.xyz/api/testing.php")
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
                            
                            self.sendNotif()
                            let alert = UIAlertController(title: "Message", message: "Belikan Barang Berhasil", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                
                                self.handleBack()
                                
                            }))
                            
                            self.present(alert, animated: true)
                        }
                    }
                }
                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc private func handleBack(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadBarangDetail"), object: nil)
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    //tampilan
    
    let ongkirTableView : UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Tanggal Kembali Ke Indonesia "
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelTgl : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Harga Barang "
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelHarga : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelC : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Jumlah Barang "
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelKota : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelOngkir : UILabel = {
        let label = UILabel()
        label.text = "Metode Pengiriman"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ongkirText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.addTarget(self, action: #selector(ongkirTapped(_:)),for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let label4 : UILabel = {
        let label = UILabel()
        label.text = "Harga Penawaran (Termasuk Ongkir)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelTotal : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let backButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        //backButton.setImage(UIImage(named: "BackButton.png"), for: .normal) // Image can be downloaded from here below link
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(button.tintColor, for: .normal) // You can change the TitleColor
        button.addTarget(self, action: #selector(handleBack), for: UIControlEvents.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let labelImage : UILabel = {
        let label = UILabel()
        label.text = "Nota Pembelian"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "coba")
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:))))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let postButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Barang Sudah Dibelikan", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor(hex: "#4373D8")
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleTerimaOffer), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button

    }()

    //    let declineButton : UIButton = {
    //        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    //        button.setTitle("Tolak", for: .normal)
    //        button.setTitleColor(.white, for: .normal)
    //        button.setTitleColor(.cyan, for: .selected)
    //        button.backgroundColor = UIColor.red
    //        button.clipsToBounds = true
    //        button.addTarget(self, action: #selector(handleTolak), for: UIControlEvents.touchDown)
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        return button
    //
    //    }()
    
    let dividerLineView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    let dividerLineView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    let dividerLineView3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.keyboardDismissMode = .onDrag
        v.delaysContentTouches = false
        return v
    }()
    
    
    func setupView(){
        
        // add the scroll view to self.view
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.size.width - 16 , height: 1150)
        let screenWidth = UIScreen.main.bounds.width+10
        
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        
        scrollView.addSubview(labelA)
        labelA.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
        labelA.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(labelTgl)
        labelTgl.topAnchor.constraint(equalTo: labelA.bottomAnchor, constant: 10).isActive = true
        labelTgl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(labelB)
        labelB.topAnchor.constraint(equalTo: labelTgl.bottomAnchor, constant: 30).isActive = true
        labelB.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(labelHarga)
        labelHarga.topAnchor.constraint(equalTo: labelB.bottomAnchor, constant: 10).isActive = true
        labelHarga.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(labelC)
        labelC.topAnchor.constraint(equalTo: labelHarga.bottomAnchor, constant: 30).isActive = true
        labelC.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(labelKota)
        labelKota.topAnchor.constraint(equalTo: labelC.bottomAnchor, constant: 10).isActive = true
        labelKota.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(labelOngkir)
        labelOngkir.topAnchor.constraint(equalTo: labelKota.bottomAnchor, constant: 30).isActive = true
        labelOngkir.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(ongkirText)
        ongkirText.topAnchor.constraint(equalTo: labelOngkir.bottomAnchor, constant: 10).isActive = true
        ongkirText.heightAnchor.constraint(equalToConstant: 35).isActive = true
        ongkirText.font = UIFont.systemFont(ofSize: 15)
        ongkirText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        ongkirText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -150).isActive = true
        
        scrollView.addSubview(label4)
        label4.topAnchor.constraint(equalTo: ongkirText.bottomAnchor, constant: 30).isActive = true
        label4.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(labelTotal)
        labelTotal.topAnchor.constraint(equalTo: label4.bottomAnchor, constant: 10).isActive = true
        labelTotal.heightAnchor.constraint(equalToConstant: 50).isActive = true
        labelTotal.font = UIFont.systemFont(ofSize: 25)
        labelTotal.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(labelImage)
        labelImage.topAnchor.constraint(equalTo: labelTotal.bottomAnchor, constant: 30).isActive = true
        labelImage.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: labelImage.bottomAnchor, constant: 10).isActive = true //anchor ke scrollview
        imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        //backButton
        view.addSubview(backButton)
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        
        scrollView.addSubview(postButton)
        postButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        postButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        //        scrollView.addSubview(declineButton)
        //        declineButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        //        declineButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        //        declineButton.widthAnchor.constraint(equalToConstant: screenWidth/2).isActive = true
        //        declineButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        //
        //        declineButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        //
        
    }
    
}
