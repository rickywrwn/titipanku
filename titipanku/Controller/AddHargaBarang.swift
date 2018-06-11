//
//  AddHargaBarang.swift
//  titipanku
//
//  Created by Ricky Wirawan on 11/06/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit

class AddHargaBarang :  UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.backgroundColor = UIColor.white
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Harga"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Batal", style: .done, target: self, action: #selector(handleCancle))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navigationBar)
        navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        navigationBar.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        
        print("Komentar Barang Loaded")
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    @objc func handleSubmit(){
        
        
    }
    
    
}

