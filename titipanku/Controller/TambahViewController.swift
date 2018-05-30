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
    
    let navSegmentControl = UISegmentedControl()
    let containerView = UIView()
    
    lazy var BarangVC: PostBarang = {
        let vc = PostBarang()
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var TripVC: PostNegara = {
        let vc = PostNegara()
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var PreorderVC: PostPreorder = {
        let vc = PostPreorder()
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
    
    @objc private func handleBack(){
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
        }else if sender.selectedSegmentIndex == 1{
            BarangVC.view.isHidden = false
            TripVC.view.isHidden = true
            PreorderVC.view.isHidden = true
        }else {
            BarangVC.view.isHidden = true
            TripVC.view.isHidden = true
            PreorderVC.view.isHidden = false
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
        
        navSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        navSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        navSegmentControl.heightAnchor.constraint(equalToConstant: 35).isActive = true
        navSegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        navSegmentControl.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        navSegmentControl.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 30).isActive = true
        
        //backButton
        view.addSubview(backButton)
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
