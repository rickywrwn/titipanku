//
//  InboxController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 16/04/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InboxController: UIViewController {
    struct varInbox {
        static var statusInbox = ""
        
    }
    let navSegmentControl = UISegmentedControl()
    let containerView = UIView()
    
    let layout = UICollectionViewFlowLayout()
    
    lazy var NotifVC: NotifikasiController = {
        let vc = NotifikasiController()
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    lazy var PesanVC: PesanController = {
        let vc = PesanController()
        //let vc = PesanController(collectionViewLayout: layout)
        self.addAsChildVC(childVC: vc)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupView()
        
        navigationItem.title = "Home"
        
        NotifVC.view.isHidden = false
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
            PesanVC.view.isHidden = true
            NotifVC.view.isHidden = false
            varInbox.statusInbox = "notif"
        }else if sender.selectedSegmentIndex == 1{
            PesanVC.view.isHidden = false
            NotifVC.view.isHidden = true
            varInbox.statusInbox = "pesan"
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadBarang"), object: nil)
        }
    }
    
    
    func setupView(){
        let screenHeight = UIScreen.main.bounds.height
        view.backgroundColor = .white
        
        navSegmentControl.addTarget(self, action: #selector(madeSelection), for: .valueChanged)
        
        navSegmentControl.insertSegment(withTitle: "Notifikasi", at: 0, animated: false)
        navSegmentControl.insertSegment(withTitle: "Pesan", at: 1, animated: false)
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
        navSegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        navSegmentControl.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        navSegmentControl.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 30).isActive = true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

