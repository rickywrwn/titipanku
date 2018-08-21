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
        setupView()
        
    }
    
    private func setupView(){
        let backButton : UIButton = {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            button.setTitle("Cancel", for: .normal)
            button.setTitleColor(button.tintColor, for: .normal) // You can change the TitleColor
            button.addTarget(self, action: #selector(handleBack), for: UIControlEvents.touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        
        //collectionView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: screenWidth/4).isActive = true
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        //backButton
        view.addSubview(backButton)
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
    }
    
    @objc public func handleBack(){
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
        
        return CGSize(width: view.frame.width, height: 50)
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
        if let emailNow : String = UserController.emailUser.email {
            
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



