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

    struct varNegara {
        static var negara = ""
        
    }
    let navSegmentControl = UISegmentedControl()
    let containerView = UIView()
    
    let layout = UICollectionViewFlowLayout()
    lazy var BarangVC: ExploreNegaraRequest = {
        let vc = ExploreNegaraRequest(collectionViewLayout: layout)
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var TripVC: ExploreNegaraPreorder = {
        let vc = ExploreNegaraPreorder(collectionViewLayout: layout)
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var PreorderVC: ExploreNegaraPreorderBerdurasi = {
        let vc = ExploreNegaraPreorderBerdurasi(collectionViewLayout: layout)
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupView()
        TripVC.view.isHidden = false
    }
    
    @objc public func handleBack(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadExplore"), object: nil)
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
            varNegara.negara = "Request"
        }else if sender.selectedSegmentIndex == 1{
            BarangVC.view.isHidden = false
            TripVC.view.isHidden = true
            PreorderVC.view.isHidden = true
            varNegara.negara = "Preorder"
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
        }else {
            BarangVC.view.isHidden = true
            TripVC.view.isHidden = true
            PreorderVC.view.isHidden = false
            varNegara.negara = "Durasi"
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadPreorder"), object: nil)
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
        navSegmentControl.insertSegment(withTitle: "Preorder", at: 1, animated: false)
        navSegmentControl.insertSegment(withTitle: "Preorder Berdurasi", at: 2, animated: false)
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
