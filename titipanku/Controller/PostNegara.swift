//
//  PostNegara.swift
//  titipanku
//
//  Created by Ricky Wirawan on 29/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SwiftyPickerPopover
import Alamofire
import SwiftyJSON

class PostNegara: UIViewController , UITableViewDelegate, UITableViewDataSource{
     
    var dateBack : String = ""
    var countries = [country]()
    struct country: Decodable {
        let name: String
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("Post Trip")
        setupView()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(countries[indexPath.row])")
        CountryTextField.text = countries[indexPath.row].name
        myTableView.isHidden = true
        self.hideKeyboardWhenTappedAround()
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let country = countries[indexPath.row]
        cell.textLabel?.text = country.name
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
                    print(self.countries)
                } catch let jsonErr {
                    print("Failed to decode:", jsonErr)
                }
            }
            }.resume()
       
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        fetchNegara(nama: textField.text!)
         myTableView.isHidden = false
        //init tableview
        //bug untuk pemilihan negara kedua
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        myTableView.topAnchor.constraint(equalTo: CountryTextField.bottomAnchor, constant: 12).isActive = true
        myTableView.leftAnchor.constraint( equalTo: CountryTextField.leftAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: CountryTextField.rightAnchor).isActive = true
        myTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        myTableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        myTableView.layer.borderWidth = 1
        myTableView.layer.borderColor = UIColor.black.cgColor
        
    }
    
    @objc func textFieldTapped(_ textField: UITextField) {
        
        print("tapped")
        let date = Date() //ambil date hari ini
        /// DatePickerPopover appears:
        DatePickerPopover(title: "Tanggal Kembali")
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
    @objc func handlePostTrip(){
        
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            print(emailNow)
            let parameters: Parameters = ["email": emailNow,"country": CountryTextField.text!, "tgl" : dateBack ,"action" : "insert"]
            Alamofire.request("http://localhost/titipanku/PostTrip.php",method: .get, parameters: parameters).responseJSON {
                response in
                
                //mencetak JSON response
                if let json = response.result.value {
                    print("JSON: \(json)")
                }
                
                //mengambil json
                let json = JSON(response.result.value)
                print(json)
                let cekSukses = json["success"].intValue
                
                if cekSukses != 1 {
                    let alert = UIAlertController(title: "Message", message: "gagal", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }else{
                    let alert = UIAlertController(title: "Message", message: "Post Trip Berhasil", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                       self.handleBack()
                    }))
                    
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
    
    @objc private func handleBack(){
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //tampilan
    let myTableView : UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let LabelNegara : UILabel = {
        let label = UILabel()
        label.text = "Negara Tujuan"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let CountryTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
        return textField
    }()
    
    let LabelTanggal : UILabel = {
        let label = UILabel()
        label.text = "Tanggal Kembali"
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
    
    let postButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Post Trip", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePostTrip), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    private func setupView(){
        view.backgroundColor = .white
        let screenWidth = UIScreen.main.bounds.width
        //Label Negara
        view.addSubview(LabelNegara)
        LabelNegara.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
        LabelNegara.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: screenWidth / -2).isActive = true
        
        //CountryTextField
        view.addSubview(CountryTextField)
        CountryTextField.topAnchor.constraint(equalTo: LabelNegara.bottomAnchor, constant: 10).isActive = true
        CountryTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //CountryTextField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        CountryTextField.font = UIFont.systemFont(ofSize: 17)
        CountryTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: screenWidth / -2).isActive = true
        CountryTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        CountryTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 30).isActive = true
        
        //Label Tanggal
        view.addSubview(LabelTanggal)
        LabelTanggal.topAnchor.constraint(equalTo: CountryTextField.bottomAnchor, constant: 50).isActive = true
        LabelTanggal.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: screenWidth / -2).isActive = true
        
        //Date
        view.addSubview(dateTextField)
        dateTextField.topAnchor.constraint(equalTo: LabelTanggal.bottomAnchor, constant: 10).isActive = true
        dateTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dateTextField.font = UIFont.systemFont(ofSize: 17)
        dateTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: screenWidth / -2).isActive = true
        dateTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        dateTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 30).isActive = true
        
        //PostButton
        view.addSubview(postButton)
        postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: screenWidth / -2).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        postButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 120).isActive = true
        postButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 120).isActive = true
        postButton.topAnchor.constraint(greaterThanOrEqualTo: dateTextField.bottomAnchor, constant: 70).isActive = true
    }
}
