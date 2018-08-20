//
//  FilterPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 20/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

class FilterPreorder: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var countries = [country]()
    struct country: Decodable {
        let name: String
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FilterPreorder.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FilterPreorder.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setupView()
        ukuranText.text = "Semua Kategori"
        beratText.text = "Semua Negara"
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Num: \(indexPath.row)")
        print("Value: \(countries[indexPath.row])")
        beratText.text = countries[indexPath.row].name
        myTableView.isHidden = true
        self.dismissKeyboard()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        fetchNegara(nama: textField.text!)
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.tag = 0
        self.view.addSubview(myTableView)
        myTableView.topAnchor.constraint(equalTo: beratText.bottomAnchor, constant: 12).isActive = true
        myTableView.leftAnchor.constraint( equalTo: beratText.leftAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: beratText.rightAnchor).isActive = true
        myTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        myTableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        myTableView.layer.borderWidth = 1
        myTableView.layer.borderColor = UIColor.black.cgColor
        
        myTableView.isHidden = false
    }
    
    @objc func ukuranTapped(_ textField: UITextField) {
        
        print("tapped")
        StringPickerPopover(title: "Kategori", choices: ["Semua Kategori","Elektronik","Makanan","Pakaian"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.ukuranText.text = selectedString
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: textField, baseViewController: self)
        
    }
    
    @objc func handleApply(){
        self.dismissKeyboard()
        var itung : Int = 0
        if ukuranText.text == "Semua Kategori"{
            itung = itung + 1
        }
        if beratText.text == "Semua Negara"{
            itung = itung + 2
        }
        
        if itung == 1{
            SearchPreorder.varFilter.search = "negara"
            SearchPreorder.varFilter.negara = beratText.text!
        }else if itung == 2 {
            SearchPreorder.varFilter.search = "kategori"
            SearchPreorder.varFilter.kategori = ukuranText.text!
        }else if itung == 3 {
            SearchPreorder.varFilter.search = "none"
        }else{
            SearchPreorder.varFilter.search = "semua"
            SearchPreorder.varFilter.kategori = ukuranText.text!
            SearchPreorder.varFilter.negara = beratText.text!
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPreorder"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleCancel(){
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    let myTableView : UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let label1 : UILabel = {
        let label = UILabel()
        label.text = "Kategori"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ukuranText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(ukuranTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let label2 : UILabel = {
        let label = UILabel()
        label.text = "Negara"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let beratText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
        return textField
    }()
    
    let postButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Apply", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor.blue
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleApply), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    let declineButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.cyan, for: .selected)
        button.backgroundColor = UIColor.red
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleCancel), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.keyboardDismissMode = .interactive
        v.delaysContentTouches = false
        return v
    }()
    
    func setupView(){
        
        
        // add the scroll view to self.view
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.size.width - 16 , height: 250)
        let screenWidth = UIScreen.main.bounds.width+10
        
        
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 250.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        
        
        scrollView.addSubview(label1)
        label1.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true //anchor ke scrollview
        label1.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(ukuranText)
        ukuranText.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 10).isActive = true
        ukuranText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        ukuranText.font = UIFont.systemFont(ofSize: 25)
        ukuranText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ukuranText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        ukuranText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(label2)
        label2.topAnchor.constraint(equalTo: ukuranText.bottomAnchor, constant: 30).isActive = true
        label2.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(beratText)
        beratText.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 10).isActive = true
        beratText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        beratText.font = UIFont.systemFont(ofSize: 25)
        beratText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        beratText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        beratText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
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


