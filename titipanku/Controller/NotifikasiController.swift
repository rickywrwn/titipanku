//
//  NotifikasiController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 23/07/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NotifikasiController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    var trips = [trip]()
    struct trip: Decodable {
        let country: String
        let tanggalPulang: String
        
    }
    
    fileprivate let tripCellId = "tripCellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("Post Trip")
        
        fetchUserTrip()
        //init tableview
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(TripsCell.self, forCellWithReuseIdentifier: tripCellId)
       
        setupView()
    }
    private func setupView(){
        view.backgroundColor = .white
        let screenWidth = UIScreen.main.bounds.width
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        //collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 58).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 5).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: 700).isActive = true
        
        
        
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tripCellId, for: indexPath) as! TripsCell
        
        
        cell.labelCountry.text = trips[indexPath.row].country
        cell.LabelTgl.text = trips[indexPath.row].tanggalPulang
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trips.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 150)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.gray.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // change 2 to desired number of seconds
            cell?.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
    
    fileprivate func fetchUserTrip() {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            
            let urlString = "http://titipanku.xyz/api/GetTrip.php?email=\(String(describing: emailNow))"
            guard let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { (data, _, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        print("Failed to get data from url:", err)
                        return
                    }
                    
                    guard let data = data else { return }
                    do {
                        let decoder = JSONDecoder()
                        self.trips = try decoder.decode([trip].self, from: data)
                        self.collectionView?.reloadData()
                        print(self.trips)
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                    }
                }
                }.resume()
        }
    }
    
    
}




