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

class barangDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
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
                           self.collectionView?.reloadData()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(AppDetailHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        collectionView?.register(AppDetailDescriptionCell.self, forCellWithReuseIdentifier: descriptionCellId)
        collectionView?.register(AppDetailButtons.self, forCellWithReuseIdentifier: buttonCellId)
        collectionView?.register(AppDetailOffer.self, forCellWithReuseIdentifier: offerCellId)
        collectionView?.register(ScreenshotsCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    @objc func handleDiskusi(){
        print("diskusi")
        let layout = UICollectionViewFlowLayout()
        let komentarController = KomentarBarangController(collectionViewLayout: layout)
        //komentarController.app = app
        navigationController?.pushViewController(komentarController, animated: true)
    }
    
    @objc func handleLain(){
        //perform(#selector(showHome), with: nil, afterDelay: 0.01)
        print(app?.id)
    }
    func showOffer() {
        print("pencet")
        //let layout = UICollectionViewFlowLayout()
        let appDetailController = OfferController()
        appDetailController.app = app
        navigationController?.pushViewController(appDetailController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId, for: indexPath) as! AppDetailDescriptionCell
            
            cell.nameLabel.text = app?.name
           
            let intHarga: Int? = app?.price
            cell.priceLabel.text = "Rp. " +  intHarga.map(String.init)!
            
            //cell.textView.text = app?.description
            cell.textView.attributedText = descriptionAttributedText()
            
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: offerCellId, for: indexPath) as! AppDetailOffer
            
            
            return cell
        }
        
        //untuk screenshot
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ScreenshotsCell
        
        cell.app = app
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //ukuran selain header
        if indexPath.item == 0 {
            return CGSize(width: view.frame.width, height: 270)
        }else if indexPath.item == 1{
            return CGSize(width: view.frame.width, height: 70)
        }else if indexPath.item == 2{
            return CGSize(width: view.frame.width, height: 70)
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
        cell?.layer.backgroundColor = UIColor.gray.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if indexPath.row == 2{
                cell?.layer.backgroundColor = UIColor.white.cgColor
                print("bantu")
                self.showOffer()
            }
        }
        
    }
    
    fileprivate func descriptionAttributedText() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Description\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
        let range = NSMakeRange(0, attributedText.string.characters.count)
        attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: range)
        
        if let desc = app?.description {
            attributedText.append(NSAttributedString(string: desc, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.darkGray]))
        }
        
        return attributedText
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
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE DESCRIPTION"
        tv.font = UIFont.systemFont(ofSize: 14)
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
        addSubview(textView)
        addSubview(qtyLabel)
        addSubview(countryLabel)
        addSubview(kotaLabel)
        addSubview(dividerLineView)
        
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: nameLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: priceLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: textView)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: qtyLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: countryLabel)
        addConstraintsWithFormat("H:|-15-[v0]-5-|", views: kotaLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|-15-[v0]-5-[v3]-5-[v1]-20-[v4]-5-[v5]-5-[v6]-25-[v2(1)]-15-|", views: nameLabel, textView, dividerLineView, priceLabel ,qtyLabel,countryLabel,kotaLabel )
        
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
        button.setTitle("Diskusi 1", for: .normal)
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



