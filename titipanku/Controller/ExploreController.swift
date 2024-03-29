//
//  ExploreController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 16/04/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView

struct listData: Decodable {
    let explore : [explore]
}
struct explore: Decodable {
    let name : String
    let isi : [isi]
}
struct isi: Decodable {
    let id: String
    let nama: String
}
extension ExploreController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text{
            let nextCont = HasilSearch()
            nextCont.isiData = searchText
            present(nextCont, animated: true, completion: {
            })
        }
    }
}
class ExploreController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let exploreCellId = "exploreCellId"
    
    var isiExplore : listData?
    var isiData = [isi]()
    func fetchExplore(_ completionHandler: @escaping (listData) -> ()) {
        
        let urlString = "http://titipanku.xyz/api/GetExplore.php"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                self.isiExplore = try decoder.decode(listData.self, from: data)
                print(self.isiExplore)
                print("count isiexplore")
                print(self.isiExplore?.explore.count)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.collectionView?.reloadData()
                    completionHandler(self.isiExplore!)
                })
                
            } catch let err {
                print(err)
                
                //SKActivityIndicator.dismiss()
            }
            
        }) .resume()
        
    }
    
    fileprivate let categoryCellId = "categoryCellId"
    fileprivate let countryCellId = "countryCellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKActivityIndicator.show("Loading...")
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(categoryCollectionView.self, forCellWithReuseIdentifier: categoryCellId)
        collectionView?.register(countryCollectionView.self, forCellWithReuseIdentifier: countryCellId)
        NotificationCenter.default.addObserver(self, selector: #selector(showDetailNegara(_:)), name: NSNotification.Name(rawValue: "showDetailNegara"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showDetailKategori(_:)), name: NSNotification.Name(rawValue: "showDetailKategori"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadExplore(_:)), name: NSNotification.Name(rawValue: "reloadExplore"), object: nil)
        setupLayout()
        navigationItem.title = "Explore"
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        
        self.fetchExplore{(isiExplore) -> ()in
            self.isiExplore = isiExplore
            //self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
    }

    @objc func showDetailNegara(_ notification: NSNotification) {
        let nextCont = ExploreNegara()
        if let dataNegara = notification.userInfo?["isiNegara"] as? isi {
            nextCont.isiData = dataNegara
            
            present(nextCont, animated: true, completion: {
            })
        }
    }

    @objc func showDetailKategori(_ notification: NSNotification) {
        print("It Works")
        let nextCont = ExploreKategori()
        if let dataKategori = notification.userInfo?["isiKategori"] as? isi {
            nextCont.isiData = dataKategori
            present(nextCont, animated: true, completion: {
            })
        }
    }

    @objc func reloadExplore(_ notification: NSNotification) {
        print(self.isiExplore)
        SKActivityIndicator.show("Loading...")
        
        
        self.fetchExplore{(isiExplore) -> ()in
            self.isiExplore = isiExplore
            print(self.isiExplore)
            SKActivityIndicator.dismiss()
        }
    }
    
    private func setupLayout(){
        
        view.addSubview(collectionView!)
        collectionView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: 500).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 60).isActive = true
     
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = isiExplore?.explore.count {
            return count
        }else{
            print("asd")
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: countryCellId, for: indexPath) as! countryCollectionView
            cell.dataExplore = isiExplore?.explore[indexPath.row]
            cell.nameLabel.text = isiExplore?.explore[indexPath.row].name
            cell.ujungCell.reloadData()
            return cell
        }else if indexPath.row == 1{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellId, for: indexPath) as! categoryCollectionView
            cell.dataExplore = isiExplore?.explore[indexPath.row]
            cell.nameLabel.text = isiExplore?.explore[indexPath.row].name
            cell.ujungCell.reloadData()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellId, for: indexPath) as! categoryCollectionView
        cell.dataExplore = isiExplore?.explore[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0{
            
            print("request")
        }else{
            print("penawar")
        }
        
    }
    
}


