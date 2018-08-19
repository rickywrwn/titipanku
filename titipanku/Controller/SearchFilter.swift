//
//  SearchFilter.swift
//  titipanku
//
//  Created by Ricky Wirawan on 20/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

class SearchFilter: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
       
        
        setupView()
    }
    
    @objc func ukuranTapped(_ textField: UITextField) {
        
        print("tapped")
        StringPickerPopover(title: "Ukuran Barang", choices: ["Kecil (20x20x20 CM)", "Sedang ( 30x25x20 CM)","Besar (35x22x55 CM)"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.ukuranText.text = selectedString
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: textField, baseViewController: self)
        
    }
    
    @objc func beratTapped(_ textField: UITextField) {
        
        print("tapped")
        StringPickerPopover(title: "Berat Barang", choices: ["1 Kg","2 Kg","3 Kg","4 Kg","5 Kg"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.beratText.text = selectedString
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: textField, baseViewController: self)
        
    }
    
    let TEXTFIELD_HEIGHT = CGFloat(integerLiteral: 30)
    
    let label1 : UILabel = {
        let label = UILabel()
        label.text = "Ukuran Barang"
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
        label.text = "Berat Barang"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let beratText : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(beratTapped(_:)),
                            for: UIControlEvents.touchDown)
        textField.inputView = UIView();
        return textField
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
        
    }
    
    
}

