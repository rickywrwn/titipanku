//
//  barangDetailController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 17/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import Alamofire_SwiftyJSON
import SKActivityIndicatorView
import Hue


struct VarOffer: Decodable {
    let id: String
    let idPenawar: String
    let idRequest: String
    let tglOffer: String
    let hargaPenawaran: String
    let valueHarga: String
    let tglPulang: String
    let idKota : String
    let kota: String
    let hargaOngkir: String
    let jenisOngkir: String
    let status: String
    
}

var adaNawar = false
var idOfferNow : String = ""
var statusOffer = false
var tinggiDesc : Float = 0

class barangDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

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
        
        
//        // Create the navigation bar
//        let height: CGFloat = 75
//        let statusBarHeight = UIApplication.shared.statusBarFrame.height;
//        let navbar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight, width: UIScreen.main.bounds.width, height: height))
//        navbar.backgroundColor = UIColor.white
//        navbar.delegate = self as? UINavigationBarDelegate
//
//
//        // Offset by 20 pixels vertically to take the status bar into account
//        navbar.backgroundColor = UIColor(hex: "#3867d6")
//
//        // Create a navigation item with a title
//        let navigationItem = UINavigationItem()
        navigationItem.title = "Request"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Titip Juga", style: .plain, target: self, action: #selector(handleTitip))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Batal", style: .done, target: self, action: #selector(handleCancle))
//        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
//        // Assign the navigation item to the navigation bar
//        navbar.items = [navigationItem]
//
//        // Make the navigation bar a subview of the current view controller
//        self.view.addSubview(navbar)
//
//        collectionView?.frame = CGRect(x: 0, y: height, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - height))
//
        
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

class AppCellKosong: BaseCell {
    override func setupViews() {
        super.setupViews()
    }
}

class AppDetailDescriptionCell: BaseCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "harga"
        label.font = UIFont.boldSystemFont(ofSize: 21)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "harga"
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    let tglLabel: UILabel = {
        let label = UILabel()
        label.text = "tgl"
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE DESCRIPTION"
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        tv.inputView = UIView();
        return tv
    }()
    
    let imageViewQty: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.green
        iv.layer.masksToBounds = true
        return iv
    }()
    let qtyLabelKiri: UILabel = {
        let label = UILabel()
        label.text = "Jumlah Barang:"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let qtyLabel: UILabel = {
        let label = UILabel()
        label.text = "qty"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let imageViewCountry: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.green
        iv.layer.masksToBounds = true
        return iv
    }()
    let countryLabelKiri: UILabel = {
        let label = UILabel()
        label.text = "Negara Pembelian:"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let countryLabel: UILabel = {
        let label = UILabel()
        label.text = "count"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let imageViewKota: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.green
        iv.layer.masksToBounds = true
        return iv
    }()
    let kotaLabelKiri: UILabel = {
        let label = UILabel()
        label.text = "Kota Pengiriman:"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let kotaLabel: UILabel = {
        let label = UILabel()
        label.text = "kota"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let imageViewUrl: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.green
        iv.layer.masksToBounds = true
        return iv
    }()
    let UrlLabelKiri: UILabel = {
        let label = UILabel()
        label.text = "URL Refrensi:"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let UrlLabel: UILabel = {
        let label = UILabel()
        label.text = "kota"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(tglLabel)
        addSubview(textView)
        addSubview(qtyLabelKiri)
        addSubview(qtyLabel)
        addSubview(imageViewQty)
        addSubview(countryLabelKiri)
        addSubview(countryLabel)
        addSubview(imageViewCountry)
        addSubview(kotaLabelKiri)
        addSubview(kotaLabel)
        addSubview(imageViewKota)
        addSubview(UrlLabelKiri)
        addSubview(UrlLabel)
        addSubview(imageViewUrl)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-15-[v0]", views: nameLabel)
        addConstraintsWithFormat("H:|-15-[v0]", views: tglLabel)
        addConstraintsWithFormat("H:|-10-[v0]", views: textView)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewQty,qtyLabelKiri,qtyLabel)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewCountry,countryLabelKiri,countryLabel)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewKota,kotaLabelKiri,kotaLabel)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewUrl,UrlLabelKiri,UrlLabel)
        addConstraintsWithFormat("H:|[v0]", views: dividerLineView)
        
        //addConstraintsWithFormat("V:|-15-[v0]-5-[v3]-5-[v7]-15-[v1]-1-[v4]-5-[v5]-5-[v6]-25-[v2(1)]-15-|", views: nameLabel, textView, dividerLineView, priceLabel ,qtyLabelKiri,countryLabelKiri,kotaLabelKiri,tglLabel )
        addConstraintsWithFormat("V:[v0]-5-[v3]-15-[v1]", views: nameLabel, textView, priceLabel ,tglLabel)
        addConstraintsWithFormat("V:[v0(17)]-5-[v1(17)]-5-[v2(17)]-5-[v3(17)]|", views: imageViewQty,imageViewCountry,imageViewKota,imageViewUrl)
        addConstraintsWithFormat("V:[v0]-5-[v1]-5-[v2]-5-[v3]|", views: qtyLabelKiri,countryLabelKiri,kotaLabelKiri,UrlLabelKiri)
        addConstraintsWithFormat("V:[v0]-5-[v1]-5-[v2]-5-[v3]|", views: qtyLabel,countryLabel,kotaLabel,UrlLabel)
        
    }
}

