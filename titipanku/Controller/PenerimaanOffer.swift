//
//  PenerimaanOffer.swift
//  titipanku
//
//  Created by Ricky Wirawan on 06/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyPickerPopover
import SwiftyJSON
import Alamofire_SwiftyJSON
import MidtransKit
import SKActivityIndicatorView
import Cosmos

class PenerimaanOffer :  UIViewController {
    
    var selectedHarga : String = ""
    var selectedRating : String = ""
    var idOffer : String = ""
    var arrNama = [String]()
    var arrHarga = [String]()
    var statusTable : Int = 0
    var prvv : raja?
    var kota : rajaKota?
    var midtrans : Midtrans?
    var orderId : String = ""
    struct Midtrans: Decodable {
        let orderId: String
    }
    
    struct userDetail: Decodable {
        let saldo: String
        let valueSaldo: String
    }
    
    var isiUser  : userDetail?
    
    fileprivate func fetchJSON() {
        if let userPenawar = varOffer?.idPenawar {
            print(userPenawar)
            let urlString = "http://titipanku.xyz/api/DetailUser.php?email=\(String(describing: userPenawar))"
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
                        SKActivityIndicator.dismiss()
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                        SKActivityIndicator.dismiss()
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        SKActivityIndicator.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKActivityIndicator.show("Loading...")
        view.backgroundColor = UIColor.white
        print("Bantu belikan Barang Loaded")
        ongkirText.isHidden = false
        labelOngkir.isHidden = false
        print(app)
        //fetchOffer()
        fetchJSON()
        labelTgl.text = self.varOffer?.tglPulang
        labelHarga.text = self.app?.nomorResi
        labelKota.text = self.varOffer?.kota
        
        //label4.isHidden = true
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
        navigationItem.title = "Penerimaan"
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Titip Juga", style: .plain, target: self, action: #selector(handleTitip))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Batal", style: .done, target: self, action: #selector(btnCancel))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        //print(detailOffer)
        
        Alamofire.request("http://titipanku.xyz/uploads/nota"+(self.varOffer?.id)!+".jpg").responseImage { response in
            //debugPrint(response)
            //let nama = self.app?.name
            //print("gambar : "+imageName)
            if let image = response.result.value {
                //print("image downloaded: \(image)")
                self.imageView.image = image
            }
        }
    }
    
    @objc private func btnCancel(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendNotif(){
        if let idTujuan = self.varOffer?.idPenawar{
            let parameters: Parameters = ["idTujuan": idTujuan,"pesan": "Requester Telah Menerima Barang"]
            print(parameters)
            Alamofire.request("http://titipanku.xyz/api/notif.php",method: .get, parameters: parameters).responseJSON {
                response in
                
                //mengambil json
                let json = JSON(response.result.value)
                print(json)
            }
        }
    }
    
    @objc func handleCekResi(){
        let tambahCont = CekResi()
        if let resi = labelHarga.text{
            tambahCont.nomor = resi
        }
        present(tambahCont, animated: true, completion: {
        })
    }
    
    @objc func handleTerimaOffer(){
        if ongkirText.text != "" {
        let saldo = Int((self.isiUser?.valueSaldo)!)
        let harga = Int((self.varOffer?.valueHarga)!)
        let hargaTotal = harga! + Int((self.varOffer?.hargaOngkir)!)!
            // create the alert
            let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin Barang Telah Sampai Dengan Baik ?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ya", style: UIAlertActionStyle.default, handler: { action in
                let saldoNow : Int = saldo! + hargaTotal
                if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let idOffer = self.varOffer?.id, let idRequest = self.app?.id, let review = self.ongkirText.text , let rating : String = String(self.ratingControl.rating) , let email = self.varOffer?.idPenawar, let saldo : Int = saldoNow, let jumlah  : Int = hargaTotal,let idPenawar = self.varOffer?.idPenawar{
                    
                    let parameter: Parameters = ["idOffer": idOffer,"email":emailNow,"idRequest": idRequest,"jumlah":jumlah,"saldo":saldo,"idPenawar":idPenawar,"action":"terima"]
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
                            let parameters: Parameters = ["rating": rating,"email":email,"reviewer":emailNow,"review": review,"action":"insert"]
                            print (parameters)
                            Alamofire.request("http://titipanku.xyz/api/PostReview.php",method: .get, parameters: parameters).responseJSON {
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
                                    
                                    self.sendNotif()
                                    let alert = UIAlertController(title: "Message", message: "Review dan Terima Barang Berhasil", preferredStyle: .alert)
                                    
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                        
                                        self.handleBack()
                                        
                                    }))
                                    
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    }
                }
                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
         }else{
            let alert = UIAlertController(title: "Message", message: self.ongkirText.text, preferredStyle: .alert)
            print(ratingControl.rating)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        
    }
    
