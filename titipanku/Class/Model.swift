//
//  Model.swift
//  titipanku
//
//  Created by Ricky Wirawan on 30/04/18.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

struct FeaturedApps: Decodable {
    
    var bannerCategory: AppCategory?
    var categories: [AppCategory]?
    
}

struct AppCategory: Decodable {
    
    let name: String?
    let apps: [App]?
    let type: String?
    
    func handleMore(angka : Int) {
        
        print(angka)
    }
    
    static func fetchFeaturedApps(_ completionHandler: @escaping (FeaturedApps) -> ()) {
        
        let urlString = "http://titipanku.xyz/api/NewestList.php"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let featuredApps = try decoder.decode(FeaturedApps.self, from: data)
                //print(featuredApps)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler(featuredApps)
                })
                
            } catch let err {
                print(err)
            }
            
        }) .resume()
        
    }
}

struct App: Decodable {
    
    var id: String?
    var email : String?
    var name: String?
    var description: String?
    var category: String?
    var country: String?
    var price: String?
    var ImageName: String?
    var url: String?
    var brand: String?
    var qty: String?
    var ukuran: String?
    var berat: String?
    var kotaKirim: String?
    var idKota: String?
    var provinsi: String?
    var tglPost: String?
    var status: String?
    var deadline: String?
    var valueHarga: String?
    var nomorResi: String?
    
    var Screenshots: [String]?
    var appInformation: [AppInformation]?
}

struct AppInformation: Decodable {
    let Name: String
    let Value: String
}
