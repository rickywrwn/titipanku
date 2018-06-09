//
//  registerController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 10/04/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class registerController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupView()
    }
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    
    let labelEmail : UILabel = {
        let label = UILabel()
        label.text = "Email:"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Password:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let passwordTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let confPasswordLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Confirmation Password:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let confPasswordTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let fullNameLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Full Name:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let fullNameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    let registerButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(handleRegister), for: UIControlEvents.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let backButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        //backButton.setImage(UIImage(named: "BackButton.png"), for: .normal) // Image can be downloaded from here below link
        button.setTitle("Back", for: .normal)
        button.setTitleColor(button.tintColor, for: .normal) // You can change the TitleColor
        button.addTarget(self, action: #selector(handleBack), for: UIControlEvents.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //klik register
    @objc private func handleRegister(){
        
        //cekOngkir(origin: "501",destination: "114",weight: "1000")
        
        let parameters: Parameters = ["email": emailTextField.text!,"password": passwordTextField.text!, "name" : fullNameTextField.text! ,"action" : "register"]
        Alamofire.request("http://localhost/titipanku/Login.php",method: .get, parameters: parameters).responseJSON {
            response in

            //mencetak JSON response
            if let json = response.result.value {
                print("JSON: \(json)")
            }

            //mengambil json
            let json = JSON(response.result.value)
            print(json)
            let cekSukses = json["success"].intValue
            let pesan = json["message"].stringValue
            
            print(pesan)
            if cekSukses != 1 {
                let alert = UIAlertController(title: "Message", message: "gagal", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))

                self.present(alert, animated: true)
            }else{
                let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.handleBack()
                }))

                self.present(alert, animated: true)
            }

//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//            }
        }
    }
    
    @objc private func handleBack(){
        navigationController?.popViewController(animated: true)
      self.dismiss(animated: true, completion: nil)
    }
    
    func setupView(){
        //LabelEmail
        view.addSubview(labelEmail)
        labelEmail.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        labelEmail.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //EmailTextField
        view.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: labelEmail.bottomAnchor, constant: 10).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTextField.font = UIFont.systemFont(ofSize: 25)
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        emailTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
 
        //PasswordLabel
        view.addSubview(passwordLabel)
        passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30).isActive = true
        passwordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //PasswordTextField
        view.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.font = UIFont.systemFont(ofSize: 25)
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        passwordTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        //ConfPasswordLabel
        view.addSubview(confPasswordLabel)
        confPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30).isActive = true
        confPasswordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //PasswordTextField
        view.addSubview(confPasswordTextField)
        confPasswordTextField.topAnchor.constraint(equalTo: confPasswordLabel.bottomAnchor, constant: 10).isActive = true
        confPasswordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        confPasswordTextField.font = UIFont.systemFont(ofSize: 25)
        confPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confPasswordTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        confPasswordTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        //FUllNameLabel
        view.addSubview(fullNameLabel)
        fullNameLabel.topAnchor.constraint(equalTo: confPasswordTextField.bottomAnchor, constant: 30).isActive = true
        fullNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //FullNameTextField
        view.addSubview(fullNameTextField)
        fullNameTextField.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 10).isActive = true
        fullNameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        fullNameTextField.font = UIFont.systemFont(ofSize: 25)
        fullNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fullNameTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        fullNameTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        //registerButton
        view.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 120).isActive = true
        registerButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 120).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        registerButton.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: 50).isActive = true
        
        //backButton
        view.addSubview(backButton)
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        //backButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        //backButton.centerYAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true

        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cekOngkir(origin:String,destination:String,weight:String) -> (paket: Array<String>,harga: Array<String>) {
        //kalau post dengan header encoding harus URLencoding
        let headers = [
            "key": "590ad699c8c798373e2053a28c7edd1e",
            "content-type": "application/x-www-form-urlencoded"
        ]
        let parameters: Parameters = ["origin": origin,"destination": destination, "weight" : weight, "courier" : "jne"]
        
        var arrNama = [String]()
        var arrHarga = [String]()
        Alamofire.request("https://api.rajaongkir.com/starter/cost",method: .post, parameters: parameters,encoding: URLEncoding.default, headers: headers)
            .responseSwiftyJSON { dataResponse in
                
                
                if let json = dataResponse.value {
                    let hasil = json["rajaongkir"]["results"][0]["costs"]
                    for i in 0 ..< hasil.count {
                        let servis = hasil[i]["service"]
                        let harga = hasil[i]["cost"][0]["value"]
                        print(servis.stringValue)
                        print(harga.stringValue)
                        arrNama.append(servis.stringValue)
                        arrHarga.append(harga.stringValue)
                    }
                    // print(hasil.count)
                    
                }
        }
        return (arrNama,arrHarga)
    }
    
    
    
}
