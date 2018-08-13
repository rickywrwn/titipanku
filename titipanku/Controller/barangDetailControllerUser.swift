//
//  barangDetailControllerUser.swift
//  titipanku
//
//  Created by Ricky Wirawan on 13/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import Alamofire_SwiftyJSON
import SKActivityIndicatorView
import Hue

class barangDetailControllerUser: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var offers = [VarOffer]()
    var tinggiTextView : Float = 0
    
    var app: App? {
        didSet {
            
            if app?.Screenshots != nil {
                return
            }
            
            if let id = app?.id {
                let urlString = "http://titipanku.xyz/api/DetailBarang.php?id=\(id)"
                
                URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                    
                    guard let data = data else { return }
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    do {
                        
                        let decoder = JSONDecoder()
                        let appDetail = try decoder.decode(App.self, from: data)
                        //print(appDetail)
                        self.app = appDetail
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            //self.collectionView!.reloadData()
                        })
                        
                    } catch let err {
                        print(err)
                    }
                    
                    
                }).resume()
            }
        }
    }
    
    
    func fetchOffer(_ completionHandler: @escaping ([VarOffer]) -> ()) {
        if let id = self.app?.id {
            let urlString = "http://titipanku.xyz/api/GetOffer.php?idRequest=\(id)"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.offers = try decoder.decode([VarOffer].self, from: data)
                    print(self.offers)
                    
                    SKActivityIndicator.dismiss()
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.offers)
                    })
                    
                } catch let err {
                    print(err)
                    
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
    }
    
    fileprivate let headerId = "headerId"
    fileprivate let cellId = "cellId"
    fileprivate let descriptionCellId = "descriptionCellId"
    fileprivate let buttonCellId = "buttonCellId"
    fileprivate let offerCellId = "offerCellId"
    fileprivate let userCellId = "userCellId"
    fileprivate let offerListCellId = "offerListCellId"
    fileprivate let AppCellKosongCellId = "AppCellKosongCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(AppDetailHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(AppDetailDescriptionCell.self, forCellWithReuseIdentifier: descriptionCellId)
        collectionView?.register(AppDetailButtons.self, forCellWithReuseIdentifier: buttonCellId)
        collectionView?.register(AppDetailOffer.self, forCellWithReuseIdentifier: offerCellId)
        collectionView?.register(AppDetailUser.self, forCellWithReuseIdentifier: userCellId)
        collectionView?.register(AppOfferList.self, forCellWithReuseIdentifier: offerListCellId)
        collectionView?.register(AppCellKosong.self, forCellWithReuseIdentifier: AppCellKosongCellId)
        collectionView?.register(ScreenshotsCell.self, forCellWithReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAcceptOffer(_:)), name: NSNotification.Name(rawValue: "toAcceptOffer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAcceptedOffer(_:)), name: NSNotification.Name(rawValue: "toAcceptedOffer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showConfirmAcceptedOffer(_:)), name: NSNotification.Name(rawValue: "toConfirmAcceptedOffer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPengirimanOffer(_:)), name: NSNotification.Name(rawValue: "toPengirimanOffer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPenerimaanOffer(_:)), name: NSNotification.Name(rawValue: "toPenerimaanOffer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showCompletedOffer(_:)), name: NSNotification.Name(rawValue: "toCompletedOffer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBarangDetail), name: NSNotification.Name(rawValue: "reloadBarangDetail"), object: nil)
        adaNawar = false
        statusOffer = false
        SKActivityIndicator.show("Loading...")
        self.fetchOffer{(offers) -> ()in
            self.offers = offers
            print("count offers" + String(self.offers.count))
            for i in 0 ..< self.offers.count {
                print(self.offers[i].status)
                if self.offers[i].status != "1"{
                    statusOffer = true
                    print("nocok")
                }else{
                    print("cok")
                }
            }
            
            self.collectionView?.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        collectionView?.reloadData()
    }
    
    @objc func reloadBarangDetail(){
        SKActivityIndicator.show("Loading...")
        self.offers = []
        print("count baru" + String(self.offers.count))
        self.fetchOffer{(offers) -> ()in
            self.offers = offers
            print(self.offers)
            print("count baru" + String(self.offers.count))
            self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
    }
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    @objc func handleDiskusi(){
        print("diskusi")
        let layout = UICollectionViewFlowLayout()
        let komentarController = KomentarBarangController(collectionViewLayout: layout)
        //komentarController.app = app
        print(statusOffer)
        print(self.app?.status)
        print(self.app?.nomorResi)
        //print(self.offers[0].id)
        //navigationController?.pushViewController(komentarController, animated: true)
    }
    func showOffer() {
        let appDetailController = OfferController()
        appDetailController.app = app
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    @objc func handleTitip(){
        print("titip")
        let layout = UICollectionViewFlowLayout()
        let tambahCont = PostTitipJuga(collectionViewLayout:layout)
        tambahCont.app = self.app
        tambahCont.sizeDesc = tinggiDesc
        print(tinggiDesc)
        present(tambahCont, animated: true, completion: {
        })
    }
    @objc func handleOfferCancel(){
        if let idOffer : String = idOfferNow {
            
            let parameter: Parameters = ["idOffer": idOffer ,"action":"cancel"]
            print (parameter)
            Alamofire.request("http://titipanku.xyz/api/SetOffer.php",method: .get, parameters: parameter).responseJSON {
                response in
                
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
                    let alert = UIAlertController(title: "Message", message: "Cancel Offer Berhasil", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        
                        adaNawar = false
                        self.reloadBarangDetail()
                        
                    }))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc func showAcceptOffer(_ notification: NSNotification) {
        let appDetailController = AcceptOffer()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOffer {
            appDetailController.varOffer = varOffer
        }
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    @objc func showAcceptedOffer(_ notification: NSNotification) {
        let appDetailController = AcceptedOffer()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOffer {
            appDetailController.varOffer = varOffer
        }
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    @objc func showConfirmAcceptedOffer(_ notification: NSNotification) {
        let appDetailController = ConfirmAcceptedOffer()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOffer {
            appDetailController.varOffer = varOffer
        }
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    @objc func showPengirimanOffer(_ notification: NSNotification) {
        let appDetailController = PengirimanOffer()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOffer {
            appDetailController.varOffer = varOffer
        }
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    @objc func showPenerimaanOffer(_ notification: NSNotification) {
        let appDetailController = PenerimaanOffer()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOffer {
            appDetailController.varOffer = varOffer
        }
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    @objc func showCompletedOffer(_ notification: NSNotification) {
        let appDetailController = CompletedOffer()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOffer {
            appDetailController.varOffer = varOffer
        }
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId, for: indexPath) as! AppDetailDescriptionCell
            
            cell.nameLabel.text = app?.name
            
            cell.priceLabel.text = "Rp. " +   (app?.price)!
            cell.tglLabel.text = "Tanggal Posting : " + (app?.tglPost)!
            //cell.textView.text = app?.description
            cell.textView.attributedText = descriptionAttributedText()
            //menghitung tinggi textview
            let sizeThatFitsTextView = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width, height: CGFloat(MAXFLOAT)))
            let heightOfText = sizeThatFitsTextView.height
            tinggiDesc = Float(heightOfText)
            tinggiTextView = Float(heightOfText-55)
            cell.qtyLabel.text = app?.qty
            cell.countryLabel.text = app?.country
            cell.kotaLabel.text = app?.kotaKirim
            if app?.url == ""{
                cell.UrlLabel.text = "Tidak Ada"
            }else {
                cell.UrlLabel.text = app?.url
            }
            return cell
            
        }else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buttonCellId, for: indexPath) as! AppDetailButtons
            
            cell.diskusiButton.addTarget(self, action: #selector(handleDiskusi), for: UIControlEvents.touchDown)
            cell.priceLabel.text = "Rp. " +   (app?.price)!
            return cell
        }else if indexPath.item == 2 {
            
            if self.app?.status == "1"{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! AppDetailUser
                //cell.diskusiButton.setTitle(app?.email, for: .normal)
                cell.user = (app?.email)!
                cell.statusOffer = statusOffer
                cell.backgroundColor = UIColor(hex: "#4b6584")
                cell.userCollectionView.reloadData()
                
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! AppDetailUser
                //cell.diskusiButton.setTitle(app?.email, for: .normal)
                cell.user = (app?.email)!
                if self.offers.count > 0 {
                    cell.traveller = self.offers[0].idPenawar
                }else{
                    cell.traveller = ""
                }
                cell.statusOffer = statusOffer
                cell.backgroundColor = UIColor(hex: "#4b6584")
                cell.userCollectionView.reloadData()
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! AppDetailUser
            
            
            return cell
        }else if indexPath.item == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerCellId, for: indexPath) as! AppDetailOffer
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                
                if self.app?.email == emailNow{
                    if statusOffer != true{
                        cell.nameLabel.text = "List Penawar"
                        cell.backgroundColor = UIColor.white
                        cell.nameLabel.textColor = UIColor.black
                    }else{
                        if self.app?.status == "2" {
                            cell.nameLabel.text = "Penawaran Yang Disetujui"
                            cell.backgroundColor = UIColor(hex: "#20bf6b")
                            cell.nameLabel.textColor = UIColor.white
                        }else if self.app?.status == "3" {
                            cell.nameLabel.text = "Request Anda Sudah Dibelikan"
                            cell.backgroundColor = UIColor(hex: "#20bf6b")
                            cell.nameLabel.textColor = UIColor.white
                        }else if self.app?.status == "4" {
                            cell.nameLabel.text = "Request Anda Sudah Dikirim"
                            cell.backgroundColor = UIColor(hex: "#20bf6b")
                            cell.nameLabel.textColor = UIColor.white
                        }else if self.app?.status == "5" {
                            cell.nameLabel.text = "Request Selesai"
                            cell.backgroundColor = UIColor(hex: "#20bf6b")
                            cell.nameLabel.textColor = UIColor.white
                        }
                    }
                    
                }else{
                    
                    var cekBeli = false
                    for i in 0 ..< self.offers.count {
                        if emailNow == self.offers[i].idPenawar{
                            print("cancel")
                            cekBeli = true
                        }
                    }
                    if cekBeli == false{
                        if statusOffer == false{
                            cell.nameLabel.text = "Bantu Belikan"
                            cell.backgroundColor = UIColor(hex: "#3867d6")
                            cell.nameLabel.textColor = UIColor.white
                        }else{
                            cell.nameLabel.text = "Request Sudah Diterima Oleh User Lain"
                            cell.backgroundColor = UIColor(hex: "#20bf6b")
                            cell.nameLabel.textColor = UIColor.white
                        }
                        
                    }else{
                        print("statusOffer")
                        print(statusOffer)
                        if statusOffer != true{
                            cell.nameLabel.text = "Cancel Penawaran"
                            cell.backgroundColor = UIColor(hex: "#eb3b5a")
                            cell.nameLabel.textColor = UIColor.white
                        }else{
                            if self.app?.status == "2" {
                                cell.nameLabel.text = "Penawaran Anda Sudah Diterima"
                                cell.backgroundColor = UIColor(hex: "#20bf6b")
                                cell.nameLabel.textColor = UIColor.white
                            }
                        }
                    }
                    
                }
                
            }
            
            return cell
        }else if indexPath.item == 4{
            
            if let email = self.app?.email,let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String  {
                if email == emailNow && offers.count > 0 {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListCellId, for: indexPath) as! AppOfferList
                    //cell.varOffer = offers[i]
                    //cell.backgroundColor = UIColor.black
                    cell.offers = offers
                    cell.app = app
                    print("Login sebagai requester dan ada penawaran")
                    for i in 0 ..< self.offers.count {
                        if self.offers[i].status != "1"{
                            statusOffer = true
                            //status offer 2, artinya sudah bayar
                        }
                    }
                    print("status offer")
                    print(statusOffer)
                    cell.offerCollectionView.reloadData()
                    return cell
                    
                }else if email == emailNow && offers.count == 0{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCellKosongCellId, for: indexPath) as! AppCellKosong
                    print("keterangan : login sebagai requester dan tidak ada penawaran")
                    return cell
                }else if email != emailNow && offers.count == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCellKosongCellId, for: indexPath) as! AppCellKosong
                    print("keterangan : login sebagai user lain tetapi penawaran di request tidak ada")
                    return cell
                }else if email != emailNow  && offers.count > 0 {
                    for i in 0 ..< self.offers.count {
                        if self.offers[i].status != "1"{
                            statusOffer = true
                        }
                        if emailNow == self.offers[i].idPenawar{
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListCellId, for: indexPath) as! AppOfferList
                            print("keterangan : penawaran ada dan user menawar disini")
                            //cell.varOffer = offers[i]
                            //cell.backgroundColor = UIColor.black
                            cell.offers = [self.offers[i]]
                            cell.app = app
                            adaNawar = true
                            idOfferNow = self.offers[i].id
                            
                            print(offers[i])
                            cell.offerCollectionView.reloadData()
                            return cell
                        }else{
                            print("keterangan : penawaran ada tetapi user bukan user yang login")
                            
                        }
                    }
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCellKosongCellId, for: indexPath) as! AppCellKosong
                    print("user tidak ada nawar disini")
                    return cell
                }
            }
            
        }
        
        //untuk screenshot
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotsCell
        
        cell.app = app
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //ukuran selain header
        if indexPath.item == 0 {
            return CGSize(width: view.frame.width, height: CGFloat(230 + tinggiTextView))
        }else if indexPath.item == 1{
            return CGSize(width: view.frame.width, height: 145)
        }else if indexPath.item == 2{
            return CGSize(width: view.frame.width, height: 230)
        }else if indexPath.item == 3{
            return CGSize(width: view.frame.width, height: 70)
        }
        
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let email = app?.email {
            
            if email == emailNow  && offers.count > 0{
                //jika user sendiri
                if indexPath.item == 4{
                    return CGSize(width: view.frame.width, height: 350)
                }
            }else if email != emailNow  && offers.count != 0{
                if indexPath.item == 4{
                    return CGSize(width: view.frame.width, height: 133)
                }
            }else if offers.count == 0{
                if indexPath.item == 4{
                    return CGSize(width: view.frame.width, height: 0)
                }
            }
            
        }
        
        return CGSize(width: view.frame.width, height: 170)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! AppDetailHeader
        header.app = app
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 300) //ukuran gambar
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath)
        
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String , let status = app?.status , let email = app?.email {
            if email != emailNow{
                if indexPath.row == 3  {
                    cell?.layer.backgroundColor = UIColor.gray.cgColor
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        
                        if  self.offers.count > 0 {
                            
                            if adaNawar == false{
                                if statusOffer == false{
                                    print("bantu")
                                    cell?.layer.backgroundColor = UIColor(hex: "#4b7bec").cgColor
                                    print(statusOffer)
                                    self.showOffer()
                                }else{
                                    print("request sudah di terima oleh user lain dan sudah dibayar")
                                    cell?.layer.backgroundColor = UIColor(hex: "#20bf6b").cgColor
                                }
                            }else{
                                print("cancel")
                                if statusOffer != true{
                                    
                                    let alert = UIAlertController(title: "Message", message: "Apakah Anda Ingin Membatalkan Penawaran?", preferredStyle: .alert)
                                    
                                    alert.addAction(UIAlertAction(title: "Ya", style: .default, handler: { action in
                                        
                                        print("batal")
                                        self.handleOfferCancel()
                                        
                                    }))
                                    alert.addAction(UIAlertAction(title: "Tidak", style: .default, handler: nil))
                                    
                                    self.present(alert, animated: true)
                                    cell?.layer.backgroundColor = UIColor(hex: "#eb3b5a").cgColor
                                }else{
                                    print("status offer sdh 2")
                                    cell?.backgroundColor = UIColor(hex: "#20bf6b")
                                }
                                
                            }
                            //                            for i in 0 ..< self.offers.count {
                            //                                if emailNow == self.offers[i].idPenawar{
                            //
                            //                                }else{
                            //
                            //                                }
                            //                            }
                        }else{
                            cell?.layer.backgroundColor = UIColor(hex: "#4b7bec").cgColor
                            self.showOffer()
                        }
                    }
                }
            }
        }
        
    }
    
    fileprivate func descriptionAttributedText() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Deskripsi Barang\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)])
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let range = NSMakeRange(0, attributedText.string.characters.count)
        attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: range)
        
        if let desc = app?.description {
            attributedText.append(NSAttributedString(string: desc, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor.darkGray]))
        }
        
        return attributedText
    }
    
}

