//
//  AddDetailBarang.swift
//  titipanku
//
//  Created by Ricky Wirawan on 11/06/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

class AddDetailBarang :  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
     var imgBarang: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        if PostBarang.varDetail.status != 0 {
            BarangImageView.image = PostBarang.varDetail.gambarBarang
            nameText.text = PostBarang.varDetail.namaBarang
            qtyText.text = PostBarang.varDetail.qty
            descText.text = PostBarang.varDetail.desc
            categoryText.text = PostBarang.varDetail.kategori
        }
        
        setupView()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    @objc func handleCancle(){
         self.dismiss(animated: true)
    }
    
    @objc func handleSubmit(){
        
        PostBarang.varDetail.gambarBarang = imgBarang
        PostBarang.varDetail.namaBarang = nameText.text!
        PostBarang.varDetail.qty = qtyText.text!
        PostBarang.varDetail.desc = descText.text!
        PostBarang.varDetail.kategori = categoryText.text!
        PostBarang.varDetail.status = 1
        
        print(PostBarang.varDetail.namaBarang.self)
        
        // untuk melakukan reload Collectionview di Post Barang
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc func textFieldTapped(_ textField: UITextField) {
        
        print("tapped")
        StringPickerPopover(title: "Kategori Barang", choices: ["Elektronik","Makanan dan Minuman","Fashion Pria","Fashion Wanita","Produk Kecantikan","Peralatan Rumah Tangga","Barang Koleksi","Lainnya"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.categoryText.text = selectedString
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: textField, baseViewController: self)
        
    }
    
    @objc func qtyTapped(_ textField: UITextField) {
        
        print("tapped")
        StringPickerPopover(title: "Jumlah Barang", choices: ["1","2","3","4","5","6","7","8","9","10"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.qtyText.text = selectedString
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: textField, baseViewController: self)
        
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
            
            
        }))
        self.present(alert, animated: true, completion: nil)
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
            BarangImageView.image = selectedImage
            imgBarang = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
   
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    
    //lazy var supaya mau akses self
    lazy var BarangImageView: UIImageView = {
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
    
    let label1 : UILabel = {
        let label = UILabel()
        label.text = "Nama Barang"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let label2 : UILabel = {
        let label = UILabel()
        label.text = "Kuantitas"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let qtyText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(qtyTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let label3 : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Deskripsi Barang"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descText : UITextView = {
        let textField = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 3
        textField.layer.borderColor =  UIColor.gray.cgColor
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let label4 : UILabel = {
        let label = UILabel()
        label.text = "Kategori"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let categoryText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.keyboardDismissMode = .interactive
        return v
    }()
    
    func setupView(){
        
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.backgroundColor = UIColor.white
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Detail Barang"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Batal", style: .done, target: self, action: #selector(handleCancle))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navigationBar)
        navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        navigationBar.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        
        
        // add the scroll view to self.view
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.size.width - 16 , height: 1150)
        
        
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true

        
        scrollView.addSubview(BarangImageView)
        BarangImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true //anchor ke scrollview
        BarangImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        BarangImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        BarangImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        scrollView.addSubview(label1)
        label1.topAnchor.constraint(equalTo: BarangImageView.bottomAnchor, constant: 30).isActive = true
        label1.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(nameText)
        nameText.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 10).isActive = true
        nameText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameText.font = UIFont.systemFont(ofSize: 25)
        nameText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        nameText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(label2)
        label2.topAnchor.constraint(equalTo: nameText.bottomAnchor, constant: 30).isActive = true
        label2.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(qtyText)
        qtyText.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 10).isActive = true
        qtyText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        qtyText.font = UIFont.systemFont(ofSize: 25)
        qtyText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qtyText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        qtyText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(label3)
        label3.topAnchor.constraint(equalTo: qtyText.bottomAnchor, constant: 30).isActive = true
        label3.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        scrollView.addSubview(descText)
        descText.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 10).isActive = true
        descText.heightAnchor.constraint(equalToConstant: 150).isActive = true
        descText.font = UIFont.systemFont(ofSize: 25)
        descText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        descText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(label4)
        label4.topAnchor.constraint(equalTo: descText.bottomAnchor, constant: 30).isActive = true
        label4.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(categoryText)
        categoryText.topAnchor.constraint(equalTo: label4.bottomAnchor, constant: 10).isActive = true
        categoryText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        categoryText.font = UIFont.systemFont(ofSize: 25)
        categoryText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        categoryText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        categoryText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
    }
    
}
