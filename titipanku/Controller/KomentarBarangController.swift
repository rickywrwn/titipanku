//
//  KomentarBarangController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 23/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit

class KomentarBarangController :  UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var app: App? {
        didSet {
            
            if app?.Screenshots != nil {
                return
            }
            
            if let id = app?.id {
                let urlString = "http://45.76.178.35/titipanku/DetailBarang.php?id=\(id)"
                
                URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                    
                    guard let data = data else { return }
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    do {
                        
                        let decoder = JSONDecoder()
                        let appDetail = try decoder.decode(App.self, from: data)
                        
                        self.app = appDetail
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.collectionView?.reloadData()
                        })
                        
                    } catch let err {
                        print(err)
                    }
                    
                    
                }).resume()
            }
        }
    }
    
    //
    
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