class AppDetailButtons: BaseCell {
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Rp 1412333"
        label.textColor = UIColor(hex: "#4b7bec")
        label.font = UIFont.systemFont(ofSize: 21)
        return label
    }()
    let ketLabel: UILabel = {
        let label = UILabel()
        label.text = "Sebelum Ongkos Kirim"
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let diskusiButton : UIButton = {
        let button = UIButton()
        button.setTitle("Lihat Diskusi", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: "#4b7bec")
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    let dividerLineView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(priceLabel)
        addSubview(ketLabel)
        addSubview(diskusiButton)
        addSubview(dividerLineView)
        addSubview(dividerLineView1)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("H:|-25-[v0]|", views: priceLabel)
        addConstraintsWithFormat("H:|-270-[v0]-10-|", views: diskusiButton)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView1)
        addConstraintsWithFormat("H:|-25-[v0]|", views: ketLabel)
        
        addConstraintsWithFormat("V:|-10-[v0(1)]-10-[v1]-1-[v2]-10-[v4(1)]-10-[v3(50)]-10-|", views: dividerLineView,priceLabel,ketLabel,diskusiButton,dividerLineView1 )
    }
    
}

class AppDetailUser: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
 
    fileprivate let userTawarBarangCellId = "userTawarBarangCellId"
    
    var user : String = ""
    var traveller : String = ""
    var statusOffer = false
    
    let userCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 27
        layout.minimumLineSpacing = 27
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(userCollectionView)
        addSubview(dividerLineView)
        
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        
        userCollectionView.register(userTawarBarangCell.self, forCellWithReuseIdentifier: userTawarBarangCellId)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("H:|-10-[v0]|", views: userCollectionView)
        
        addConstraintsWithFormat("V:|[v0][v1(1)]|", views: userCollectionView,dividerLineView )
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userTawarBarangCellId, for: indexPath) as! userTawarBarangCell
        //cell.app = appCategory?.apps?[indexPath.item]
        
        if statusOffer == false{
            if indexPath.item == 0{
                cell.nameLabel.text = user
                cell.LabelA.text = "Requester"
                cell.backgroundColor = UIColor.white
                DispatchQueue.main.async{
                    Alamofire.request("http://titipanku.xyz/uploads/"+self.user+".jpg").responseImage { response in
                        //debugPrint(response)
                        //let nama = self.app?.name
                        //print("gambar : "+imageName)
                        if let image = response.result.value {
                            //print("image downloaded: \(image)")
                            cell.imageView.image = image
                            self.userCollectionView.reloadData()
                        }
                    }
                }
                
                return cell
            }else{
                cell.LabelA.text = "Traveller"
                cell.backgroundColor = UIColor.white
                return cell
            }
        }else{
            if indexPath.item == 0{
                cell.nameLabel.text = user
                cell.LabelA.text = "Requester"
                cell.backgroundColor = UIColor.white
                DispatchQueue.main.async{
                    Alamofire.request("http://titipanku.xyz/uploads/"+self.user+".jpg").responseImage { response in
                        //debugPrint(response)
                        //let nama = self.app?.name
                        //print("gambar : "+imageName)
                        if let image = response.result.value {
                            //print("image downloaded: \(image)")
                            cell.imageView.image = image
                            self.userCollectionView.reloadData()
                        }
                    }
                }
                
                return cell
            }else{
                cell.nameLabel.text = traveller
                cell.LabelA.text = "Traveller"
                cell.backgroundColor = UIColor.white
                DispatchQueue.main.async{
                    Alamofire.request("http://titipanku.xyz/uploads/"+self.traveller+".jpg").responseImage { response in
                        //debugPrint(response)
                        //let nama = self.app?.name
                        //print("gambar : "+imageName)
                        if let image = response.result.value {
                            //print("image downloaded: \(image)")
                            cell.imageView.image = image
                            self.userCollectionView.reloadData()
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/2-25, height: frame.height - 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0{
            print("request")
            print(self.user + "user nama")
            print(self.user + ".jpg")
        }else{
            print("penawar")
            print(self.traveller + "traveler nama")
            print(self.traveller + ".jpg")
        }
        userCollectionView.reloadData()
        
    }
    
}


class userTawarBarangCell: BaseCell {
    
    let LabelA: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "coba")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Belum Ada"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(LabelA)
        
        addConstraintsWithFormat("H:|-5-[v0]-5-|", views: LabelA)
        addConstraintsWithFormat("H:|-25-[v0]-25-|", views: imageView)
        addConstraintsWithFormat("H:|-5-[v0]-5-|", views: nameLabel)
        
        addConstraintsWithFormat("V:|[v2]-5-[v0(150)]-5-[v1]", views: imageView,nameLabel,LabelA)
        
    }
    
}


class AppOfferList: BaseCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    fileprivate let offerListDalamId = "offerListDalamId"
    fileprivate let offerListKiriCellId = "offerListKiriCellId"
    fileprivate let offerListKananCellId = "offerListKananCellId"
    
//    var varOffer: VarOffer? {
//        didSet {
//
//        }
//
//    }
    
    var offers = [VarOffer]()
    
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
                        self.app = appDetail
                        
                        
                    } catch let err {
                        print(err)
                    }
                }).resume()
            }
        }
    }
    
    
    let offerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(offerCollectionView)
        addSubview(dividerLineView)
        
        offerCollectionView.dataSource = self
        offerCollectionView.delegate = self
        
        offerCollectionView.register(AppOfferListDalam.self, forCellWithReuseIdentifier: offerListDalamId)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("H:|[v0]|", views: offerCollectionView)
        
        addConstraintsWithFormat("V:|-15-[v0]|", views: offerCollectionView,dividerLineView )
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return offers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("count appofferlist")
        print(offers.count)
        for i in 0 ..< offers.count {
            if indexPath.row == i{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListDalamId, for: indexPath) as! AppOfferListDalam
                cell.app = app
                //cell.backgroundColor = UIColor.brown
                cell.varOffer = offers[i]
                print("appoferlist")
                print(offers[i])
                cell.offerCollectionView.reloadData()
                return cell
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListDalamId, for: indexPath) as! AppOfferListDalam
        //cell.app = appCategory?.apps?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: frame.width, height: 130)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        if indexPath.row == 0{
