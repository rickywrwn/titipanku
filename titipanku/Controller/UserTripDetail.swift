//
//  UserTripDetail.swift
//  titipanku
//
//  Created by Ricky Wirawan on 31/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Alamofire
import SwiftyJSON
import AlamofireImage
import Hue

class UserTripDetail: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    fileprivate let RequestCellId = "RequestCellId"
    
    var isiUser  : userDetail?
    var app : App?
    var tripRequests = [tripRequest]()
    var collectionview: UICollectionView!
    var tripUser : trip?
    
    struct tripRequest: Decodable {
        let id: String
        let idRequest: String
        let idTrip: String
        let email: String
    }
    
    func fetchTripRequests(_ completionHandler: @escaping ([tripRequest]) -> ()) {
        if let idTrip = tripUser?.id {
            let urlString = "http://titipanku.xyz/api/GetTripRequest.php?idTrip=\(String(describing: idTrip))"
            print(urlString)
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.tripRequests = try decoder.decode([tripRequest].self, from: data)
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.tripRequests)
                    })
                } catch let err {
                    print(err)
                    
                    self.collectionview.reloadData()
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
        
    }
    
    func fetchDetail(idRequest : String, completionHandler: @escaping (App) -> ()) {
        if let id : String = idRequest  {
            let urlString = "http://titipanku.xyz/api/DetailBarang.php?id=\(id)"

            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in

                guard let data = data else { return }

                if let error = error {
                    print(error)
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    self.app = try decoder.decode(App.self, from: data)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.app!)
                    })
                } catch let err {
                    print(err)

                    self.collectionview.reloadData()
                    SKActivityIndicator.dismiss()
                }

            }) .resume()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.backgroundColor = UIColor.white
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        self.fetchTripRequests{(tripRequests) -> ()in
            self.tripRequests = tripRequests
            print("count request" + String(self.tripRequests.count))
            self.collectionview.reloadData()
            SKActivityIndicator.dismiss()
        }
        
    }
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    @objc func handleCancleTrip(){
        let alert = UIAlertController(title: "Message", message: "Apakah Anda Yakin Untuk Menghapus Trip?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ya", style: .default, handler: { action in
            
            for i in 0 ..< self.tripRequests.count {
                
                self.fetchDetail(idRequest: self.tripRequests[i].idRequest,completionHandler: {(app) -> () in
                    
                    if let idTrip : String = self.tripRequests[i].idTrip, let idRequest : String = self.tripRequests[i].idRequest , let idPemilik : String = app.email,let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String{
                        
                        let parameters: Parameters = ["idTrip": idTrip,"idRequest": idRequest, "idPemilik" : idPemilik, "email":emailNow]
                        print(parameters)
                        Alamofire.request("http://titipanku.xyz/api/SetTrip.php",method: .get, parameters: parameters).responseJSON {
                            response in
                            
                            //mencetak JSON response
                            if let json = response.result.value {
                                print("JSON: \(json)")
                            }
                            
                            //mengambil json
                            let json = JSON(response.result.value)
                            print(json)
                            let cekSukses = json["success"].intValue
                            let pesan = json["message"].stringValue
                            
                            if cekSukses != 1 {
                                let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                                
                                self.present(alert, animated: true)
                            }else{
                                let alert = UIAlertController(title: "Message", message: "Hapus Trip Berhasil", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                                    self.handleCancle()
                                }))
                                
                                self.present(alert, animated: true)
                            }
                        }
                    }
                })
                
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Tidak", style: .default, handler: { action in
           
        }))
        self.present(alert, animated: true)
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
        navigationItem.title = "Trip"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let email = isiUser?.email {
            if emailNow == email {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel Trip", style: .done, target: self, action: #selector(handleCancleTrip))
            }
        }
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
        self.collectionview.register(HistoryCell.self, forCellWithReuseIdentifier: RequestCellId)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        self.view.addSubview(collectionview)
        
        self.collectionview.translatesAutoresizingMaskIntoConstraints = false
        self.collectionview.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: 0).isActive = true
        self.collectionview.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        self.collectionview.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: -5).isActive = true
        self.collectionview.heightAnchor.constraint(equalToConstant: 600).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! HistoryCell

        self.fetchDetail(idRequest: tripRequests[indexPath.row].idRequest,completionHandler: {(app) -> () in
            self.app = app
            print(app)
            cell.labelCountry.text = app.name
            cell.LabelTgl.text = self.tripRequests[indexPath.row].idRequest
            cell.LabelStatus.isHidden = true
            cell.labelC.isHidden = true
            cell.labelB.text = "Status"
            if app.status == "0"{
                cell.LabelTgl.text = "Ditolak"
            }else if app.status == "1"{
                cell.LabelTgl.text = "Belum Diterima"
            }else if app.status == "2"{
                cell.LabelTgl.text = "Diterima"
            }else if app.status == "3"{
                cell.LabelTgl.text = "Sudah Dibelikan"
            }else if app.status == "4"{
                cell.LabelTgl.text = "Sudah Dikirim"
            }else if app.status == "5"{
                cell.LabelTgl.text = "Selesai"
            }
            if let id = app.id {
                Alamofire.request("http://titipanku.xyz/uploads/b"+id+".jpg").responseImage { response in
                    if let image = response.result.value {
                        cell.imageView.image = image
                    }
                }
            }
        })

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripRequests.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("asd")
        
        self.fetchDetail(idRequest: tripRequests[indexPath.row].idRequest,completionHandler: {(app) -> () in
            self.app = app
            print(app)
            let layout = UICollectionViewFlowLayout()
            let appDetailController = barangDetailController(collectionViewLayout: layout)
            appDetailController.app = app
            self.present(appDetailController, animated: true, completion: {
            })
        })
        
    }
}
