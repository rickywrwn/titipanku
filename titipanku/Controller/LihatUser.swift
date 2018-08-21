//
//  LihatUser.swift
//  titipanku
//
//  Created by Ricky Wirawan on 21/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import SKActivityIndicatorView

class LihatUser : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var cekLogged : Bool = UserDefaults.standard.bool(forKey: "logged")
    struct userDetail: Decodable {
        let name: String
        let email: String
        let tanggalDaftar: String
        
    }
    var isiUser  : userDetail?
    
    struct emailUser {
        static var email = ""
        static var status = ""
    }
    fileprivate func fetchJSON() {
        if let emailNow : String = emailUser.email {
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
                        // link in description for video on JSONDecoder
                        let decoder = JSONDecoder()
                        // Swift 4.1
                        self.isiUser = try decoder.decode(userDetail.self, from: data)
                        print(self.isiUser)
                        
                        self.collectionView?.reloadData()
                        SKActivityIndicator.dismiss()
                    } catch let jsonErr {
                        print("Failed to decode:", jsonErr)
                        SKActivityIndicator.dismiss()
                    }
                }
                }.resume()
        }
    }
    
    fileprivate let userCellId = "userCellId"
    fileprivate let cellId = "cellId"
    fileprivate let activityCellId = "activityCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        self.title = "User"
        navigationItem.title = "Profile"
        print("User Loaded")
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        fetchJSON()
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(UserDetailCell.self, forCellWithReuseIdentifier: userCellId)
        collectionView?.register(UserActivityCell.self, forCellWithReuseIdentifier: activityCellId)
        
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
    
    @objc func handleTrip(){
        let layout = UICollectionViewFlowLayout()
        let tripListCont = UserTripList(collectionViewLayout: layout)
        navigationController?.pushViewController(tripListCont, animated: true)
        
    }
    @objc func handleReview(){
        let layout = UICollectionViewFlowLayout()
        let tripListCont = UserReview(collectionViewLayout: layout)
        navigationController?.pushViewController(tripListCont, animated: true)
        
    }
    @objc func handlePembelian(){
        let tripListCont = UserPembelian()
        navigationController?.pushViewController(tripListCont, animated: true)
        
    }
    @objc func handlePenjualan(){
        let tripListCont = UserPenjualan()
        navigationController?.pushViewController(tripListCont, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! UserDetailCell
            
            cell.labelEmail.text = isiUser?.email
            cell.LabelNama.text = isiUser?.name
            cell.LabelTanggal.text = isiUser?.tanggalDaftar
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                Alamofire.request("http://titipanku.xyz/uploads/"+emailNow+".jpg").responseImage { response in
                    //debugPrint(response)
                    //let nama = self.app?.name
                    //print("gambar : "+imageName)
                    if let image = response.result.value {
                        //print("image downloaded: \(image)")
                        cell.imageView.image = image
                        self.collectionView?.reloadData()
                    }
                }
            }
            
            
            return cell
        }else if indexPath.item == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! UserActivityCell
            cell.labelNama.text = "Review"
            
            return cell
        }else if indexPath.item == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! UserActivityCell
            cell.labelNama.text = "Postinganku"
            
            return cell
        }else if indexPath.item == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! UserActivityCell
            cell.labelNama.text = "Penawaranku"
            
            return cell
        }else if indexPath.item == 4{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCellId, for: indexPath) as! UserActivityCell
            cell.labelNama.text = "Trip"
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! UserDetailCell
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row == 0{
            
            return CGSize(width: view.frame.width, height: 170)
        }
        return CGSize(width: view.frame.width, height: 40)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        if indexPath.row != 0 {
            
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.backgroundColor = UIColor.gray.cgColor
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cell?.layer.backgroundColor = UIColor.white.cgColor
                if indexPath.row == 1{
                    self.handleReview()
                }else if indexPath.row == 2{
                    self.handlePembelian()
                }else if indexPath.row == 3{
                    self.handlePenjualan()
                }else if indexPath.row == 4{
                    self.handleTrip()
                }
            }
        }
    }
}
