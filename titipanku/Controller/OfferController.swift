//
//  OfferController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 12/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyPickerPopover
import SwiftyJSON
import Alamofire_SwiftyJSON


class OfferController :  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct dataTrip {
        static var id = ""
    }
    var arrNama = [String]()
    var arrHarga = [String]()
    var kotaKirim : String = ""
    var dateBack : String = ""
    var selectedProv : String = ""
    var selectedCity : String = ""
    var statusTable : Int = 0
    var countries = [country]()
    var provinces = [province]()
    var cities = [city]()
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
    
    struct varOffer {
        var provinsi : String
        var kota : String
        var tglPulang : String
        var hargaPenawaran : String
    }
    
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
        ongkirText.isHidden = true
        labelOngkir.isHidden = true
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
        navigationItem.title = "Bantu Belikan"
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
            label3.isHidden = false
            kotaText.isHidden = false
        }else if tableView.tag == 2{
            print("Num: \(indexPath.row)")
            print("Value: \(cities[indexPath.row])")
            kotaText.text = cities[indexPath.row].city_name
            selectedCity = cities[indexPath.row].city_id
            kotaKirim = (app?.idKota)!
            
            //kalau post dengan header encoding harus URLencoding
            let headers = [
                "key": "590ad699c8c798373e2053a28c7edd1e",
                "content-type": "application/x-www-form-urlencoded"
            ]
            
            if let berat = app?.berat,let myInt = Int(berat) {
                print(myInt)
                let parameters: Parameters = ["origin": selectedCity,"destination": kotaKirim, "weight" : myInt, "courier" : "jne"]
                print (parameters)
                Alamofire.request("https://api.rajaongkir.com/starter/cost",method: .post, parameters: parameters,encoding: URLEncoding.default, headers: headers)
                    .responseSwiftyJSON { dataResponse in
                        
                        
                        if let json = dataResponse.value {
                            print(json)
                            let hasil = json["rajaongkir"]["results"][0]["costs"]
                            for i in 0 ..< hasil.count {
                                let servis = hasil[i]["service"]
                                let harga = hasil[i]["cost"][0]["value"]
                                print(servis.stringValue)
                                print(harga.stringValue)
                                self.arrNama.append(servis.stringValue)
                                self.arrHarga.append(harga.stringValue)
                            }
                            print(hasil.count)
                        }
                }
            }
            
            kotaTableView.isHidden = true
        } else if tableView.tag == 3{
            print("Num: \(indexPath.row)")
            ongkirText.text = "JNE " + arrNama[indexPath.row] + " - Rp. " + arrHarga[indexPath.row]
            ongkirTableView.isHidden = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1{
            
            return provinces.count
        }else if tableView.tag == 2{
            
            return cities.count
        }else if tableView.tag == 3{
            
            return arrNama.count
        }
        return provinces.count
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
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            
            return cell
        }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let city = cities[indexPath.row]
        cell.textLabel?.text = city.city_name
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        return cell
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
                        //print(json)
                        //let hasil = json["rajaongkir"]["results"]
                        do {
                            let decoder = JSONDecoder()
                            self.prvv = try decoder.decode(raja.self, from: json)
                            self.provinces = (self.prvv?.rajaongkir.results)!
                            //print(self.provinces)
                            self.provTableView.reloadData()
                            //print(self.provinces.count)
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
    
    @objc func textFieldTapped(_ textField: UITextField) {
        
        print("tapped")
        let date = Date() //ambil date hari ini
        /// DatePickerPopover appears:
        DatePickerPopover(title: "Tanggal Estimasi Pengiriman")
            .setDateMode(.date)
            .setSelectedDate(Date())
            .setMinimumDate(date)
            .setDoneButton(action: { popover, selectedDate in
                let formatter = DateFormatter()
                let formatterValue = DateFormatter()
                // initially set the format based on your datepicker date / server String
                //formatter.dateFormat = "yyyy-MM-dd"
                formatter.dateFormat = "dd MMM yyyy"
                formatterValue.dateFormat = "yyyy-MM-dd"
                // again convert your date to string
                let stringDate = formatter.string(from: selectedDate)
                self.dateBack = formatterValue.string(from: selectedDate)
                
                self.dateTextField.text = stringDate
                print(self.dateBack)
                print("selectedDate \(stringDate)")})
            .setCancelButton(action: { _, _ in print("cancel")})
            .appear(originView: textField, baseViewController: self)
        
    }
    
    
    @objc func ongkirTapped(_ textField: UITextField) {
        
        //init tableview
        //bug untuk pemilihan negara kedua
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
        
        provTableView.isHidden = true
        kotaTableView.isHidden = true
        ongkirTableView.isHidden = false
    }
    
    @objc func handlePostBarang(){
        if(provinsiText.text == "" && kotaText.text == "" && dateTextField.text == "" && hargaText.text == ""){
            let alert = UIAlertController(title: "Message", message: "Data Harus Terisi Semua", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else{
            print(dateTextField.text)
            print(dateBack)
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let id : String = app?.id, let idPemilik : String = app?.email,let hargaPenawaran : String = hargaText.text , let tglPulang : String = dateBack , let provinsi : String = provinsiText.text , let kota : String = kotaText.text, let email = self.app?.email,let idTrip :String = dataTrip.id{
                print(tglPulang)
                
                let parameter: Parameters = ["idRequest":id,"idPenawar": emailNow, "idPemilik": idPemilik, "hargaPenawaran":hargaPenawaran, "tglPulang": tglPulang, "provinsi":provinsi, "kota": kota, "idKota": selectedCity,"email":email,"idTrip":idTrip, "action" : "insert"]
                print (parameter)
                Alamofire.request("http://titipanku.xyz/api/PostOffer.php",method: .get, parameters: parameter).responseJSON {
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
                        let alert = UIAlertController(title: "Message", message: "Post Offer Berhasil", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            self.handleBack()
                        }))
                        
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func handleBack(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadBarangDetail"), object: nil)
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
    
    let label2 : UILabel = {
        let label = UILabel()
        label.text = "Provinsi Pengiriman"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let provinsiText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textProvDidChange(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let label3 : UILabel = {
        let label = UILabel()
        label.text = "Kota Pengiriman"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let kotaText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textKotaTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    
    let LabelTanggal : UILabel = {
        let label = UILabel()
        label.text = "Tanggal Pulang"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldTapped(_:)),
                            for: UIControlEvents.touchDown)
        return textField
    }()
    
    
    let labelOngkir : UILabel = {
        let label = UILabel()
        label.text = "Jasa Pengiriman"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ongkirText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(ongkirTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let label4 : UILabel = {
        let label = UILabel()
        label.text = "Harga Penawaran (Belum Termasuk Ongkir)"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let hargaText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
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
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true

        scrollView.addSubview(label2)
        label2.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
        label2.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(provinsiText)
        provinsiText.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 10).isActive = true
        provinsiText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        provinsiText.font = UIFont.systemFont(ofSize: 25)
        provinsiText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        provinsiText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        provinsiText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(label3)
        label3.topAnchor.constraint(equalTo: provinsiText.bottomAnchor, constant: 30).isActive = true
        label3.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(kotaText)
        kotaText.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 10).isActive = true
        kotaText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        kotaText.font = UIFont.systemFont(ofSize: 25)
        kotaText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        kotaText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        kotaText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(labelOngkir)
        labelOngkir.topAnchor.constraint(equalTo: kotaText.bottomAnchor, constant: 30).isActive = true
        labelOngkir.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(ongkirText)
        ongkirText.topAnchor.constraint(equalTo: labelOngkir.bottomAnchor, constant: 10).isActive = true
        ongkirText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ongkirText.font = UIFont.systemFont(ofSize: 25)
        ongkirText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ongkirText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        ongkirText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        
        scrollView.addSubview(LabelTanggal)
        LabelTanggal.topAnchor.constraint(equalTo: kotaText.bottomAnchor, constant: 30).isActive = true
        LabelTanggal.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(dateTextField)
        dateTextField.topAnchor.constraint(equalTo: LabelTanggal.bottomAnchor, constant: 10).isActive = true
        dateTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dateTextField.font = UIFont.systemFont(ofSize: 25)
        dateTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        dateTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(label4)
        label4.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 30).isActive = true
        label4.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(hargaText)
        hargaText.topAnchor.constraint(equalTo: label4.bottomAnchor, constant: 10).isActive = true
        hargaText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        hargaText.font = UIFont.systemFont(ofSize: 25)
        hargaText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hargaText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        hargaText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(postButton)
        postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor ).isActive = true
        postButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        
    }
   
}
    

