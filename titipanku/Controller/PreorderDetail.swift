//
//  PreorderDetail.swift
//  titipanku
//
//  Created by Ricky Wirawan on 24/06/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import Alamofire_SwiftyJSON
import SKActivityIndicatorView
import Hue

struct VarOfferPreorder: Decodable {
    let id: String
    let idPreorder: String
    let idPembeli: String
    let tglBeli: String
    let qty: String
    let kota: String
    let idKota : String
    let hargaOngkir: String
    let pengiriman : String
    let nomorResi : String
    let valueHarga : String
    let status: String
}

class PreorderDetail: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var offers = [VarOfferPreorder]()
    
    var tinggiTextView : Float = 0
    
    var app: App? {
        didSet {
            
            if app?.Screenshots != nil {
                return
            }
            
            if let id = app?.id {
                let urlString = "http://titipanku.xyz/api/DetailPreorder.php?id=\(id)"
                
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
    
    
    func fetchBeli(_ completionHandler: @escaping ([VarOfferPreorder]) -> ()) {
        if let id = self.app?.id {
            let urlString = "http://titipanku.xyz/api/GetBeli.php?idPreorder=\(id)"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.offers = try decoder.decode([VarOfferPreorder].self, from: data)
                    print(self.offers)
                    print(self.offers.count)
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
    
    func fetchBeliPembeli(_ completionHandler: @escaping ([VarOfferPreorder]) -> ()) {
        if let id = self.app?.id, let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            let urlString = "http://titipanku.xyz/api/GetBeliPembeli.php?idPreorder=\(id)&idPembeli=\(emailNow)"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.offers = try decoder.decode([VarOfferPreorder].self, from: data)
                    print(self.offers)
                    print(self.offers.count)
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
        
        collectionView?.register(AppDetailDescriptionCell1.self, forCellWithReuseIdentifier: descriptionCellId)
        collectionView?.register(AppDetailButtons1.self, forCellWithReuseIdentifier: buttonCellId)
        collectionView?.register(AppDetailOffer1.self, forCellWithReuseIdentifier: offerCellId)
        collectionView?.register(AppDetailUser1.self, forCellWithReuseIdentifier: userCellId)
        collectionView?.register(AppOfferList1.self, forCellWithReuseIdentifier: offerListCellId)
        collectionView?.register(AppCellKosong.self, forCellWithReuseIdentifier: AppCellKosongCellId)
        collectionView?.register(ScreenshotsCell.self, forCellWithReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAcceptPreorder(_:)), name: NSNotification.Name(rawValue: "toAcceptPreorder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLihatPreorder(_:)), name: NSNotification.Name(rawValue: "toLihatPreorder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLihatResiPreorder(_:)), name: NSNotification.Name(rawValue: "toLihatResiPreorder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAcceptedPreorder(_:)), name: NSNotification.Name(rawValue: "toAcceptedPreorder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPengirimanPreorder(_:)), name: NSNotification.Name(rawValue: "toPengirimanPreorder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPenerimaanPreorder(_:)), name: NSNotification.Name(rawValue: "toPenerimaanPreorder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBarangDetail), name: NSNotification.Name(rawValue: "reloadPreorderDetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUser(_:)), name: NSNotification.Name(rawValue: "toUserPreorder"), object: nil)
         SKActivityIndicator.show("Loading...")
        if let email = self.app?.email, let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            if email == emailNow {
                self.fetchBeli{(offers) -> ()in
                    self.offers = offers
                    print("count" + String(self.offers.count))
                    self.collectionView?.reloadData()
                    SKActivityIndicator.dismiss()
                }
            }else{
                self.fetchBeliPembeli{(offers) -> ()in
                    self.offers = offers
                    print("count" + String(self.offers.count))
                    self.collectionView?.reloadData()
                    SKActivityIndicator.dismiss()
                }
            }
        }
        
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
        navigationItem.title = "Preorder"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .done, target: self, action: #selector(handleCancle))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleSubmit))
        // Assign the navigation item to the navigation bar
        
        navbar.setItems([navigationItem], animated: false)
        
        // Make the navigation bar a subview of the current view controller
        
        collectionView?.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - 64))
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(hex: "#4373D8")
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @objc func handleCancle(){
        self.dismiss(animated: true)
    }
    
    @objc func reloadBarangDetail(){
        self.offers = []
        self.collectionView?.reloadData()
        print("count baru" + String(self.offers.count))
        SKActivityIndicator.show("Loading...")
        if let email = self.app?.email, let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
            if email == emailNow {
                
                self.fetchBeli{(offers) -> ()in
                    self.offers = offers
                    print(self.offers)
                    print("count baru" + String(self.offers.count))
                    self.collectionView!.reloadData()
                    SKActivityIndicator.dismiss()
                }
            }else{
                
                self.fetchBeliPembeli{(offers) -> ()in
                    self.offers = offers
                    print(self.offers)
                    print("count baru" + String(self.offers.count))
                    self.collectionView!.reloadData()
                    SKActivityIndicator.dismiss()
                }
            }
            
        }
    }
    
    @objc func handleDiskusi(){
        let komentarController = KomentarPreorder()
        //komentarController.app = app
        print(app?.status)
        //print(app)
        //print(offers)
        komentarController.app = self.app
        present(komentarController, animated: true, completion: {
        })
    }
    func showOffer() {
        let appDetailController = OfferController()
        appDetailController.app = app
        present(appDetailController, animated: true, completion: {
        })
    }
    
    @objc func handleLain(){
        print(app?.id)
    }
    
    @objc func showUser(_ notification: NSNotification) {
        
        let layout = UICollectionViewFlowLayout()
        let appDetailController = UserController()
        if let varOffer = notification.userInfo?["email"] as? String {
            UserController.emailUser.email = varOffer
            UserController.emailUser.status = "lain"
        }
        present(appDetailController, animated: true, completion: {
        })
        //navigationController?.pushViewController(appDetailController, animated: true)
    }
    @objc func showAcceptPreorder(_ notification: NSNotification) {
        let appDetailController = AcceptPembelian()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOfferPreorder {
            appDetailController.varOffer = varOffer
        }
        present(appDetailController, animated: true, completion: {
        })
    }
    @objc func showLihatPreorder(_ notification: NSNotification) {
        let appDetailController = LihatPreorder()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOfferPreorder {
            appDetailController.varOffer = varOffer
        }
        present(appDetailController, animated: true, completion: {
        })
    }
    @objc func showLihatResiPreorder(_ notification: NSNotification) {
        let appDetailController = LihatResiPreorder()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOfferPreorder {
            appDetailController.varOffer = varOffer
        }
        present(appDetailController, animated: true, completion: {
        })
    }
    @objc func showAcceptedPreorder(_ notification: NSNotification) {
        let appDetailController = AcceptedPembelian()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOfferPreorder {
            appDetailController.varOffer = varOffer
        }
        present(appDetailController, animated: true, completion: {
        })
    }
    @objc func showPengirimanPreorder(_ notification: NSNotification) {
        let appDetailController = PengirimanPembelian()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOfferPreorder {
            appDetailController.varOffer = varOffer
        }
        present(appDetailController, animated: true, completion: {
        })
    }
    @objc func showPenerimaanPreorder(_ notification: NSNotification) {
        let appDetailController = PenerimaanPembelian()
        appDetailController.app = app
        if let varOffer = notification.userInfo?["varOffer"] as? VarOfferPreorder {
            appDetailController.varOffer = varOffer
        }
        present(appDetailController, animated: true, completion: {
        })
    }
    @objc func showBeliPreorder() {
        let appDetailController = AcceptPreorder()
        appDetailController.app = app
        present(appDetailController, animated: true, completion: {
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId, for: indexPath) as! AppDetailDescriptionCell1
            
            cell.nameLabel.text = app?.name
            cell.priceLabel.text = "Rp. " +   (app?.price)!
            cell.tglLabel.text = "Tanggal Posting : " + (app?.tglPost)!
            //cell.textView.text = app?.description
            cell.textView.attributedText = descriptionAttributedText()
            //menghitung tinggi textview
            let sizeThatFitsTextView = cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.size.width, height: CGFloat(MAXFLOAT)))
            let heightOfText = sizeThatFitsTextView.height
            tinggiTextView = Float(heightOfText-55)
            cell.brandLabel.text = (app?.brand)!
            cell.qtyLabel.text = (app?.qty)!
            cell.countryLabel.text =  (app?.country)!
            cell.kotaLabel.text = (app?.kotaKirim)!
            cell.deadlineLabel.text = (app?.deadline)!
            cell.qtyLabel.text = (app?.qty)!
            return cell
            
        }else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buttonCellId, for: indexPath) as! AppDetailButtons1
            cell.diskusiButton.addTarget(self, action: #selector(handleDiskusi), for: UIControlEvents.touchDown)
            cell.priceLabel.text = "Rp " + (app?.price)!
            return cell
        }else if indexPath.item == 2 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! AppDetailUser1
            //cell.diskusiButton.setTitle(app?.email, for: .normal)
            cell.user = (app?.email)!
            cell.backgroundColor = UIColor(hex: "#4b6584")
            return cell
            
        }else if indexPath.item == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerCellId, for: indexPath) as! AppDetailOffer1
            
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
//                if let status = self.app?.status {
//                    if status == "1"{
//                        if self.app?.email == emailNow{
//                            //jika request milik sendiri
//                            cell.nameLabel.text = "List Pembeli"
//
//                        }else{
//
//                            cell.nameLabel.text = "Beli"
//                        }
//                    }else if status == "2"{
//                        if self.app?.email == emailNow{
//                            //jika request milik sendiri
//                            cell.nameLabel.text = "List Pembeli"
//
//                        }else{
//                            cell.nameLabel.text = "Beli"
//                        }
//                    }
//                }
                if self.app?.email == emailNow{
                    //jika request milik sendiri
                    cell.nameLabel.text = "List Pembeli"
                    
                }else{
                    cell.nameLabel.text = "Beli"
                }
            }

            return cell
        }else if indexPath.item == 4{
            
            if let email = self.app?.email,let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String  {
                if email == emailNow && offers.count > 0 {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListCellId, for: indexPath) as! AppOfferList1
                    //cell.varOffer = offers[i]
                    //cell.backgroundColor = UIColor.black
                    cell.offers = offers
                    cell.app = app
                    cell.offerCollectionView.reloadData()
                    return cell
                    
                }else if email == emailNow && offers.count == 0{
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCellKosongCellId, for: indexPath) as! AppCellKosong
                    return cell
                }else if email != emailNow && offers.count > 0 {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListCellId, for: indexPath) as! AppOfferList1
                    //cell.varOffer = offers[i]
                    //cell.backgroundColor = UIColor.black
                    cell.offers = offers
                    cell.app = app
                    cell.offerCollectionView.reloadData()
                    return cell
                    
                }else if email != emailNow && offers.count == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCellKosongCellId, for: indexPath) as! AppCellKosong
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
            return CGSize(width: view.frame.width, height: CGFloat(270 + tinggiTextView))
        }else if indexPath.item == 1{
            return CGSize(width: view.frame.width, height: 145)
        }else if indexPath.item == 2{
            return CGSize(width: view.frame.width, height: 235)
        }else if indexPath.item == 3{
            return CGSize(width: view.frame.width, height: 70)
        }
        
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let email = app?.email {
            
            if email == emailNow  && offers.count > 0{
                //jika user sendiri
                if indexPath.item == 4{
                    return CGSize(width: view.frame.width, height: 350)
                }
            }else if email == emailNow  && offers.count == 0{
                return CGSize(width: view.frame.width, height: 0)
            }else if email != emailNow  && offers.count > 0{
                //jika user sendiri
                if indexPath.item == 4{
                    return CGSize(width: view.frame.width, height: 350)
                }
            }else if email != emailNow  && offers.count == 0{
                return CGSize(width: view.frame.width, height: 0)
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
                //pembeli
                if indexPath.row == 3  {
                    cell?.layer.backgroundColor = UIColor.gray.cgColor
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        var cekBeli = false
//                        cell?.layer.backgroundColor = UIColor.white.cgColor
//                        for i in 0 ..< self.offers.count {
//                            if emailNow == self.offers[i].idPembeli{
//                                print("cancel")
//                                cekBeli = true
//                            }
//                        }
                        self.showBeliPreorder()
//                        if cekBeli == false{
//                                self.showBeliPreorder()
//                        }
                    }
                }
            }
        }
        
    }
    
    fileprivate func descriptionAttributedText() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Deskripsi Barang\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)])
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let range = NSMakeRange(0, attributedText.string.characters.count)
        attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: range)
        
        if let desc = app?.description {
            attributedText.append(NSAttributedString(string: desc, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.darkGray]))
        }
        
        return attributedText
    }
    
}


