//
//  AcceptPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 23/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyPickerPopover
import SwiftyJSON
import Alamofire_SwiftyJSON

class AcceptPreorder :  UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var selectedProv : String = ""
    var selectedCity : String = ""
    var selectedHarga : String = ""
    var selectedPengiriman : String = ""
    var idOffer : String = ""
    var arrNama = [String]()
    var arrHarga = [String]()
    var provinces = [province]()
    var cities = [city]()
    var prvv : raja?
    var kota : rajaKota?
    var jumlah : Int = 0
    struct userDetail: Decodable {
        let saldo: String
        let valueSaldo: String
    }
    
    var isiUser  : userDetail?
    
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
        ongkirText.isHidden = false
        labelOngkir.isHidden = false
        //print(app)
        fetchJSON()
        labelTgl.text = self.app?.deadline
        labelHarga.text = "Rp " + (self.app?.price)!
        labelKota.text = self.app?.kotaKirim
        label4.isHidden = true
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
        navigationItem.title = "Beli Preorder"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1{
            print("Num: \(indexPath.row)")
            print("Value: \(provinces[indexPath.row])")
            provinsiText.text = provinces[indexPath.row].province
            selectedProv = provinces[indexPath.row].province_id
            provTableView.isHidden = true
        }else if tableView.tag == 2{
            print("Num: \(indexPath.row)")
            print("Value: \(cities[indexPath.row])")
            kotaText.text = cities[indexPath.row].city_name
            selectedCity = cities[indexPath.row].city_id
            kotaTableView.isHidden = true
        }else if tableView.tag == 3{
            print("Num: \(indexPath.row)")
            ongkirText.text = "JNE " + arrNama[indexPath.row] + " - Rp. " + arrHarga[indexPath.row]
            ongkirTableView.isHidden = true
            selectedHarga = arrHarga[indexPath.row]
            selectedPengiriman = arrNama[indexPath.row]
            label4.isHidden = false
            let total = Int(selectedHarga)! + Int((app?.valueHarga)!)! * Int(qtyText.text!)!
            jumlah = total
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            let s2 = formatter.string(from:total  as NSNumber)
            labelTotal.text = "Rp " + s2!
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1{
            
            return provinces.count
        }else if tableView.tag == 2{
            
            return cities.count
        }
        return arrNama.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1{
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
            let province = provinces[indexPath.row]
            cell.textLabel?.text = province.province
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            return cell
        }else if tableView.tag == 2{
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
            let city = cities[indexPath.row]
            cell.textLabel?.text = city.city_name
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            return cell
        }else if tableView.tag == 3{
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
            let paket = arrNama[indexPath.row]
            let harga = arrHarga[indexPath.row]
            cell.textLabel?.text = paket + " - " + harga
            return cell
        }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let paket = arrNama[indexPath.row]
        let harga = arrHarga[indexPath.row]
        cell.textLabel?.text = paket + " - " + harga
        
        return cell
    }
    
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

    func fetchProv() {
        //kalau post dengan header encoding harus URLencoding
        DispatchQueue.main.async {
            let headers = [
                "key": "590ad699c8c798373e2053a28c7edd1e",
                "content-type": "application/x-www-form-urlencoded"
            ]
            Alamofire.request("https://api.rajaongkir.com/starter/province",method: .get,encoding: URLEncoding.default, headers: headers)
                .responseSwiftyJSON { dataResponse in
                    if let json = dataResponse.data {
                        print(json)
                        //let hasil = json["rajaongkir"]["results"]
                        do {
                            let decoder = JSONDecoder()
                            self.prvv = try decoder.decode(raja.self, from: json)
                            self.provinces = (self.prvv?.rajaongkir.results)!
                            print(self.provinces)
                            self.provTableView.reloadData()
                            print(self.provinces.count)
                        } catch let jsonErr {
                            print("Failed to decode:", jsonErr)
                        }
                    }
            }
            
        }
        
    }
    
    
    func fetchKota(prov:String) {
        DispatchQueue.main.async {
            //kalau post dengan header encoding harus URLencoding
            let parameters: Parameters = ["province": prov]
            let headers = [
                "key": "590ad699c8c798373e2053a28c7edd1e",
                "content-type": "application/x-www-form-urlencoded"
            ]
            Alamofire.request("https://api.rajaongkir.com/starter/city",method: .get,parameters : parameters,encoding: URLEncoding.default, headers: headers)
                .responseSwiftyJSON { dataResponse in
                    
                    
                    if let json = dataResponse.data {
                        //print(json)
                        //let hasil = json["rajaongkir"]["results"]
                        do {
                            let decoder = JSONDecoder()
                            self.kota = try decoder.decode(rajaKota.self, from: json)
                            self.cities = (self.kota?.rajaongkir.results)!
                            self.kotaTableView.reloadData()
                            //print(self.cities)
                            print(self.cities.count)
                        } catch let jsonErr {
                            print("Failed to decode:", jsonErr)
                        }
                    }
            }
        }
        
    }
    
    func fetchOngkir(){
        //kalau post dengan header encoding harus URLencoding
        let headers = [
            "key": "590ad699c8c798373e2053a28c7edd1e",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        if let berat = app?.berat,let myInt = Int(berat) , let origin = app?.idKota, let destination : String = selectedCity{
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
        
        if kotaText.text != "" {
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
    }
    
    @objc func textProvDidChange(_ textField: UITextField) {
        
        fetchProv()
        //init tableview
        //bug untuk pemilihan negara kedua
        provTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        provTableView.dataSource = self
        provTableView.delegate = self
        provTableView.tag = 1
        self.view.addSubview(provTableView)
        provTableView.topAnchor.constraint(equalTo: provinsiText.bottomAnchor, constant: 12).isActive = true
        provTableView.leftAnchor.constraint( equalTo: provinsiText.leftAnchor).isActive = true
        provTableView.rightAnchor.constraint(equalTo: provinsiText.rightAnchor).isActive = true
        provTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        provTableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        provTableView.layer.borderWidth = 1
        provTableView.layer.borderColor = UIColor.black.cgColor
        
        provTableView.isHidden = false
        kotaTableView.isHidden = true
        ongkirTableView.isHidden = true
    }
    
    @objc func textKotaTapped(_ textField: UITextField) {
        
        if provinsiText.text != ""{
            
            fetchKota(prov: selectedProv)
            //init tableview
            //bug untuk pemilihan negara kedua
            kotaTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
            kotaTableView.dataSource = self
            kotaTableView.delegate = self
            kotaTableView.tag = 2
            self.view.addSubview(kotaTableView)
            kotaTableView.topAnchor.constraint(equalTo: kotaText.bottomAnchor, constant: 12).isActive = true
            kotaTableView.leftAnchor.constraint( equalTo: kotaText.leftAnchor).isActive = true
            kotaTableView.rightAnchor.constraint(equalTo: kotaText.rightAnchor).isActive = true
            kotaTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            kotaTableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
            kotaTableView.layer.borderWidth = 1
            kotaTableView.layer.borderColor = UIColor.black.cgColor
            provTableView.isHidden = true
            kotaTableView.isHidden = false
            ongkirTableView.isHidden = true
        }
    }
    
    @objc func qtyTapped(_ textField: UITextField) {
        
        print("tapped")
        StringPickerPopover(title: "Jumlah Barang", choices: ["1","2","3","4","5"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.qtyText.text = selectedString
                
                if self.ongkirText.text == ""{
                    let total = Int((self.app?.valueHarga)!)! * Int(selectedString)!
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.minimumFractionDigits = 0
                    let s2 = formatter.string(from:total  as NSNumber)
                    self.labelTotal.text = "Rp " + s2!
                    
                }else{
                    
                    let total = Int(self.selectedHarga)! + Int((self.app?.valueHarga)!)! * Int(selectedString)!
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.minimumFractionDigits = 0
                    let s2 = formatter.string(from:total  as NSNumber)
                    self.labelTotal.text = "Rp " + s2!
                }
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: textField, baseViewController: self)
        
    }
    
    func sendNotif(){
        if let idTujuan = self.app?.email{
            let parameters: Parameters = ["idTujuan": idTujuan,"pesan": "Ada Penawaran Baru di Preordermu"]
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
        }else{
            if  Int((app?.qty)!)! < Int(qtyText.text!)!{
                let alert = UIAlertController(title: "Message", message: "Jumlah Barang Melebihi Stok", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }else{
            // create the alert
            let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin untuk Membeli Barang?", preferredStyle: UIAlertControllerStyle.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))

            alert.addAction(UIAlertAction(title: "Ya", style: UIAlertActionStyle.default, handler: { action in
                
                let saldo = Int((self.isiUser?.valueSaldo)!)
                let harga = Int((self.app?.valueHarga)!)
                let ongkir = Int(self.selectedHarga)
                
                let hargaTotal = self.jumlah
                print(hargaTotal)
                if saldo! < hargaTotal {
                    let alert = UIAlertController(title: "Message", message: "Saldo Anda Kurang, Saldo Saat ini adalah Rp " + (self.isiUser?.saldo)!, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    
                    let saldoNow : Int = saldo! - hargaTotal
                    print(saldoNow)
                    
                    if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String , let idPreorder = self.app?.id , let idPemilik = self.app?.email,let ongkir : String = self.selectedHarga, let qty = self.qtyText.text, let qtyAwal = self.app?.qty,let kota = self.kotaText.text,let pengiriman : String = self.selectedPengiriman, let jumlah : Int = self.jumlah{
                        var qtyNow = Int(qtyAwal)! - Int(qty)!
                        
                        let parameter: Parameters = ["idPreorder": idPreorder,"email":emailNow, "qty" : qty ,"kota":kota,"idKota":self.selectedCity,"hargaOngkir":ongkir,"pengiriman":pengiriman,"qtyNow":qtyNow,"saldo":saldoNow,"idPemilik":idPemilik,"jumlah":jumlah,"action":"insert"]
                        print (parameter)
                        Alamofire.request("http://titipanku.xyz/api/PostBeliPreorder.php",method: .get, parameters: parameter).responseJSON {
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
                                let alert = UIAlertController(title: "Message", message: "Pembelian Preorder Berhasil", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                                    
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
    }
    
    @objc private func handleBack(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPreorderDetail"), object: nil)
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    //tampilan
    
    let provTableView : UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let kotaTableView : UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    
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
        label.text = "Harga Barang (Belum Termasuk Ongkir) "
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
    
    let labelQty : UILabel = {
        let label = UILabel()
        label.text = "Kuantitas"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let qtyText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(qtyTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let labelProvinsi : UILabel = {
        let label = UILabel()
        label.text = "Dikirim ke Provinsi"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let provinsiText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textProvDidChange(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let labelCity : UILabel = {
        let label = UILabel()
        label.text = "Dikirim ke Kota"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let kotaText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textKotaTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
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
        textField.addTarget(self, action: #selector(ongkirTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let label4 : UILabel = {
        let label = UILabel()
        label.text = "Harga Barang (Termasuk Ongkir)"
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
        button.setTitle("Beli", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor(hex: "#4373D8")
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleTerimaOffer), for: UIControlEvents.touchDown)
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
        
        scrollView.addSubview(labelQty)
        labelQty.topAnchor.constraint(equalTo: labelKota.bottomAnchor, constant: 30).isActive = true
        labelQty.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(qtyText)
        qtyText.topAnchor.constraint(equalTo: labelQty.bottomAnchor, constant: 10).isActive = true
        qtyText.heightAnchor.constraint(equalToConstant: 35).isActive = true
        qtyText.font = UIFont.systemFont(ofSize: 15)
        qtyText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qtyText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        qtyText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -150).isActive = true
        
        scrollView.addSubview(labelProvinsi)
        labelProvinsi.topAnchor.constraint(equalTo: qtyText.bottomAnchor, constant: 30).isActive = true
        labelProvinsi.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(provinsiText)
        provinsiText.topAnchor.constraint(equalTo: labelProvinsi.bottomAnchor, constant: 10).isActive = true
        provinsiText.heightAnchor.constraint(equalToConstant: 35).isActive = true
        provinsiText.font = UIFont.systemFont(ofSize: 15)
        provinsiText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        provinsiText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -150).isActive = true
        
        scrollView.addSubview(labelCity)
        labelCity.topAnchor.constraint(equalTo: provinsiText.bottomAnchor, constant: 30).isActive = true
        labelCity.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        scrollView.addSubview(kotaText)
        kotaText.topAnchor.constraint(equalTo: labelCity.bottomAnchor, constant: 10).isActive = true
        kotaText.heightAnchor.constraint(equalToConstant: 35).isActive = true
        kotaText.font = UIFont.systemFont(ofSize: 15)
        kotaText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        kotaText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -150).isActive = true
        
        scrollView.addSubview(labelOngkir)
        labelOngkir.topAnchor.constraint(equalTo: kotaText.bottomAnchor, constant: 30).isActive = true
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
        postButton.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        
    }
    
}