//            print(varOffer?.idPenawar)
//        }else{
//            print(varOffer)
//            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toAcceptOffer"), object: nil, userInfo: dataIdOffer)
//        }
        print("offerlist luar " + String(indexPath.row))
    }
}


class AppOfferListDalam: BaseCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    fileprivate let offerListKiriCellId = "offerListKiriCellId"
    fileprivate let offerListKananCellId = "offerListKananCellId"
    
    var varOffer: VarOffer? {
        didSet {

        }

    }
    
    
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
                        self.app = appDetail
                        
                        
                    } catch let err {
                        print(err)
                    }
                    
                    
                }).resume()
            }
        }
    }
    
    
    let offerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(offerCollectionView)
        addSubview(dividerLineView)
        
        offerCollectionView.dataSource = self
        offerCollectionView.delegate = self
        
        offerCollectionView.register(OfferListKiri.self, forCellWithReuseIdentifier: offerListKiriCellId)
        offerCollectionView.register(OfferListKanan.self, forCellWithReuseIdentifier: offerListKananCellId)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("H:|[v0]|", views: offerCollectionView)
        
        addConstraintsWithFormat("V:|[v0][v1(1)]|", views: offerCollectionView,dividerLineView )
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.item == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListKiriCellId, for: indexPath) as! OfferListKiri
            //cell.app = appCategory?.apps?[indexPath.item]
            //cell.backgroundColor = UIColor.red
            cell.nameLabel.text = varOffer?.idPenawar
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListKananCellId, for: indexPath) as! OfferListKanan
            //cell.app = appCategory?.apps?[indexPath.item]
            //cell.backgroundColor = UIColor.blue
            cell.priceLabel.text = "Harga Penawaran : Rp." + (varOffer?.hargaPenawaran)!
            cell.kotaLabel.text = "Kota Pengiriman : " + (varOffer?.kota)!
            cell.tglLabel.text = "Tgl Pulang : " + (varOffer?.tglPulang)!
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListKiriCellId, for: indexPath) as! OfferListKiri
        //cell.app = appCategory?.apps?[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0{
            return CGSize(width: frame.width/3-5, height: frame.height)
        }else{
            let ukuran = frame.width/3+26
            return CGSize(width: frame.width-ukuran, height: frame.height)
        }
        
        return CGSize(width: frame.width/2-5, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            print(varOffer?.idPenawar)
            print(statusOffer)
        }else{
            
            print("statusoffernow")
            print(statusOffer)
            if statusOffer == false{
                if adaNawar == false{
                    print(varOffer)
                    print(varOffer?.hargaPenawaran)
                    let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toAcceptOffer"), object: nil, userInfo: dataIdOffer)
                }else{
                    print(varOffer?.hargaPenawaran)
                }
            }else{
                if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                    if varOffer?.status == "2"{
                        if emailNow != varOffer?.idPenawar{
                            print(statusOffer)
                            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toAcceptedOffer"), object: nil, userInfo: dataIdOffer)
                            print("tinggal nunggu dibelikan")
                        }else{
                            print(statusOffer)
                            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toConfirmAcceptedOffer"), object: nil, userInfo: dataIdOffer)
                        }
                    }else if varOffer?.status == "3"{
                        if emailNow != varOffer?.idPenawar{
                            print(statusOffer)
                            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toAcceptedOffer"), object: nil, userInfo: dataIdOffer)
                            print("tinggal nunggu Dikirim")
                        }else{
                            print(statusOffer)
                            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toPengirimanOffer"), object: nil, userInfo: dataIdOffer)
                        }
                    }else if varOffer?.status == "4"{
                        if emailNow != varOffer?.idPenawar{
                            print(statusOffer)
                            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toPenerimaanOffer"), object: nil, userInfo: dataIdOffer)
                            print("tinggal nunggu Sampai")
                        }else{
                            print(statusOffer)
                            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toAcceptedOffer"), object: nil, userInfo: dataIdOffer)
                        }
                    }else if varOffer?.status == "5"{
                        if emailNow != varOffer?.idPenawar{
                            print(statusOffer)
                            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toCompletedOffer"), object: nil, userInfo: dataIdOffer)
                            print("sudah Sampai")
                        }else{
                            print(statusOffer)
                            let dataIdOffer:[String: VarOffer] = ["varOffer": varOffer!]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toCompletedOffer"), object: nil, userInfo: dataIdOffer)
                        }
                    }
                    
                }
                
            }
            
        }
    }
}

