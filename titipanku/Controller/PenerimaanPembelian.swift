//
//  PenerimaanPembelian.swift
//  titipanku
//
//  Created by Ricky Wirawan on 07/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyPickerPopover
import SwiftyJSON
import Alamofire_SwiftyJSON


class PenerimaanPembelian :  UIViewController {
    
    var selectedHarga : String = ""
    var idOffer : String = ""
    var arrNama = [String]()
    var arrHarga = [String]()
    var statusTable : Int = 0
    var prvv : raja?
    var kota : rajaKota?
    
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
    
    var varOffer: VarOfferPreorder? {
        didSet {
            
        }
        
    }
    
    var app: App? {
        didSet {
            
            if app?.Screenshots != nil {
                return
            }
            
            if let id = app?.id {
                let urlString = "http://titipanku.xyz/api/DetailPreorder.php?id=\(id)"
                
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
        print(app)
        print(varOffer)
        //fetchOffer()
        
        labelA.text = "Tanggl Pembelian"
        labelTgl.text = varOffer?.tglBeli
        labelB.text = "Jumlah Barang"
        labelHarga.text = app?.qty
        labelKota.text = varOffer?.kota
        ResiText.text = varOffer?.nomorResi
        ongkirText.text = "JNE"+(varOffer?.pengiriman)! + " " + (varOffer?.hargaOngkir)! // Create the navigation bar
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
        setupView()
        //print(detailOffer)
    }
    
    @objc private func btnCancel(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendNotif(){
        if let idTujuan = self.app?.id{
            let parameters: Parameters = ["idTujuan": idTujuan,"pesan": "Pembeli Telah Menerima Barang Dengan Baik"]
            print(parameters)
            Alamofire.request("http://titipanku.xyz/api/notif.php",method: .get, parameters: parameters).responseJSON {
                response in
                
                //mengambil json
                let json = JSON(response.result.value)
                print(json)
            }
        }
    }
    
    func sendNotifTolak(){
        if let idTujuan = self.app?.id{
            let parameters: Parameters = ["idTujuan": idTujuan,"pesan": "Terdapat Masalah Pada Transaksimu"]
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
        
        // create the alert
        let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ya", style: UIAlertActionStyle.default, handler: { action in
            if let idOffer = self.varOffer?.id , let idRequest = self.app?.id, let review = self.reviewText.text , let rating = self.ratingText.text , let email = self.app?.email,let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String{
                
                let parameter: Parameters = ["idOffer": idOffer,"idRequest": idRequest,"action":"terima"]
                print (parameter)
                Alamofire.request("http://titipanku.xyz/api/SetPreorder.php",method: .get, parameters: parameter).responseJSON {
                    response in
                    
                    //mengambil json
                    let json = JSON(response.result.value)
                    print(json)
                    let cekSukses = json["success"].intValue
                    let pesan = json["pesan"].stringValue
                    
                    if cekSukses != 1 {
                        let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                    }else{
                        let parameters: Parameters = ["rating": rating,"email":email,"review": review,"reviewer": emailNow,"action":"insert"]
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
        
    }
    
    @objc func handleTolak(){
        // create the alert
        let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin ?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ya", style: UIAlertActionStyle.default, handler: { action in
            
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String,let idPreorder = self.app?.id, let idPemilik = self.app?.email{
                
                let parameter: Parameters = ["emailA":emailNow,"emailB": idPemilik,"tujuan":"preorder","idTujuan":idPreorder,"action":"insert"]
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
                        self.sendNotifTolak()
                        let alert = UIAlertController(title: "Message", message: "Penerimaan Barang Berhasil", preferredStyle: .alert)
                        
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
    
    @objc func qtyTapped(_ textField: UITextField) {
        
        print("tapped")
        StringPickerPopover(title: "Ukuran Barang", choices: ["1", "2","3","4","5"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.ratingText.text = selectedString
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: textField, baseViewController: self)
        
    }
    
    @objc private func handleBack(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPreorderDetail"), object: nil)
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    //tampilan
    
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
        label.text = "Harga Penawaran (Belum Termasuk Ongkir) "
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
        label.text = "Dikirim Ke Kota "
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
        //textField.inputView = UIView();
        return textField
    }()
    
    let labelResi : UILabel = {
        let label = UILabel()
        label.text = "Nomor Resi"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ResiText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.inputView = UIView();
        return textField
    }()
    
    let labelReview : UILabel = {
        let label = UILabel()
        label.text = "Review Anda"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let reviewText : UITextView = {
        let textField = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.layer.borderWidth = 1
        textField.layer.borderColor =  UIColor.black.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        //textField.addTarget(self, action: #selector(ongkirTapped(_:)),for: UIControlEvents.touchDown)
        //textField.inputView = UIView();
        return textField
    }()
    
    let labelRating : UILabel = {
        let label = UILabel()
        label.text = "Rating"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        button.setTitle("Barang Sudah Diterima", for: .normal)
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
    
    
    func setupView(){
        
        // add the scroll view to self.view
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.size.width - 16 , height: 850)
        let screenWidth = UIScreen.main.bounds.width+10
        
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
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

        scrollView.addSubview(labelResi)
        labelResi.topAnchor.constraint(equalTo: ongkirText.bottomAnchor, constant: 30).isActive = true
        labelResi.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(ResiText)
        ResiText.topAnchor.constraint(equalTo: labelResi.bottomAnchor, constant: 10).isActive = true
        ResiText.heightAnchor.constraint(equalToConstant: 35).isActive = true
        ResiText.font = UIFont.systemFont(ofSize: 15)
        ResiText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        ResiText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -150).isActive = true
        
        scrollView.addSubview(labelReview)
        labelReview.topAnchor.constraint(equalTo: ResiText.bottomAnchor, constant: 30).isActive = true
        labelReview.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(reviewText)
        reviewText.topAnchor.constraint(equalTo: labelReview.bottomAnchor, constant: 10).isActive = true
        reviewText.heightAnchor.constraint(equalToConstant: 105).isActive = true
        reviewText.font = UIFont.systemFont(ofSize: 15)
        reviewText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        reviewText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50).isActive = true
        
        scrollView.addSubview(labelRating)
        labelRating.topAnchor.constraint(equalTo: reviewText.bottomAnchor, constant: 30).isActive = true
        labelRating.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(ratingText)
        ratingText.topAnchor.constraint(equalTo: labelRating.bottomAnchor, constant: 10).isActive = true
        ratingText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ratingText.font = UIFont.systemFont(ofSize: 25)
        ratingText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        ratingText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -150).isActive = true
        
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


