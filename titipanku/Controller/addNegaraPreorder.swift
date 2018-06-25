//
//  AddNegaraPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 25/06/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

class AddNegaraPreorder :  UIViewController{
    var dateBack : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        if PostPreorder.varNegara.status != 0 {
            negaraText.text = PostPreorder.varNegara.negara
            dateTextField.text =  PostPreorder.varNegara.deadline
        }
        
        setupView()
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    @objc func handleSubmit(){
        PostPreorder.varNegara.negara = negaraText.text!
        PostPreorder.varNegara.deadline = dateBack
        PostPreorder.varNegara.status = 1
        
        print(PostPreorder.varNegara.negara.self)
        self.dismiss(animated: true)
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
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    
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
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
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
    
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.keyboardDismissMode = .interactive
        return v
    }()
    
    func setupView(){
        let screenWidth = UIScreen.main.bounds.width
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.backgroundColor = UIColor.white
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Negara Pembelian"
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
        scrollView.contentSize = CGSize(width: view.frame.size.width - 16 , height: 850)
        
        
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 8.0).isActive = true
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
        
        //Label Tanggal
        scrollView.addSubview(LabelTanggal)
        LabelTanggal.topAnchor.constraint(equalTo: negaraText.bottomAnchor, constant: 50).isActive = true
        LabelTanggal.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        //Date
        view.addSubview(dateTextField)
        dateTextField.topAnchor.constraint(equalTo: LabelTanggal.bottomAnchor, constant: 10).isActive = true
        dateTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dateTextField.font = UIFont.systemFont(ofSize: 17)
        dateTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        dateTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        dateTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 30).isActive = true
        
    }
    
    
}

