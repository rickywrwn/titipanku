//
//  WithdrawController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 29/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import MidtransKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

class WithdrawController :  UIViewController {
    
    struct userDetail: Decodable {
        let saldo: String
        let valueSaldo: String
    }
    
    var isiUser  : userDetail?
    var midtrans : Midtrans?
    
    struct Midtrans: Decodable {
        let orderId: String
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
                        
                        
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                    }
                }
                }.resume()
        }
    }
    
    func fetchOrderId(){
        let urlString = "http://titipanku.xyz/api/GetMaxTopup.php"
        
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
        hideKeyboardWhenTappedAround()
        fetchJSON()
        fetchOrderId()
        setupView() // Create the navigation bar
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
        navigationItem.title = "Penarikan Wallet"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
        
        // Assign the navigation item to the navigation bar
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
    
    @objc public func handleCancle(){
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTerimaOffer(){
        print("payment sukses")
        Alamofire.request("http://titipanku.xyz/api/finish.php",method: .get).responseJSON {
            response in
            //mencetak JSON response
            if let json = response.result.value {
                print("JSON: \(json)")
            }
        }
        
        let saldoTotal = Int((self.isiUser?.valueSaldo)!)! - Int(self.hargaText.text!)!
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String , let jumlah = hargaText.text, let saldo : String = String(saldoTotal), let status : String = "pending", let rekening = rekeningText.text,let nama = namaText.text{
            
            let parameter: Parameters = ["jumlah": jumlah,"email":emailNow, "saldo" : saldo ,"status":status,"namaRekening":nama,"rekening":rekening ,"action":"insert"]
            print (parameter)
            Alamofire.request("http://titipanku.xyz/api/PostWithdraw.php",method: .get, parameters: parameter).responseJSON {
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
                    let alert = UIAlertController(title: "Message", message: "Permintaan Withdraw Berhasil", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.handleBack()
                    }))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    @objc private func handleBack(){
        self.dismiss(animated: true, completion: nil)
    }
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 35)
    //tampilan
    
    let ongkirTableView : UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Jumlah Penarikan (Dalam Rupiah)"
        label.font = UIFont.systemFont(ofSize: 28)
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
    
    
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Rekening Penarikan"
        label.font = UIFont.systemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let rekeningText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let labelC : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Nama Pemilik Rekening"
        label.font = UIFont.systemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let namaText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let postButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Withdraw", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor.blue
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
    
    func setupView(){
        
        let screenWidth = UIScreen.main.bounds.width+10
        
        view.addSubview(labelA)
        labelA.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        labelA.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        labelA.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        view.addSubview(hargaText)
        hargaText.topAnchor.constraint(equalTo: labelA.bottomAnchor, constant: 10).isActive = true
        hargaText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        hargaText.font = UIFont.systemFont(ofSize: 25)
        hargaText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hargaText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        hargaText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        view.addSubview(labelB)
        labelB.topAnchor.constraint(equalTo: hargaText.bottomAnchor, constant: 20).isActive = true
        labelB.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        labelB.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        view.addSubview(rekeningText)
        rekeningText.topAnchor.constraint(equalTo: labelB.bottomAnchor, constant: 10).isActive = true
        rekeningText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        rekeningText.font = UIFont.systemFont(ofSize: 25)
        rekeningText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rekeningText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        rekeningText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        view.addSubview(labelC)
        labelC.topAnchor.constraint(equalTo: rekeningText.bottomAnchor, constant: 20).isActive = true
        labelC.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        labelC.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
        view.addSubview(namaText)
        namaText.topAnchor.constraint(equalTo: labelC.bottomAnchor, constant: 10).isActive = true
        namaText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        namaText.font = UIFont.systemFont(ofSize: 25)
        namaText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        namaText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        namaText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        view.addSubview(postButton)
        postButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        postButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80).isActive = true
        postButton.widthAnchor.constraint(equalToConstant: screenWidth-15).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    
    }
}
