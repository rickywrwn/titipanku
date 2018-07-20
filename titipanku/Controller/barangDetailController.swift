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

struct VarOffer: Decodable {
    let id: String
    let idPenawar: String
    let tglOffer: String
    let hargaPenawaran: String
    let tglPulang: String
    let idKota : String
    let kota: String
    let status: String
    
}

class barangDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var offers = [VarOffer]()
    
    var tinggiTextView : Float = 0
    
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
                    //print(self.offers)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.offers)
                    })
                    
                } catch let err {
                    print(err)
                }
                
            }) .resume()
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
                        //print(appDetail)
                        self.app = appDetail
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                           
                        })
                        
                    } catch let err {
                        print(err)
                    }
                    
                    
                }).resume()
            }
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
        if let email = self.app?.email,let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String  {
            print(emailNow + " dan " + email )
            if email == emailNow {
                self.fetchOffer{(offers) -> ()in
                    self.offers = offers
                    print("count" + String(self.offers.count))
                    self.collectionView?.reloadData()
                }
            }
        }
        
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBarangDetail), name: NSNotification.Name(rawValue: "reloadBarangDetail"), object: nil)
        
    }
    
    @objc func reloadBarangDetail(){
        self.fetchOffer{(offers) -> ()in
            self.offers = offers
            print(self.offers)
            print("count baru" + String(self.offers.count))
            self.collectionView?.reloadData()
        }
    }
    
    @objc func handleDiskusi(){
        print("diskusi")
        let layout = UICollectionViewFlowLayout()
        let komentarController = KomentarBarangController(collectionViewLayout: layout)
        //komentarController.app = app
        navigationController?.pushViewController(komentarController, animated: true)
    }
    func showOffer() {
        let appDetailController = OfferController()
        appDetailController.app = app
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    @objc func handleLain(){
        //perform(#selector(showHome), with: nil, afterDelay: 0.01)
        print(app?.id)
    }

    @objc func showAcceptOffer(_ notification: NSNotification) {
        let appDetailController = AcceptOffer()
        appDetailController.app = app
        if let idOffer = notification.userInfo?["idOffer"] as? String {
            appDetailController.idOffer = idOffer
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
            tinggiTextView = Float(heightOfText-55)
            cell.qtyLabel.text = "Jumlah Barang : " + (app?.qty)!
            cell.countryLabel.text = "Negara Pembelian : " + (app?.country)!
            cell.kotaLabel.text = "Kota Pengiriman : " + (app?.kotaKirim)!
            return cell
            
        }else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: buttonCellId, for: indexPath) as! AppDetailButtons
            cell.diskusiButton.addTarget(self, action: #selector(handleDiskusi), for: UIControlEvents.touchDown)
            cell.diskusiButton1.addTarget(self, action: #selector(handleLain), for: UIControlEvents.touchDown)
            
            return cell
        }else if indexPath.item == 2 {
            
            if self.app?.status == "1"{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! AppDetailUser
                //cell.diskusiButton.setTitle(app?.email, for: .normal)
                cell.user = (app?.email)!
                return cell
            }else {
                
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCellId, for: indexPath) as! AppDetailUser
            
            
            return cell
        }else if indexPath.item == 3 {
            if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String {
                
                if let status = self.app?.status {
                   
                    if status == "1"{
                        
                        if self.app?.email != emailNow{
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerCellId, for: indexPath) as! AppDetailOffer
                            return cell
                        }else{
                            //jika request milik sendiri
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerCellId, for: indexPath) as! AppDetailOffer
                            cell.nameLabel.text = "List Penawar"
                            
                            return cell
                        }
                    }
                }
            
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerCellId, for: indexPath) as! AppDetailOffer
            
            return cell
        }
        
        if let email = self.app?.email,let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String  {
            if email == emailNow && offers.count > 0 {
                
                for i in 0 ..< offers.count {
                    if indexPath.item == 4 + i {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerListCellId, for: indexPath) as! AppOfferList
//                        cell.diskusiButton.setTitle(offers[i].idPenawar, for: .normal)
//                        cell.diskusiButton1.setTitle(offers[i].tglPulang, for: .normal)cell.collectionview
                        cell.varOffer = offers[i]
                        cell.app = app
                        return cell
                    }
                }
            }else if email == emailNow && offers.count == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCellKosongCellId, for: indexPath) as! AppCellKosong
                return cell
            }else if email != emailNow {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppCellKosongCellId, for: indexPath) as! AppCellKosong
                return cell
            }
        }
        
        //untuk screenshot
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotsCell
        
        cell.app = app
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4 + offers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //ukuran selain header
        if indexPath.item == 0 {
            return CGSize(width: view.frame.width, height: CGFloat(270 + tinggiTextView))
        }else if indexPath.item == 1{
            return CGSize(width: view.frame.width, height: 70)
        }else if indexPath.item == 2{
            return CGSize(width: view.frame.width, height: 220)
        }else if indexPath.item == 3{
            return CGSize(width: view.frame.width, height: 70)
        }
        
        if let emailNow = UserDefaults.standard.value(forKey: "loggedEmail") as? String, let email = app?.email {
            
            if email == emailNow  && offers.count > 0{
                //jika user sendiri
                for i in 0 ..< offers.count {
                    if indexPath.item == 4 + i {
                        return CGSize(width: view.frame.width, height: 110)
                    }
                }
            }else if email == emailNow  && offers.count == 0{
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
                if indexPath.row == 3  {
                    cell?.layer.backgroundColor = UIColor.gray.cgColor
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        cell?.layer.backgroundColor = UIColor.white.cgColor
                        print("bantu")
                        self.showOffer()
                    }
                }
            }else{
                for i in 0 ..< offers.count {
                    if indexPath.item == 4 + i {
                        //print("penawar" + offers[i].id)
                        // lihat penawaran yang masuk
                        
                        
                        let appDetailController = AcceptOffer()
                        appDetailController.app = app
                        appDetailController.idOffer = offers[i].id
                        navigationController?.pushViewController(appDetailController, animated: true)
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

class AppCellKosong: BaseCell {
    
    
    override func setupViews() {
        super.setupViews()
        
    }
    
}

class AppDetailDescriptionCell: BaseCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "harga"
        label.font = UIFont.systemFont(ofSize: 21)
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
        label.font = UIFont.systemFont(ofSize: 10)
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
    
    let qtyLabel: UILabel = {
        let label = UILabel()
        label.text = "qty"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.text = "count"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let kotaLabel: UILabel = {
        let label = UILabel()
        label.text = "kota"
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
        
        addSubview(nameLabel)
        addSubview(priceLabel)
        addSubview(tglLabel)
        addSubview(textView)
        addSubview(qtyLabel)
        addSubview(countryLabel)
        addSubview(kotaLabel)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: nameLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: priceLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: tglLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: textView)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: qtyLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: countryLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: kotaLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-15-[v0]-5-[v3]-5-[v7]-15-[v1]-1-[v4]-5-[v5]-5-[v6]-25-[v2(1)]-15-|", views: nameLabel, textView, dividerLineView, priceLabel ,qtyLabel,countryLabel,kotaLabel,tglLabel )
        
    }
    
}

class AppDetailButtons: BaseCell {
    
    let diskusiButton : UIButton = {
        let button = UIButton()
        button.setTitle("Diskusi", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let diskusiButton1 : UIButton = {
        let button = UIButton()
        button.setTitle("Titip Juga", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(diskusiButton)
        addSubview(diskusiButton1)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-30-[v0(150)]-4-[v1(150)]-30-|", views: diskusiButton, diskusiButton1)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v0(50)]", views: diskusiButton )
        addConstraintsWithFormat("V:|[v0(50)][v1(1)]|", views: diskusiButton1,dividerLineView )
        
    }
    
}

class AppDetailUser: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
 
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
        
        userCollectionView.register(userTawarBarangCell.self, forCellWithReuseIdentifier: userTawarBarangCellId)
        
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        addConstraintsWithFormat("H:|[v0]|", views: userCollectionView)
        
        addConstraintsWithFormat("V:|[v0][v1(1)]|", views: userCollectionView,dividerLineView )
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userTawarBarangCellId, for: indexPath) as! userTawarBarangCell
        //cell.app = appCategory?.apps?[indexPath.item]
        cell.backgroundColor = UIColor.clear
        
        if indexPath.item == 0{
            cell.nameLabel.text = user
            cell.LabelA.text = "Requester"
            DispatchQueue.main.async{
                
                Alamofire.request("http://titipanku.xyz/uploads/"+self.user+".jpg").responseImage { response in
                    //debugPrint(response)
                    //let nama = self.app?.name
                    //print("gambar : "+imageName)
                    if let image = response.result.value {
                        //print("image downloaded: \(image)")
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
            
            print("request")
        }else{
            print("penawar")
        }
        
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
        cell.backgroundColor = UIColor.brown
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
        }else{
            let appDetailController = AcceptOffer()
            let dataIdOffer:[String: String] = ["idOffer": (varOffer?.id)!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toAcceptOffer"), object: nil, userInfo: dataIdOffer)
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
        
        addConstraintsWithFormat("H:|-150-[v0(150)]-150-|", views: nameLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v0(50)][v1(1)]|", views: nameLabel,dividerLineView )
        
    }
    
}

class AppDetailHeader: BaseCell {
    
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



