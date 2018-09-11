//
//  UserEdit.swift
//  titipanku
//
//  Created by Ricky Wirawan on 12/09/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyPickerPopover
import SwiftyJSON
import Alamofire_SwiftyJSON
import MidtransKit

class UserEdit :  UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var cekGambar = false
    
    struct userDetail: Decodable {
        let email: String
        let name: String
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
                        
                        self.ongkirText.text = self.isiUser?.name
                        DispatchQueue.main.async{
                            Alamofire.request("http://titipanku.xyz/uploads/"+(self.isiUser?.email)!+".jpg").responseImage { response in
                                if let image = response.result.value {
                                    self.imageView.image = image
                                    
                                }
                            }
                        }
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                    }
                }
                }.resume()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        fetchJSON()
        
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
        navigationItem.title = "Edit Profile"
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Titip Juga", style: .plain, target: self, action: #selector(handleTitip))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(btnCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleTerimaOffer))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        setupView()
    }
    
    @objc private func btnCancel(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imgTapped(_ imageView: UIImageView) {
        print("tapped gambar")
        
        let alert = UIAlertController(title: "Choose one of the following:", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.openCamera()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print(info)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            imageView.image = selectedImage
            cekGambar = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleTerimaOffer(){
        
        if(ongkirText.text == "" ){
            let alert = UIAlertController(title: "Message", message: "Data Harus Terisi Semua", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }else{
            
            // create the alert
            let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin ?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Batal", style: UIAlertActionStyle.cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ya", style: UIAlertActionStyle.default, handler: { action in
                
                if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let nama = self.ongkirText.text{
                    
                    let parameter: Parameters = ["email":emailNow,"nama":nama,"action":"edit","action2" : "tidak"]
                    print (parameter)
                    Alamofire.request("http://titipanku.xyz/api/EditProfile.php",method: .get, parameters: parameter).responseJSON {
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
                            
                            let imgData = UIImageJPEGRepresentation(self.imageView.image!, 0.1)!
                            
                            let parameters = ["name": "Frank","email": emailNow,"action" : "edit","action2" : "upload"]
                            print(parameters)
                            //userfile adalah parameter post untuk file yg ingin di upload
                            Alamofire.upload(multipartFormData: { multipartFormData in
                                multipartFormData.append(imgData, withName: "userfile",fileName: "file.jpg", mimeType: "image/jpg")
                                for (key, value) in parameters {
                                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                                }
                            },
                                             to:"http://titipanku.xyz/api/uploadPP.php")
                            { (result) in
                                switch result {
                                case .success(let upload, _, _):
                                    
                                    upload.uploadProgress(closure: { (progress) in
                                        print("Upload Progress: \(progress.fractionCompleted)")
                                    })
                                    
                                    upload.responseJSON { response in
                                        print(response.result.value)
                                    }
                                    
                                case .failure(let encodingError):
                                    print(encodingError)
                                }
                            }
                            
                            let alert = UIAlertController(title: "Message", message: "Update Profile Berhasil", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            self.btnCancel()
                                
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
    
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    //tampilan
    
    let labelOngkir : UILabel = {
        let label = UILabel()
        label.text = "Nama "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ongkirText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .left
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let labelImage : UILabel = {
        let label = UILabel()
        label.text = "Profile Picture"
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
        
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:))))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    func setupView(){
        
        
        view.addSubview(labelOngkir)
        labelOngkir.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        labelOngkir.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        view.addSubview(ongkirText)
        ongkirText.topAnchor.constraint(equalTo: labelOngkir.bottomAnchor, constant: 10).isActive = true
        ongkirText.heightAnchor.constraint(equalToConstant: 35).isActive = true
        ongkirText.font = UIFont.systemFont(ofSize: 15)
        ongkirText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        ongkirText.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -150).isActive = true
        
        view.addSubview(labelImage)
        labelImage.topAnchor.constraint(equalTo: ongkirText.bottomAnchor, constant: 30).isActive = true
        labelImage.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: labelImage.bottomAnchor, constant: 10).isActive = true //anchor ke scrollview
        imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    
    }
    
}

