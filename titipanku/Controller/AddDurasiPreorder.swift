//
//  AddDurasiPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 17/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

class AddDurasiPreorder :  UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var detik : Double = 0.0
    let pilihanBatas : [String] = ["Ya","Tidak"]
    var selectedBatas : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        if PostPreorder.varDurasi.status != 0 {
            countdownText.text = PostPreorder.varDurasi.countdownText
            
            if PostPreorder.varDurasi.statusBatas != 0 {
                label2.isHidden = false
                countdownText.isHidden = false
                batasText.text = "Ya"
            }else{
                label2.isHidden = true
                countdownText.isHidden = true
                batasText.text = "Tidak"
            }
        }else{
            label2.isHidden = true
            countdownText.isHidden = true
        }
        
        setupView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 4{
            if indexPath.row == 0{
                print("Num: \(indexPath.row)")
                print("Value: \(pilihanBatas[indexPath.row])")
                batasText.text = pilihanBatas[indexPath.row]
                batasTableView.isHidden = true
                selectedBatas = 1
                label2.isHidden = false
                countdownText.isHidden = false
            }else{
                print("Num: \(indexPath.row)")
                print("Value: \(pilihanBatas[indexPath.row])")
                batasText.text = pilihanBatas[indexPath.row]
                batasTableView.isHidden = true
                selectedBatas = 0
                label2.isHidden = true
                countdownText.isHidden = true
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 4{
            
            return pilihanBatas.count
        }
        return pilihanBatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 4{
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
            let pilihan = pilihanBatas[indexPath.row]
            cell.textLabel?.text = pilihan
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            return cell
        }
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        let pilihan = pilihanBatas[indexPath.row]
        cell.textLabel?.text = pilihan
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        return cell
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    @objc func handleSubmit(){
        if selectedBatas == 1{
            if  countdownText.text != "" {
                PostPreorder.varDurasi.countdownText = countdownText.text!
                PostPreorder.varDurasi.countdownValue = detik
                PostPreorder.varDurasi.batasWaktu = "1"
                PostPreorder.varDurasi.statusBatas = 1
                PostPreorder.varDurasi.status = 1
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
                self.dismiss(animated: true)
            }else{
                let alert = UIAlertController(title: "Peringatan", message: "Data Tidak Boleh Kosong", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            if  batasText.text != "" {
                PostPreorder.varDurasi.statusBatas = 0
                PostPreorder.varDurasi.batasWaktu = "0"
                PostPreorder.varDurasi.status = 1
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
                self.dismiss(animated: true)
            }else{
                let alert = UIAlertController(title: "Peringatan", message: "Data Tidak Boleh Kosong", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func countdownTapped(_ textField: UITextField) {
        
        CountdownPickerPopover(title: "Lama Waktu Penjualan")
            .setSelectedTimeInterval(TimeInterval())
            .setDoneButton(action: { popover, timeInterval in print("timeInterval \(timeInterval)")
                self.detik = timeInterval
                let (h, m, s) = self.secondsToHoursMinutesSeconds (seconds: Int(timeInterval))
                if(m > 0){
                    print ("\(h) Jam, \(m) Menit")
                    self.countdownText.text = "\(h) Jam, \(m) Menit"
                }else {
                    print ("\(h) Jam")
                    self.countdownText.text = "\(h) Jam"
                }
                print(self.detik)
                
            } )
            .setCancelButton(action: { _, _ in print("cancel")})
            .setClearButton(action: { popover, timeInterval in print("Clear")
                popover.setSelectedTimeInterval(TimeInterval()).reload()
            })
            .appear(originView: textField, baseViewController: self)
        
    }
    
    @objc func textBatasTapped(_ textField: UITextField) {
        
        //init tableview
        //bug untuk pemilihan negara kedua
        batasTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        batasTableView.dataSource = self
        batasTableView.delegate = self
        batasTableView.tag = 4
        self.view.addSubview(batasTableView)
        batasTableView.topAnchor.constraint(equalTo: batasText.bottomAnchor, constant: 12).isActive = true
        batasTableView.leftAnchor.constraint( equalTo: batasText.leftAnchor).isActive = true
        batasTableView.rightAnchor.constraint(equalTo: batasText.rightAnchor).isActive = true
        batasTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        batasTableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        batasTableView.layer.borderWidth = 1
        batasTableView.layer.borderColor = UIColor.black.cgColor
        batasTableView.isHidden = false
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    
    
    let batasTableView : UITableView = {
        let t = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let label3 : UILabel = {
        let label = UILabel()
        label.text = "Batas Waktu"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let batasText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textBatasTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
    }()
    
    let label2 : UILabel = {
        let label = UILabel()
        label.text = "Lama Penjualan"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let countdownText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(countdownTapped(_:)),
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
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.backgroundColor = UIColor.white
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Durasi Preorder"
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
        scrollView.contentSize = CGSize(width: view.frame.size.width - 16 , height: view.frame.size.height)
        
        
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        
        scrollView.addSubview(label3)
        label3.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
        label3.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(batasText)
        batasText.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 10).isActive = true
        batasText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        batasText.font = UIFont.systemFont(ofSize: 25)
        batasText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        batasText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        batasText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        scrollView.addSubview(label2)
        label2.topAnchor.constraint(equalTo: batasText.bottomAnchor, constant: 10).isActive = true
        label2.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(countdownText)
        countdownText.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 10).isActive = true
        countdownText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        countdownText.font = UIFont.systemFont(ofSize: 25)
        countdownText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        countdownText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        countdownText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
        
    }
    
    
}

