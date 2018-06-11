//
//  KomentarBarangController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 23/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit

class KomentarBarangController :  UICollectionViewController, UICollectionViewDelegateFlowLayout {
    override func viewDidLoad() {
        super.viewDidLoad()
        //        UserDefaults.standard.set(false, forKey:"logged")
        //        UserDefaults.standard.synchronize()
        // Do any additional setup after loading the view.
        //view.backgroundColor = UIColor.white
        navigationItem.title = "Komentar"
        collectionView?.backgroundColor = UIColor.white
        print("Komentar Barang Loaded")
        
    }
    
    
}
