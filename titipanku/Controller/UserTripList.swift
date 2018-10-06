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

struct trip: Decodable {
    let id: String
    let country: String
    let tanggalPulang: String
    let status : String
    
}

class UserTripList: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    var trips = [trip]()
    var isiUser  : userDetail?
    
    
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
        
        //supaya navbar full
        // Create the navigation bar
        let screenSize: CGRect = UIScreen.main.bounds
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 0))
        navbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navbar)
        navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        navbar.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor).isActive = true
        
        // Offset by 20 pixels vertically to take the status bar into account
        navbar.backgroundColor = UIColor(hex: "#3867d6")
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Daftar Trip"
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Titip Juga", style: .plain, target: self, action: #selector(handleTitip))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "kembali", style: .done, target: self, action: #selector(handleBack))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        
        //collectionView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: screenWidth/4).isActive = true
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: 0).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        
    }
    
    @objc public func handleBack(){
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tripCellId, for: indexPath) as! TripsCell
        
        cell.labelCountry.text = trips[indexPath.row].country
        cell.LabelTgl.text = trips[indexPath.row].tanggalPulang
        if trips[indexPath.row].status == "1"{
            cell.LabelStatus.text = "Belum Pulang"
        }else{
            cell.LabelStatus.text = "Sudah Pulang"
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trips.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 120)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.gray.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // change 2 to desired number of seconds
            cell?.layer.backgroundColor = UIColor.white.cgColor
            if let trip : trip = self.trips[indexPath.row] {
                let layout = UICollectionViewFlowLayout()
                layout.minimumInteritemSpacing = 0
                layout.minimumLineSpacing = 0
                let addDetail = UserTripDetail()
                addDetail.tripUser = trip
                addDetail.isiUser = self.isiUser
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.present(addDetail, animated: false, completion: nil)
            }else{
                print("no app")
            }
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
                        if self.trips.count <= 0 {
                            let alert = UIAlertController(title: "Message", message: "Tidak ada Trip untuk ditampilkan", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
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
    
    let labelC : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Status : "
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
    
    let LabelStatus : UILabel = {
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
        addSubview(labelC)
        addSubview(labelCountry)
        addSubview(LabelTgl)
        addSubview(LabelStatus)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-10-[v0]-5-[v1]", views: labelA,labelCountry) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-10-[v0]-5-[v1]", views: labelB,LabelTgl)
        addConstraintsWithFormat("H:|-10-[v0]-5-[v1]", views: labelC,LabelStatus)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-10-[v0]-5-[v1]-5-[v2]", views: labelA,labelB,labelC)
        addConstraintsWithFormat("V:|-10-[v0]-5-[v1]-5-[v2]", views: labelCountry,LabelTgl,LabelStatus )
        addConstraintsWithFormat("V:|[v0(1)]", views: dividerLineView )
        
    }
    
}



