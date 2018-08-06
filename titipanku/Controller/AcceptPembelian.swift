//
//  ListPembeliPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 24/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyPickerPopover
import SwiftyJSON
import Alamofire_SwiftyJSON


class AcceptPembelian :  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        navigationItem.title = "Pembeli Preorder"
        print("Bantu belikan Barang Loaded")
        ongkirText.isHidden = false
        labelOngkir.isHidden = false
        print(app)
        print(varOffer)
        //fetchOffer()
        
        labelTgl.text = self.varOffer?.tglBeli
        let harga = Int((app?.valueHarga)!)
        let qty = Int((varOffer?.qty)!)
        let ongkir = Int((varOffer?.valueHarga)!)
        labelHarga.text = "Rp " + String(harga!*qty!+ongkir!)
        labelKota.text = self.varOffer?.kota
        label4.isHidden = true
        ongkirText.text = (varOffer?.pengiriman)! + " " + (varOffer?.hargaOngkir)!
        setupView()
        //print(detailOffer)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 3{
            print("Num: \(indexPath.row)")
            ongkirText.text = "JNE " + arrNama[indexPath.row] + " - Rp. " + arrHarga[indexPath.row]
            ongkirTableView.isHidden = true
            selectedHarga = arrHarga[indexPath.row]
            label4.isHidden = false
            let total = Int(selectedHarga)! + Int((varOffer?.hargaOngkir)!)!
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
    
    
    @objc func handleTerimaOffer(){
        
        if(ongkirText.text == ""){
            let alert = UIAlertController(title: "Message", message: "Data Harus Terisi Semua", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else{
            
            // create the alert
            let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin untuk Menerima?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                if let idOffer = self.varOffer?.id , let idRequest = self.app?.id{
                    
                    let parameter: Parameters = ["idOffer": idOffer,"idRequest": idRequest,"action":"accept"]
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
                            let alert = UIAlertController(title: "Message", message: "Accept Offer Berhasil", preferredStyle: .alert)
                            
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
    
    @objc func handleTolak(){
        // create the alert
        let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin untuk Menolak Pembeli?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String , let idOffer = self.varOffer?.id{
                
                let parameter: Parameters = ["idOffer":idOffer,"action":"decline"]
                print (parameter)
                Alamofire.request("http://titipanku.xyz/api/SetPreorder.php",method: .get, parameters: parameter).responseJSON {
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
    
    @objc private func handleBack(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPreorderDetail"), object: nil)
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
        button.backgroundColor = UIColor.blue
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
        scrollView.contentSize = CGSize(width: view.frame.size.width - 16 , height: 850)
        let screenWidth = UIScreen.main.bounds.width+10
        
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0).isActive = true
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
