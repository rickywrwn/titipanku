//
//  AddNegaraBarang.swift
//  titipanku
//
//  Created by Ricky Wirawan on 11/06/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit

class AddNegaraBarang :  UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        if PostBarang.varNegara.status != 0 {
            negaraText.text = PostBarang.varNegara.negara
            kotaText.text = PostBarang.varNegara.kota
            
        }
        
        setupView()
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    @objc func handleSubmit(){
        PostBarang.varNegara.negara = negaraText.text!
        PostBarang.varNegara.kota = kotaText.text!
        PostBarang.varNegara.status = 1
        
        print(PostBarang.varNegara.negara.self)
        self.dismiss(animated: true)
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
    
    let label2 : UILabel = {
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
        
        scrollView.addSubview(label2)
        label2.topAnchor.constraint(equalTo: negaraText.bottomAnchor, constant: 30).isActive = true
        label2.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(kotaText)
        kotaText.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 10).isActive = true
        kotaText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        kotaText.font = UIFont.systemFont(ofSize: 25)
        kotaText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        kotaText.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        kotaText.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        
    }
    
    
}

