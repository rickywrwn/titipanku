//
//  AddNegaraBarang.swift
//  titipanku
//
//  Created by Ricky Wirawan on 11/06/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire

class AddNegaraBarang :  UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    var selectedProv : String = ""
    var selectedCity : String = ""
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        if PostBarang.varNegara.status != 0 {
            negaraText.text = PostBarang.varNegara.negara
            provinsiText.text = PostBarang.varNegara.provinsi
            kotaText.text = PostBarang.varNegara.kota
            
            
            label3.isHidden = false
            kotaText.isHidden = false
        }else{
            
            label3.isHidden = true
            kotaText.isHidden = true
        }
        
        setupView()
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    @objc func handleSubmit(){
        
        if negaraText.text != "" && provinsiText.text != "" && kotaText.text != ""{
            PostBarang.varNegara.negara = negaraText.text!
            PostBarang.varNegara.kota = kotaText.text!
            PostBarang.varNegara.provinsi = provinsiText.text!
            PostBarang.varNegara.idKota = selectedCity
            PostBarang.varNegara.status = 1
            
            print(PostBarang.varNegara.negara.self)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
            self.dismiss(animated: true)
        }else{
            let alert = UIAlertController(title: "Peringatan", message: "Data Tidak Boleh Kosong", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0{
            print("Num: \(indexPath.row)")
            print("Value: \(countries[indexPath.row])")
            negaraText.text = countries[indexPath.row].name
            myTableView.isHidden = true
        }else if tableView.tag == 1{
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
            kotaTableView.isHidden = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            
            return countries.count
        }else if tableView.tag == 1{
            
            return provinces.count
        }else if tableView.tag == 2{
            
            return cities.count
        }
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0{
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
            let country = countries[indexPath.row]
            cell.textLabel?.text = country.name
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            return cell
        }else if tableView.tag == 1{
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
        }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let country = countries[indexPath.row]
        cell.textLabel?.text = country.name
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        return cell
    }
    
    
    func fetchNegara(nama:String) -> Void {
        
        let urlString = "https://restcountries.eu/rest/v2/name/\(String(describing: nama))"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to get data from url:", err)
                    return
                }

                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    self.countries = try decoder.decode([country].self, from: data)
                    self.myTableView.reloadData()
                    //print(self.countries)
                } catch let jsonErr {
                    print("Failed to decode:", jsonErr)
                }
            }
        }.resume()
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
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        fetchNegara(nama: textField.text!)
        //init tableview
        //bug untuk pemilihan negara kedua
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.tag = 0
        self.view.addSubview(myTableView)
        myTableView.topAnchor.constraint(equalTo: negaraText.bottomAnchor, constant: 12).isActive = true
        myTableView.leftAnchor.constraint( equalTo: negaraText.leftAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: negaraText.rightAnchor).isActive = true
        myTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        myTableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        myTableView.layer.borderWidth = 1
        myTableView.layer.borderColor = UIColor.black.cgColor
        
        myTableView.isHidden = false
        kotaTableView.isHidden = true
        provTableView.isHidden = true
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
        myTableView.isHidden = true
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
        myTableView.isHidden = true
    }

    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    //tampilan
    let myTableView : UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
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
    
    let label1 : UILabel = {
        let label = UILabel()
        label.text = "Negara Pembelian"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let negaraText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
        return textField
    }()
    
    let label2 : UILabel = {
        let label = UILabel()
        label.text = "Dikirim ke Provinsi"
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
        label.text = "Dikirim ke Kota"
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
    
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.keyboardDismissMode = .onDrag
        v.delaysContentTouches = false
        return v
    }()
    
    func setupView(){
        
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
        navigationItem.title = "Negara"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        // add the scroll view to self.view
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.size.width - 16 , height: 1150)
        
        
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        
        
        scrollView.addSubview(label1)
        label1.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true //anchor ke scrollview
        label1.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(negaraText)
        negaraText.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 10).isActive = true
        negaraText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        negaraText.font = UIFont.systemFont(ofSize: 25)
        negaraText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        negaraText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        negaraText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(label2)
        label2.topAnchor.constraint(equalTo: negaraText.bottomAnchor, constant: 30).isActive = true
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
        
    }
    
    
}