    @objc func handleTolak(){
        // create the alert
        let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin ?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ya", style: UIAlertActionStyle.default, handler: { action in
            
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let idOffer = self.varOffer?.id, let idRequest = self.app?.id, let idPenawar = self.varOffer?.idPenawar{
                
                let parameter: Parameters = ["emailA":emailNow,"emailB": idPenawar,"tujuan":"request","idTujuan":idRequest,"action":"insert"]
                print (parameter)
                Alamofire.request("http://titipanku.xyz/api/PostChatMasalah.php",method: .get, parameters: parameter).responseJSON {
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
                        let alert = UIAlertController(title: "Message", message: "Berhasil Menghubungi Admin, Silakan Menuju Chatroom", preferredStyle: .alert)
                        
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
    
    @objc private func handleBack(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadBarangDetail"), object: nil)
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func qtyTapped(_ textField: UITextField) {
        
        print("tapped")
        StringPickerPopover(title: "Rating Anda", choices: ["⭐️", "⭐️⭐️","⭐️⭐️⭐️","⭐️⭐️⭐️⭐️","⭐️⭐️⭐️⭐️⭐️"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                if selectedRow == 0{
                    self.selectedRating = "1"
                }else if selectedRow == 1{
                    self.selectedRating = "2"
                }else if selectedRow == 2{
                    self.selectedRating = "3"
                }else if selectedRow == 3{
                    self.selectedRating = "4"
                }else if selectedRow == 4{
                    self.selectedRating = "5"
                }
                self.ratingText.text = selectedString
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: textField, baseViewController: self)
        
    }
    
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    //tampilan
    
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Tanggal Pengiriman "
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
        label.text = "Nomor Resi "
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
    
    let cekResi : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Cek Resi", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor(hex: "#4373D8")
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleCekResi), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    let labelC : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Dikirim Dari "
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
        label.text = "Review Anda"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ongkirText : UITextView = {
        let textField = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.layer.borderWidth = 1
        textField.layer.borderColor =  UIColor.black.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.addTarget(self, action: #selector(ongkirTapped(_:)),for: UIControlEvents.touchDown)
        //textField.inputView = UIView();
        return textField
    }()
    
    let label4 : UILabel = {
        let label = UILabel()
        label.text = "Rating"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let ratingControl : CosmosView = {
        let starControl = CosmosView()
        starControl.translatesAutoresizingMaskIntoConstraints = false
        return starControl
    }()
    let ratingText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(qtyTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let postButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Barang Sampai", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor(hex: "#4373D8")
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleTerimaOffer), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    let declineButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Terdapat Masalah", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor.red
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleTolak), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button

    }()
    
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
        
        iv.isUserInteractionEnabled = true
        return iv
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
        
        scrollView.addSubview(cekResi)
        cekResi.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        cekResi.topAnchor.constraint(equalTo: labelKota.topAnchor, constant: 30).isActive = true
        cekResi.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cekResi.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        scrollView.addSubview(labelOngkir)
        labelOngkir.topAnchor.constraint(equalTo: cekResi.bottomAnchor, constant: 350).isActive = true
        labelOngkir.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(ongkirText)
        ongkirText.topAnchor.constraint(equalTo: labelOngkir.bottomAnchor, constant: 10).isActive = true
        ongkirText.heightAnchor.constraint(equalToConstant: 105).isActive = true
        ongkirText.font = UIFont.systemFont(ofSize: 15)
        ongkirText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        ongkirText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50).isActive = true
        
        scrollView.addSubview(label4)
        label4.topAnchor.constraint(equalTo: ongkirText.bottomAnchor, constant: 30).isActive = true
        label4.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(ratingControl)
        ratingControl.topAnchor.constraint(equalTo: label4.bottomAnchor, constant: 10).isActive = true
        ratingControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ratingControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        ratingControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -150).isActive = true
        
        scrollView.addSubview(labelImage)
        labelImage.topAnchor.constraint(equalTo: cekResi.bottomAnchor, constant: 0).isActive = true
        labelImage.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: labelImage.bottomAnchor, constant: 10).isActive = true //anchor ke scrollview
        imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        scrollView.addSubview(postButton)
        postButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        postButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: screenWidth/2).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        scrollView.addSubview(declineButton)
        declineButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        declineButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        declineButton.widthAnchor.constraint(equalToConstant: screenWidth/2).isActive = true
        declineButton.heightAnchor.constraint(equalToConstant: 80).isActive = true

        declineButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        
    }
    
}
