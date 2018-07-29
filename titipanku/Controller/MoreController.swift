//
//  MoreController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 29/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MoreController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    fileprivate let moreCellId = "moreCellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "More"
        navigationItem.title = "More"
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(MoreCell.self, forCellWithReuseIdentifier: moreCellId)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: moreCellId, for: indexPath) as! MoreCell
        if indexPath.row == 0{
            cell.labelA.text = "Titipanku Wallet"
        }else if indexPath.row == 1{
            cell.labelA.text = "Settings"
        }else {
            cell.labelA.text = "Logout"
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 50)
    }
    
    //logout
    @objc func handleLogout(){
        UserDefaults.standard.set(false, forKey:"logged")
        UserDefaults.standard.synchronize()
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        self.tabBarController?.selectedIndex = 0
        let loginCont = loginController()
        present(loginCont, animated: true, completion: {
            
        })
    }
    
    @objc func handleWallet(){
        let walletCont = WalletController()
        navigationController?.pushViewController(walletCont, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.gray.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // change 2 to desired number of seconds
            if indexPath.row == 0{
                self.handleWallet()
            }else if indexPath.row == 2{
                self.handleLogout()
            }
            cell?.layer.backgroundColor = UIColor.white.cgColor
        }
    }
}

class MoreCell: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "more : "
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-15-[v0]|", views: labelA)
        addConstraintsWithFormat("H:|-15-[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-5-[v0]-5-[v1(1)]|", views: labelA,dividerLineView)
        
    }
    
}




