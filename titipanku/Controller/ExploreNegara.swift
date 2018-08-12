//
//  ExploreNegara.swift
//  titipanku
//
//  Created by Ricky Wirawan on 03/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ExploreNegara: UIViewController {
    struct varTambah {
        static var statusTambah = ""
    }
    
    var isiData : isi?
    let navSegmentControl = UISegmentedControl()
    let containerView = UIView()
    
    let layout = UICollectionViewFlowLayout()
    
    lazy var RequestVC: ExploreNegaraRequest = {
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let vc = ExploreNegaraRequest(collectionViewLayout: layout)
        vc.isiData = self.isiData
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var PreorderVC: ExploreNegaraDurasi = {
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let vc = ExploreNegaraDurasi(collectionViewLayout: layout)
        vc.isiData = self.isiData
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var DurasiVC: ExploreNegaraPreorder = {
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let vc = ExploreNegaraPreorder(collectionViewLayout: layout)
        vc.isiData = self.isiData
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupView()
        
        navigationItem.title = "Home"
        RequestVC.view.isHidden = false
    }
    
    @objc public func handleBack(){
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
            RequestVC.view.isHidden = false
            PreorderVC.view.isHidden = true
            DurasiVC.view.isHidden = true
        }else if sender.selectedSegmentIndex == 1{
            RequestVC.view.isHidden = true
            PreorderVC.view.isHidden = false
            DurasiVC.view.isHidden = true
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
        }else if sender.selectedSegmentIndex == 2{
            RequestVC.view.isHidden = true
            PreorderVC.view.isHidden = true
            DurasiVC.view.isHidden = false
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
        }
    }
    
    let backButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        //backButton.setImage(UIImage(named: "BackButton.png"), for: .normal) // Image can be downloaded from here below link
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(button.tintColor, for: .normal) // You can change the TitleColor
        button.addTarget(self, action: #selector(handleBack), for: UIControlEvents.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func setupView(){
        let screenHeight = UIScreen.main.bounds.height
        view.backgroundColor = .white
        
        navSegmentControl.addTarget(self, action: #selector(madeSelection), for: .valueChanged)
        
        navSegmentControl.insertSegment(withTitle: "Request", at: 0, animated: false)
        navSegmentControl.insertSegment(withTitle: "Durasi", at: 1, animated: false)
        navSegmentControl.insertSegment(withTitle: "Preorder", at: 2, animated: false)
        navSegmentControl.selectedSegmentIndex = 0
        
        view.addSubview(containerView)
        view.addSubview(navSegmentControl)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        navSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        navSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        navSegmentControl.heightAnchor.constraint(equalToConstant: 35).isActive = true
        navSegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55).isActive = true
        navSegmentControl.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        navSegmentControl.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 30).isActive = true
        
        //backButton
        view.addSubview(backButton)
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