class OfferListKiri: BaseCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "coba")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "User"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addSubview(nameLabel)
        
        addConstraintsWithFormat("H:|-25-[v0(85)]|", views: imageView)
        addConstraintsWithFormat("H:|[v0]|", views: nameLabel)
        
        addConstraintsWithFormat("V:|[v0(85)]-5-[v1]", views: imageView,nameLabel)
        
    }
    
}


class OfferListKanan: BaseCell {
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "harga"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()

    let kotaLabel: UILabel = {
        let label = UILabel()
        label.text = "kota"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let tglLabel: UILabel = {
        let label = UILabel()
        label.text = "tgl"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()

    override func setupViews() {
        super.setupViews()

        addSubview(priceLabel)
        addSubview(kotaLabel)
        addSubview(tglLabel)

        addConstraintsWithFormat("H:|-5-[v0]|", views: priceLabel)
        addConstraintsWithFormat("H:|-5-[v0]|", views: kotaLabel)
        addConstraintsWithFormat("H:|-5-[v0]|", views: tglLabel)

        addConstraintsWithFormat("V:|-20-[v0]-5-[v1]-5-[v2]", views: priceLabel,kotaLabel,tglLabel)

    }
    
}

class AppDetailOffer: BaseCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Bantu Belikan"
        label.font = UIFont.systemFont(ofSize: 21)
        return label
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|[v0]|", views: nameLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v0(50)][v1(1)]|", views: nameLabel,dividerLineView )
        
    }
    
}

class AppDetailHeader: BaseCell {
    
    var app: App? {
        didSet {
            if let imageName = self.app?.ImageName {
                print("image name")
                print(imageName)
                Alamofire.request("http://titipanku.xyz/uploads/"+imageName).responseImage { response in
                    //debugPrint(response)
                    //let nama = self.app?.name
                    //print("gambar : "+imageName)
                    if let image = response.result.value {
                        //print("image downloaded: \(image)")
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addConstraintsWithFormat("H:|[v0]|", views: imageView)
        addConstraintsWithFormat("V:|[v0]-15-|", views: imageView)
    }
    
}

extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
}
