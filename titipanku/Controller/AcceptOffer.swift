//
//  AcceptOffer.swift
//  titipanku
//
//  Created by Ricky Wirawan on 13/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyPickerPopover
import SwiftyJSON
import Alamofire_SwiftyJSON
import MidtransKit
import SKActivityIndicatorView

class AcceptOffer :  UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var selectedHarga : String = ""
    var selectedJenis : String = ""
    var idOffer : String = ""

    var arrNama = [String]()
    var arrHarga = [String]()
    var arrEtd = [String]()
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
                        SKActivityIndicator.dismiss()
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
        SKActivityIndicator.show("Loading...")
        view.backgroundColor = UIColor.white
        print("Bantu belikan Barang Loaded")
        ongkirText.isHidden = false
        labelOngkir.isHidden = false
        //print(app)
        //fetchOffer()
        //fetchOrderId()
        fetchJSON()
        labelTgl.text = self.varOffer?.tglPulang
        labelHarga.text = "Rp " + (self.varOffer?.hargaPenawaran)!
        labelKota.text = self.varOffer?.kota
        label4.isHidden = true
        
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
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
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
            ongkirText.text = "JNE " + arrNama[indexPath.row] + " - Rp " + arrHarga[indexPath.row] + " (" + arrEtd[indexPath.row] + " Hari)"
            ongkirTableView.isHidden = true
            selectedHarga = arrHarga[indexPath.row]
            selectedJenis = arrNama[indexPath.row]
            label4.isHidden = false
            let total = Int(selectedHarga)! + Int((varOffer?.valueHarga)!)!
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            let s2 = formatter.string(from:total  as NSNumber)
            labelTotal.text = "Rp " + s2!
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNama.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let paket = arrNama[indexPath.row]
        let harga = arrHarga[indexPath.row]
        cell.textLabel?.text = paket  + "(" + arrEtd[indexPath.row] + " Hari) " + " - " + harga
        
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
                            let etd = hasil[i]["cost"][0]["etd"]
                            print(servis.stringValue)
                            print(harga.stringValue)
                            self.arrNama.append(servis.stringValue)
                            self.arrHarga.append(harga.stringValue)
                            self.arrEtd.append(etd.stringValue)
                            print(self.arrNama)
                            print(self.arrHarga)
                            print(self.arrEtd)
                            self.ongkirTableView.reloadData()
                        }
                        if hasil.count == 0{
                            self.arrNama.append("Tidak Ada")
                            self.arrHarga.append("0")
                            self.arrEtd.append("-")
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
    
    func sendNotif(){
        if let idTujuan = self.varOffer?.idPenawar{
            let parameters: Parameters = ["idTujuan": idTujuan,"pesan": "Requester Menerima Offermu"]
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
        if let idTujuan = self.varOffer?.idPenawar{
            let parameters: Parameters = ["idTujuan": idTujuan,"pesan": "Requester Menolak Offermu"]
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
        
        if(ongkirText.text == ""){
            let alert = UIAlertController(title: "Message", message: "Data Harus Terisi Semua", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else if(ongkirText.text == "JNE Tidak Ada - Rp 0"){
            let alert = UIAlertController(title: "Message", message: "JNE Tidak Mendukung Daerah Anda", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        } else{
            
            // create the alert
            let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin untuk Menerima Offer?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                
                let saldo = Int((self.isiUser?.valueSaldo)!)
                let harga = Int((self.varOffer?.valueHarga)!)
                let ongkir = Int(self.selectedHarga)
                
                let hargaTotal = harga! + ongkir!
                print(hargaTotal)
                if saldo! < hargaTotal {
                    let alert = UIAlertController(title: "Message", message: "Saldo Anda Kurang, Saldo Saat ini adalah Rp " + (self.isiUser?.saldo)!, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    
                    let saldoNow : Int = saldo! - hargaTotal
                    print(saldoNow)
                    if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let ongkir : String = self.selectedHarga, let idOffer = self.varOffer?.id, let saldo : String = String(saldoNow), let idRequest = self.app?.id , let jne : String = self.selectedJenis, let idPenawar = self.varOffer?.idPenawar,let jumlah : String = String(hargaTotal){
                        
                        let parameter: Parameters = ["idOffer": idOffer,"idRequest": idRequest,"hargaOngkir":ongkir,"jenisOngkir":jne,"idPenawar":idPenawar,"saldo":saldoNow,"email":emailNow,"jumlah":jumlah,"action":"accept"]
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
                                self.sendNotif()
                                let alert = UIAlertController(title: "Message", message: "Accept Offer Berhasil", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                    
                                    self.handleBack()
                                    
                                }))
                                
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc func handleTolak(){
        // create the alert
        let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin untuk Menolak Offer?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String , let idOffer = self.varOffer?.id, let idPenawar = self.varOffer?.idPenawar, let idRequest = self.varOffer?.idRequest{
                
                let parameter: Parameters = ["idOffer":idOffer,"idPenawar":idPenawar,"idRequest":idRequest,"action":"decline"]
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
                        self.sendNotifTolak()
                        let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                        
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
        print("tolak")
        
    }
    
    @objc private func btnCancel(){
        
        self.dismiss(animated: true, completion: nil)
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
        label.text = "Metode Pengiriman (JNE)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ongkirText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(ongkirTapped(_:)),
                            for: UIControlEvents.touchDown)
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
    
    
    
    let postButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Terima", for: .normal)
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
        button.setTitle("Tolak", for: .normal)
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
        labelTotal.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelTotal.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        labelTotal.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
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
