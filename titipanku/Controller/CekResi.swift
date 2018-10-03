//
//  CekResi.swift
//  titipanku
//
//  Created by Ricky Wirawan on 01/10/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Alamofire
import Hue

class CekResi: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    var collectionview: UICollectionView!
    var nomor = "030520034450018"
    var resi : Welcome?
    var detailsResi : details?
    
    struct Welcome: Decodable {
        let rajaongkir: Rajaongkir
    }
    
    struct Rajaongkir: Decodable {
        let query: Query
        let status: Status
        let result: Result
    }
    
    struct Query: Decodable {
        let waybill, courier: String
    }
    
    struct Result: Decodable {
        let delivered: Bool
        let summary: Summary
        let details: details
        let delivery_status: delivery_status
        let manifest: [Manifest]
    }
    
    struct details: Decodable {
        let waybill_number: String
        let waybill_date: String
        let waybill_time: String
        let weight: String
        let origin: String
        let destination: String
        let shippper_name: String
        let shipper_address1: String
        let shipper_city: String
        let receiver_name: String
        let receiver_address1: String
        let receiver_city: String
    }
    
    struct delivery_status: Decodable {
        let status, pod_receiver, pod_date, pod_time: String
    
    }
    
    struct Manifest: Decodable {
        let manifest_code, manifest_description, manifest_date, manifest_time: String
        let city_name: String
    }
    
    struct Summary: Decodable {
        let courier_code, courier_name, waybill_number, service_code: String
        let waybill_date, shipper_name, receiver_name, origin: String
        let destination, status: String
    }
    
    struct Status: Decodable {
        let code: Int
        let description: String
    }
    
    func fetchResi(){
        //kalau post dengan header encoding harus URLencoding
        let headers = [
            "key": "590ad699c8c798373e2053a28c7edd1e",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        let parameters: Parameters = ["waybill": nomor, "courier" : "jne"]
        print (parameters)
        Alamofire.request("https://api.rajaongkir.com/basic/waybill",method: .post, parameters: parameters,encoding: URLEncoding.default, headers: headers)
            .responseSwiftyJSON { dataResponse in
                
                if let data = dataResponse.data{
                    do {
                        let decoder = JSONDecoder()
                        self.resi = try decoder.decode(Welcome.self, from: data)
                        print(self.resi)
                        self.detailsResi = (self.resi?.rajaongkir.result.details)!
                        //print(self.detailsResi)
                        
                        self.collectionview.reloadData()
                    } catch let err {
                        print(err)
                        
                        self.collectionview.reloadData()
                        SKActivityIndicator.dismiss()
                    }
                }
                
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupView()
        fetchResi()
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        navigationItem.title = "Request"
        
    }
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    private func setupView(){
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
        navigationItem.title = "Lacak Pengiriman"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        let screenWidth = UIScreen.main.bounds.width
        print(screenWidth)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width, height: 700)
        
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionview.register(ManifestCell.self, forCellWithReuseIdentifier: RequestCellId)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        self.view.addSubview(collectionview)
        
        self.collectionview.translatesAutoresizingMaskIntoConstraints = false
        self.collectionview.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: 0).isActive = true
        self.collectionview.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        self.collectionview.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: 0).isActive = true
        self.collectionview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! ManifestCell
        cell.labelA.text = self.resi?.rajaongkir.result.manifest[indexPath.row].manifest_description
        cell.labelB.text = self.resi?.rajaongkir.result.manifest[indexPath.row].manifest_date
        cell.labelC.text = self.resi?.rajaongkir.result.manifest[indexPath.row].manifest_time
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var counts = 0
        if let cnt : Int = self.resi?.rajaongkir.result.manifest.count{
            counts = cnt
        }
        return counts
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("asd")
        
    }
}

class ManifestCell: BaseCell {

    let labelA : UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0;
        return label
    }()
    
    let labelB : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let labelC : UILabel = {
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
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-10-[v0]-10-|", views: labelA) //pipline terakhir dihilangkan
        addConstraintsWithFormat("H:|-10-[v0]-10-|", views: labelB)
        addConstraintsWithFormat("H:|-10-[v0]-10-|", views: labelC)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-15-[v0]-5-[v1]-5-[v2]", views: labelA,labelB,labelC)
        addConstraintsWithFormat("V:|[v0(1)]", views: dividerLineView )
        
    }
    
}


let urlString = "http://titipanku.xyz/api/DetailUser.php?email=\(String(describing: emailNow))"
guard let url = URL(string: urlString) else { return }
URLSession.shared.dataTask(with: url) { (data, _, err) in
    DispatchQueue.main.async {
        if let err = err {
            print("Failed to get data from url:", err)
            return
        }
        guard let data = data else { return }
        print(data)
        do {
            let decoder = JSONDecoder()
            self.isiUser = try decoder.decode(userDetail.self, from: data)
            print(self.isiUser)
            self.userCollectionView.reloadData()
        } catch let jsonErr {
            print("Failed to decode:", jsonErr)}}
    }.resume()