class AppDetailDescriptionCell1: BaseCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "harga"
        label.font = UIFont.systemFont(ofSize: 22)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "harga"
        label.font = UIFont.systemFont(ofSize: 19)
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
        iv.image = UIImage.init(named: "amount")
        return iv
    }()
    
    let qtyLabelKiri: UILabel = {
        let label = UILabel()
        label.text = "Jumlah:"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let qtyLabel: UILabel = {
        let label = UILabel()
        label.text = "count"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    let imageViewBrand: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage.init(named: "brand")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let brandLabelKiri: UILabel = {
        let label = UILabel()
        label.text = "Brand:"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "count"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let imageViewCountry: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage.init(named: "country")
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
        iv.image = UIImage.init(named: "city")
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
    
    let imageViewDeadline: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage.init(named: "deadline")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let deadlineLabelKiri: UILabel = {
        let label = UILabel()
        label.text = "Tanggal Pulang:"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let deadlineLabel: UILabel = {
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
        addSubview(brandLabelKiri)
        addSubview(brandLabel)
        addSubview(imageViewBrand)
        addSubview(countryLabelKiri)
        addSubview(countryLabel)
        addSubview(imageViewCountry)
        addSubview(kotaLabelKiri)
        addSubview(kotaLabel)
        addSubview(imageViewKota)
        addSubview(deadlineLabelKiri)
        addSubview(deadlineLabel)
        addSubview(imageViewDeadline)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-15-[v0]", views: nameLabel)
        addConstraintsWithFormat("H:|-15-[v0]", views: tglLabel)
        addConstraintsWithFormat("H:|-10-[v0]", views: textView)
        //addConstraintsWithFormat("H:|-15-[v0]-5-|", views: qtyLabel)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewQty,qtyLabelKiri,qtyLabel)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewBrand,brandLabelKiri,brandLabel)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewCountry,countryLabelKiri,countryLabel)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewKota,kotaLabelKiri,kotaLabel)
        addConstraintsWithFormat("H:|-15-[v0(17)]-5-[v1]-5-[v2]", views: imageViewDeadline,deadlineLabelKiri,deadlineLabel)
        addConstraintsWithFormat("H:|[v0]", views: dividerLineView)
        
        addConstraintsWithFormat("V:[v0]-5-[v3]-15-[v1]", views: nameLabel, textView, priceLabel ,tglLabel)
        addConstraintsWithFormat("V:[v4(17)]-5-[v0(17)]-5-[v1(17)]-5-[v2(17)]-5-[v3(17)]|", views: imageViewBrand,imageViewCountry,imageViewKota,imageViewDeadline,imageViewQty)
        addConstraintsWithFormat("V:[v4]-5-[v0]-5-[v1]-5-[v2]-5-[v3]|", views: brandLabelKiri,countryLabelKiri,kotaLabelKiri,deadlineLabelKiri,qtyLabelKiri)
        addConstraintsWithFormat("V:[v4]-5-[v0]-5-[v1]-5-[v2]-5-[v3]|", views: brandLabel,countryLabel,kotaLabel,deadlineLabel,qtyLabel)
    }
}

class AppDetailButtons1: BaseCell {
    
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

class AppDetailUser1: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate let userTawarBarangCellId = "userTawarBarangCellId"
    
    var user : String = ""
    
    let userCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
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
        
        userCollectionView.register(userTawarBarangCell1.self, forCellWithReuseIdentifier: userTawarBarangCellId)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("H:|[v0]|", views: userCollectionView)
        
        addConstraintsWithFormat("V:|[v0][v1(1)]|", views: userCollectionView,dividerLineView )
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userTawarBarangCellId, for: indexPath) as! userTawarBarangCell1
        //cell.app = appCategory?.apps?[indexPath.item]
        cell.backgroundColor = UIColor.clear
        
        if indexPath.item == 0{
            cell.nameLabel.text = user
            cell.LabelA.text = "Penjual"
            cell.backgroundColor = UIColor.white
            DispatchQueue.main.async{
                
                Alamofire.request("http://titipanku.xyz/uploads/"+self.user+".jpg").responseImage { response in
                    if let image = response.result.value {
                        cell.imageView.image = image
                    }
                }
            }
            
            return cell
        }else{
            cell.LabelA.text = "Traveller"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/2-5, height: frame.height - 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0{
            print("penjual")
            let dataIdOffer:[String: String] = ["email": user]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toUserPreorder"), object: nil, userInfo: dataIdOffer)
        }else{
            print("penawar")
        }
        
    }
    
}


class userTawarBarangCell1: BaseCell {
    
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


class AppOfferList1: BaseCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    fileprivate let offerListDalamId = "offerListDalamId"
    fileprivate let offerListKiriCellId = "offerListKiriCellId"
    fileprivate let offerListKananCellId = "offerListKananCellId"
    
    //    var varOffer: VarOffer? {
    //        didSet {
    //
    //        }
    //
    //    }
    
    var offers = [VarOfferPreorder]()
    
    var app: App? {
        didSet {
            
            if app?.Screenshots != nil {
                return
            }
            
            if let id = app?.id {
                let urlString = "http://titipanku.xyz/api/DetailPreorder.php?id=\(id)"
                
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
        
        offerCollectionView.register(AppOfferListDalam1.self, forCellWithReuseIdentifier: offerListDalamId)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("H:|[v0]|", views: offerCollectionView)
        
        addConstraintsWithFormat("V:|[v0][v1(1)]|", views: offerCollectionView,dividerLineView )
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return offers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        for i in 0 ..< offers.count {
            
            if indexPath.row == i{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListDalamId, for: indexPath) as! AppOfferListDalam1
                cell.app = app
                //cell.backgroundColor = UIColor.brown
                cell.varOffer = offers[i]
                cell.offerCollectionView.reloadData()
                return cell
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListDalamId, for: indexPath) as! AppOfferListDalam1
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


class AppOfferListDalam1: BaseCell , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    fileprivate let offerListKiriCellId = "offerListKiriCellId"
    fileprivate let offerListKananCellId = "offerListKananCellId"
    
    var varOffer: VarOfferPreorder? {
        didSet {
            
        }
        
    }
    
    
    var app: App? {
        didSet {
            
            if app?.Screenshots != nil {
                return
            }
            
            if let id = app?.id {
                let urlString = "http://titipanku.xyz/api/DetailPreorder.php?id=\(id)"
                
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
        
        offerCollectionView.register(OfferListKiri1.self, forCellWithReuseIdentifier: offerListKiriCellId)
        offerCollectionView.register(OfferListKanan1.self, forCellWithReuseIdentifier: offerListKananCellId)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("H:|[v0]|", views: offerCollectionView)
        
        addConstraintsWithFormat("V:|[v0][v1(1)]|", views: offerCollectionView,dividerLineView )
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListKiriCellId, for: indexPath) as! OfferListKiri1
            //cell.app = appCategory?.apps?[indexPath.item]
            //cell.backgroundColor = UIColor.red
            cell.nameLabel.text = varOffer?.idPembeli
            DispatchQueue.main.async{
                
                Alamofire.request("http://titipanku.xyz/uploads/"+(self.varOffer?.idPembeli)!+".jpg").responseImage { response in
                    if let image = response.result.value {
                        cell.imageView.image = image
                    }
                }
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListKananCellId, for: indexPath) as! OfferListKanan1
            //cell.app = appCategory?.apps?[indexPath.item]
            //cell.backgroundColor = UIColor.blue
            cell.priceLabel.text = "Kuantitas : " + (varOffer?.qty)!
            if varOffer?.status == "1"{
                cell.kotaLabel.text = "Status : Belum Disetujui"
            }else if varOffer?.status == "2"{
                cell.kotaLabel.text = "Status : Sudah Disetujui"
            }else if varOffer?.status == "3"{
                cell.kotaLabel.text = "Status : Barang Sudah Dibelikan"
            }else if varOffer?.status == "4"{
                cell.kotaLabel.text = "Status : Barang Sudah Dikirim"
            }else if varOffer?.status == "5"{
                cell.kotaLabel.text = "Status : Preorder Selesai"
            }
            cell.tglLabel.text = "Tgl Pembelian : " + (varOffer?.tglBeli)!
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListKiriCellId, for: indexPath) as! OfferListKiri1
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
            print(varOffer?.idPembeli)
            let dataIdOffer:[String: String] = ["email": (varOffer?.idPembeli)!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toUserPreorder"), object: nil, userInfo: dataIdOffer)
        }else{
            print(varOffer)
            
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let email = app?.email, let status = varOffer?.status {
                if emailNow == email{
                    //print(varOffer?.hargaPenawaran)
                    if status == "1"{
                        let dataIdOffer:[String: VarOfferPreorder] = ["varOffer": varOffer!]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toAcceptPreorder"), object: nil, userInfo: dataIdOffer)
                    }else if status == "2"{
                        let dataIdOffer:[String: VarOfferPreorder] = ["varOffer": varOffer!]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toAcceptedPreorder"), object: nil, userInfo: dataIdOffer)
                    }else if status == "3"{
                        let dataIdOffer:[String: VarOfferPreorder] = ["varOffer": varOffer!]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toPengirimanPreorder"), object: nil, userInfo: dataIdOffer)
                    }else if status == "4"{
                        let dataIdOffer:[String: VarOfferPreorder] = ["varOffer": varOffer!]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toLihatResiPreorder"), object: nil, userInfo: dataIdOffer)
                    }else if status == "5"{
                        let dataIdOffer:[String: VarOfferPreorder] = ["varOffer": varOffer!]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toLihatPreorder"), object: nil, userInfo: dataIdOffer)
                    }
                }else{
                    print("pembeli")
                    //print(varOffer?.hargaPenawaran)
                    if status == "4"{
                        let dataIdOffer:[String: VarOfferPreorder] = ["varOffer": varOffer!]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toPenerimaanPreorder"), object: nil, userInfo: dataIdOffer)
                    }else if status == "5"{
                        let dataIdOffer:[String: VarOfferPreorder] = ["varOffer": varOffer!]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toLihatResiPreorder"), object: nil, userInfo: dataIdOffer)
                    }else{
                        
                        let dataIdOffer:[String: VarOfferPreorder] = ["varOffer": varOffer!]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toLihatPreorder"), object: nil, userInfo: dataIdOffer)
                    }
                }
            }
            
        }
    }
}

class OfferListKiri1: BaseCell {
    
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
        
        addConstraintsWithFormat("V:|-10-[v0(85)]-5-[v1]", views: imageView,nameLabel)
        
    }
    
}


class OfferListKanan1: BaseCell {
    
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

class AppDetailOffer1: BaseCell {
    
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

class AppDetailHeader1: BaseCell {
    
    var app: App? {
        didSet {
            if let imageName = self.app?.ImageName {
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
        addSubview(dividerLineView)
        addConstraintsWithFormat("H:|[v0]|", views: imageView)
        addConstraintsWithFormat("V:|[v0]|", views: imageView)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)
    }
    
}

