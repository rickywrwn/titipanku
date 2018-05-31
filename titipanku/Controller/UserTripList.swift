//
//  UserTripList.swift
//  titipanku
//
//  Created by Ricky Wirawan on 31/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class UserTripList: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
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
        
        return CGSize(width: view.frame.width, height: 170)
    }
    
    fileprivate func fetchUserTrip() {
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            let urlString = "http://45.76.178.35/titipanku/GetTrip.php?email=\(String(describing: emailNow))"
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

class TripsCell: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Negara Tujuan : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Tanggal Kembali : "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let labelCountry : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        //        label.layer.borderWidth = 1
        //        label.layer.borderColor = UIColor.green.cgColor
        return label
    }()
    
    let LabelTgl : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
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
        addSubview(labelB)
        addSubview(labelCountry)
        addSubview(LabelTgl)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-4-[v0]-5-[v1]", views: labelA,labelCountry) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-4-[v0]-5-[v1]", views: labelB,LabelTgl) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-4-[v0]-4-[v1]", views: labelA,labelB)
        addConstraintsWithFormat("V:|-4-[v0]-4-[v1]", views: labelCountry,LabelTgl )
        addConstraintsWithFormat("V:|[v0(1)]", views: dividerLineView )
        
    }
    
}