class categoryCollectionView: BaseCell,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var dataExplore : explore?
    fileprivate let catId = "catId"
    fileprivate let couId = "couId"
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Belum Ada"
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ujungCell: UICollectionView = {
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
        
        addSubview(ujungCell)
        addSubview(nameLabel)
        addSubview(dividerLineView)
        
        ujungCell.dataSource = self
        ujungCell.delegate = self

        ujungCell.register(categoryCollect.self, forCellWithReuseIdentifier: catId)
        ujungCell.register(countryCollect.self, forCellWithReuseIdentifier: couId)
        
        addConstraintsWithFormat("H:|[v0]|", views: ujungCell)
        addConstraintsWithFormat("H:|-15-[v0]|", views: nameLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v1]-5-[v0]-15-[v2(1)]|", views: ujungCell,nameLabel,dividerLineView)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (dataExplore?.isi.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: catId, for: indexPath) as! categoryCollect
        cell.nameLabel.text = dataExplore?.isi[indexPath.row].nama
        cell.imageView.image = UIImage.init(named: (dataExplore?.isi[indexPath.row].nama)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(reuseIdentifier)
        print(dataExplore?.isi[indexPath.row].nama)
        let dataKategori:[String: isi] = ["isiKategori": (dataExplore?.isi[indexPath.row])!]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showDetailKategori"), object: nil, userInfo: dataKategori)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 190)
    }
    
}

class countryCollectionView: BaseCell,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var dataExplore : explore?
    fileprivate let catId = "catId"
    fileprivate let couId = "couId"
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Belum Ada"
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ujungCell: UICollectionView = {
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
        
        addSubview(ujungCell)
        addSubview(nameLabel)
        addSubview(dividerLineView)
        
        ujungCell.dataSource = self
        ujungCell.delegate = self
        
        ujungCell.register(categoryCollect.self, forCellWithReuseIdentifier: catId)
        ujungCell.register(countryCollect.self, forCellWithReuseIdentifier: couId)
        
        addConstraintsWithFormat("H:|[v0]|", views: ujungCell)
        addConstraintsWithFormat("H:|-15-[v0]|", views: nameLabel)
        addConstraintsWithFormat("H:|[v0]|", views: dividerLineView)
        
        addConstraintsWithFormat("V:|[v1]-5-[v0]-15-[v2(1)]|", views: ujungCell,nameLabel,dividerLineView)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (dataExplore?.isi.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: couId, for: indexPath) as! countryCollect
        cell.nameLabel.text = dataExplore?.isi[indexPath.row].nama
        cell.imageView.image = UIImage.init(named: (dataExplore?.isi[indexPath.row].nama)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(reuseIdentifier)
        print(dataExplore?.isi[indexPath.row].nama)
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showDetailNegara"), object: nil)
        let dataNegara:[String: isi] = ["isiNegara": (dataExplore?.isi[indexPath.row])!]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showDetailNegara"), object: nil, userInfo: dataNegara)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 190)
    }
    
}

class categoryCollect: BaseCell {
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "coba")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    var nameLabel: UILabel = {
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
        
        addConstraintsWithFormat("H:|-5-[v0]-5-|", views: imageView)
        addConstraintsWithFormat("H:|-5-[v0]-5-|", views: nameLabel)
        
        addConstraintsWithFormat("V:|-10-[v0(150)]-5-[v1]", views: imageView,nameLabel)
        
    }
    
}
class countryCollect: BaseCell {
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.image = UIImage(named: "coba")
        iv.layer.masksToBounds = true
        return iv
    }()
    
    var nameLabel: UILabel = {
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
        
        addConstraintsWithFormat("H:|-5-[v0]-5-|", views: imageView)
        addConstraintsWithFormat("H:|-5-[v0]-5-|", views: nameLabel)
        
        addConstraintsWithFormat("V:|-10-[v0(150)]-5-[v1]", views: imageView,nameLabel)
        
    }
    
}
