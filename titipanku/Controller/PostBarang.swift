//
//  PostBarang.swift
//  titipanku
//
//  Created by Ricky Wirawan on 29/05/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit

class PostBarang: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    
    fileprivate let inputCellId1 = "inputCellId1"
    fileprivate let inputCellId2 = "inputCellId2"
    fileprivate let inputCellId3 = "inputCellId3"
    fileprivate let inputCellId4 = "inputCellId4"
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("Post Barang")
        setupView()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(InputCell1.self, forCellWithReuseIdentifier: inputCellId1)
        collectionView?.register(InputCell2.self, forCellWithReuseIdentifier: inputCellId2)
        collectionView?.register(InputCell3.self, forCellWithReuseIdentifier: inputCellId3)
        collectionView?.register(InputCell4.self, forCellWithReuseIdentifier: inputCellId4)
        
        
    }
   
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1, for: indexPath) as! InputCell1
            return cell
            
        }else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId2, for: indexPath) as! InputCell2
            return cell
            
        }else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId3, for: indexPath) as! InputCell3
            return cell
            
        }else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId4, for: indexPath) as! InputCell4
            return cell
            
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCellId1, for: indexPath) as! InputCell1
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.gray.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cell?.layer.backgroundColor = UIColor.white.cgColor
        }
        if indexPath.row == 0{
            showAddDetail()
        }else if indexPath.row == 1{
            showAddKarateristik()
        }else if indexPath.row == 2{
            AddNegaraBarang()
        }else if indexPath.row == 3{
            AddHargaBarang()
        }
    }
    
    
    private func setupView(){
        view.backgroundColor = .white
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        collectionView?.heightAnchor.constraint(equalToConstant: 500).isActive = true
        collectionView?.widthAnchor.constraint(equalToConstant: 400).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
        true
    }
    
    @objc func showAddDetail(){
        let addDetail = AddDetailBarang()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)

    }
    
    @objc func showAddKarateristik(){
        let addDetail = AddKarateristikBarang()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showNegaraBarang(){
        let addDetail = AddNegaraBarang()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
    
    @objc func showHargaBarang(){
        let addDetail = AddHargaBarang()
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(addDetail, animated: false, completion: nil)
        
    }
}


class InputCell1: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Detail Barang  "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        
        addConstraintsWithFormat("H:|-50-[v0]-5-|", views: labelA) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        
    }
    
}

class InputCell2: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Karateristik Barang  "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        
        addConstraintsWithFormat("H:|-50-[v0]-5-|", views: labelA) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        
    }
    
}

class InputCell3: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Negara Pembelian"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        
        addConstraintsWithFormat("H:|-50-[v0]-5-|", views: labelA) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        
    }
    
}

class InputCell4: BaseCell {
    
    let labelA : UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "Harga "
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(labelA)
        
        addConstraintsWithFormat("H:|-50-[v0]-5-|", views: labelA) //pipline terakhir dihilangkan
        
        addConstraintsWithFormat("V:|[v0]|", views: labelA)
        
    }
    
}
