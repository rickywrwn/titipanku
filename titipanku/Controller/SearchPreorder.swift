//
//  SearchPreorder.swift
//  titipanku
//
//  Created by Ricky Wirawan on 20/08/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Alamofire
import AlamofireImage
import Hue

class SearchPreorder: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let RequestCellId = "RequestCellId"
    var requests = [App]()
    var isiData : String = ""
    
    struct varFilter {
        static var negara = ""
        static var kategori = ""
        static var search = ""
    }
    
    func fetchRequests(_ completionHandler: @escaping ([App]) -> ()) {
        if let search : String = isiData{
            let urlString = "http://titipanku.xyz/api/SearchPreorder.php?filter=none&negara=none&kategori=none&search=\(String(describing: search))"
            
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.requests = try decoder.decode([App].self, from: data)
                    print(self.requests)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.requests)
                    })
                } catch let err {
                    print(err)
                    
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
    }
    
    func fetchKategori(_ completionHandler: @escaping ([App]) -> ()) {
        if let search : String = isiData, let kategori : String = varFilter.kategori{
            let urlString = "http://titipanku.xyz/api/SearchPreorder.php?filter=kategori&negara=none&kategori=\(String(describing: kategori))&search=\(String(describing: search))"
            print(urlString)
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.requests = try decoder.decode([App].self, from: data)
                    print(self.requests)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.requests)
                    })
                } catch let err {
                    print(err)
                    
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
    }
    
    func fetchNegara(_ completionHandler: @escaping ([App]) -> ()) {
        if let search : String = isiData, let negara : String = varFilter.negara{
            let urlString = "http://titipanku.xyz/api/SearchPreorder.php?filter=negara&negara=\(String(describing: negara))&kategori=none&search=\(String(describing: search))"
            print(urlString)
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.requests = try decoder.decode([App].self, from: data)
                    print(self.requests)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.requests)
                    })
                } catch let err {
                    print(err)
                    
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
    }
    
    func fetchSemua(_ completionHandler: @escaping ([App]) -> ()) {
        if let search : String = isiData, let kategori : String = varFilter.kategori, let negara : String = varFilter.negara{
            let urlString = "http://titipanku.xyz/api/SearchPreorder.php?filter=semua&negara=\(String(describing: negara))&kategori=\(String(describing: kategori))&search=\(String(describing: search))"
            print(urlString)
            URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
                
                guard let data = data else { return }
                
                if let error = error {
                    print(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.requests = try decoder.decode([App].self, from: data)
                    print(self.requests)
                    DispatchQueue.main.async(execute: { () -> Void in
                        completionHandler(self.requests)
                    })
                } catch let err {
                    print(err)
                    
                    SKActivityIndicator.dismiss()
                }
                
            }) .resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKActivityIndicator.show("Loading...", userInteractionStatus: false)
        self.fetchRequests{(requests) -> ()in
            self.requests = requests
            print("count request" + String(self.requests.count))
            self.collectionView?.reloadData()
            SKActivityIndicator.dismiss()
        }
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Request"
        collectionView?.register(RequestCell.self, forCellWithReuseIdentifier: RequestCellId)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPreorder), name: NSNotification.Name(rawValue: "reloadPreorder"), object: nil)
        setupView()
    }
    
    private func setupView(){
        view.backgroundColor = .white
        let screenWidth = UIScreen.main.bounds.width
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        
        //collectionView?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: screenWidth/4).isActive = true
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: 600).isActive = true
        
        let backButton : UIButton = {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            button.setImage(UIImage(named: "plus"), for: .normal)
            //button.setTitle("Cancel", for: .normal)
            button.setTitleColor(button.tintColor, for: .normal) // You can change the TitleColor
            button.addTarget(self, action: #selector(handleFilter), for: UIControlEvents.touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        //backButton
        view.addSubview(backButton)
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.centerXAnchor.constraint(equalTo: collectionView!.centerXAnchor, constant: 0).isActive = true
        backButton.topAnchor.constraint(equalTo: (collectionView?.bottomAnchor)!, constant: 0).isActive = true
        
    }
    
    @objc func handleFilter(){
        let viewControllerB = SearchFilter()
        
        viewControllerB.modalPresentationStyle = .overFullScreen
        
        present(viewControllerB, animated: true, completion: nil)
    }
    
    @objc func reloadPreorder(){
        if varFilter.search == "none"{
            
        }else if varFilter.search == "kategori"{
            SKActivityIndicator.show("Loading...")
            print("reload Kategori")
            self.fetchKategori{(requests) -> ()in
                self.requests = requests
                print("count request" + String(self.requests.count))
                self.collectionView?.reloadData()
                SKActivityIndicator.dismiss()
            }
        }else if varFilter.search == "negara"{
            SKActivityIndicator.show("Loading...")
            print("reload Kategori")
            self.fetchNegara{(requests) -> ()in
                self.requests = requests
                print("count request" + String(self.requests.count))
                self.collectionView?.reloadData()
                SKActivityIndicator.dismiss()
            }
        }else if varFilter.search == "semua"{
            SKActivityIndicator.show("Loading...")
            print("reload Kategori")
            self.fetchSemua{(requests) -> ()in
                self.requests = requests
                print("count request" + String(self.requests.count))
                self.collectionView?.reloadData()
                SKActivityIndicator.dismiss()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return requests.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestCellId, for: indexPath) as! RequestCell
        cell.app = requests[indexPath.row]
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(hex: "#d1d8e0").cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2-7, height: 265)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("asd")
        if let app : App = requests[indexPath.item] {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            let addDetail = PreorderDetail(collectionViewLayout: layout)
            addDetail.app = app
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            present(addDetail, animated: false, completion: nil)
        }else{
            print("no app")
        }
        
    }
}

