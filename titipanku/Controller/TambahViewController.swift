//
//  TambahViewController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 17/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TambahViewController: UIViewController {
    struct varTambah {
        static var statusTambah = ""
        
    }
    let navSegmentControl = UISegmentedControl()
    let containerView = UIView()
    
    let layout = UICollectionViewFlowLayout()
    lazy var BarangVC: PostBarang = {
        let vc = PostBarang(collectionViewLayout: layout)
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var TripVC: PostNegara = {
        let vc = PostNegara()
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var PreorderVC: PostPreorder = {
        let vc = PostPreorder(collectionViewLayout: layout)
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupView()
        
        navigationItem.title = "Home"
        
        TripVC.view.isHidden = false
    }
    
    @objc public func handleBack(){
        PostBarang.varDetail.namaBarang = ""
        PostBarang.varDetail.desc = ""
        PostBarang.varDetail.qty = ""
        PostBarang.varDetail.kategori = ""
        PostBarang.varDetail.url = ""
        PostBarang.varDetail.status = 0
        
        PostBarang.varKarateristik.ukuran = ""
        PostBarang.varKarateristik.berat = ""
        PostBarang.varKarateristik.status = 0
        
        PostBarang.varNegara.negara = ""
        PostBarang.varNegara.kota = ""
        PostBarang.varNegara.provinsi = ""
        PostBarang.varNegara.idKota = ""
        PostBarang.varNegara.status = 0
        
        PostBarang.varHarga.harga = ""
        PostBarang.varHarga.status = 0
        
        PostPreorder.varDetail.namaBarang = ""
        PostPreorder.varDetail.brand = ""
        PostPreorder.varDetail.desc = ""
        PostPreorder.varDetail.qty = ""
        PostPreorder.varDetail.kategori = ""
        PostPreorder.varDetail.status = 0
        
        PostPreorder.varKarateristik.berat = ""
        PostPreorder.varKarateristik.status = 0
        
        PostPreorder.varNegara.negara = ""
        PostPreorder.varNegara.kota = ""
        PostPreorder.varNegara.deadline = ""
        PostPreorder.varNegara.status = 0
        
        
        PostPreorder.varHarga.harga = ""
        PostPreorder.varHarga.status = 0
        
        PostPreorder.varDurasi.batasWaktu = ""
        PostPreorder.varDurasi.countdownText = ""
        PostPreorder.varDurasi.countdownValue = 0.0
        PostPreorder.varDurasi.status = 0
        
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func addAsChildVC(childVC: UIViewController) {
        addChildViewController(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = self.view.frame
        childVC.didMove(toParentViewController: self)
    }
    
    private func removeAsChildVC(childVC: UIViewController) {
        childVC.willMove(toParentViewController: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParentViewController()
    }
    
    @objc func madeSelection(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            BarangVC.view.isHidden = true
            PreorderVC.view.isHidden = true
            TripVC.view.isHidden = false
            varTambah.statusTambah = "preorder"
        }else if sender.selectedSegmentIndex == 1{
            BarangVC.view.isHidden = false
            TripVC.view.isHidden = true
            PreorderVC.view.isHidden = true
            varTambah.statusTambah = "barang"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
        }else {
            BarangVC.view.isHidden = true
            TripVC.view.isHidden = true
            PreorderVC.view.isHidden = false
            varTambah.statusTambah = "preorder"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
        }
    }
    
    func setupView(){
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
        navigationItem.title = "Post"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleBack))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        
        let screenHeight = UIScreen.main.bounds.height
        view.backgroundColor = .white
        
        navSegmentControl.addTarget(self, action: #selector(madeSelection), for: .valueChanged)
        
        navSegmentControl.insertSegment(withTitle: "Post Trip", at: 0, animated: false)
        navSegmentControl.insertSegment(withTitle: "Titip Barang", at: 1, animated: false)
        navSegmentControl.insertSegment(withTitle: "Titipan Durasi", at: 2, animated: false)
        navSegmentControl.selectedSegmentIndex = 0
        
        view.addSubview(containerView)
        view.addSubview(navSegmentControl)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55).isActive = true
        
        navSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        navSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        navSegmentControl.heightAnchor.constraint(equalToConstant: 35).isActive = true
        navSegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55).isActive = true
        navSegmentControl.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        navSegmentControl.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 30).isActive = true
        

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
