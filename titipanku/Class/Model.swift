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
    let barang: [App]?
    let type: String?
    
    static func fetchFeaturedApps(_ completionHandler: @escaping (FeaturedApps) -> ()) {
        
        let urlString = "http://45.76.178.35/titipanku/NewestList.php"
        
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
    
    let id: String?
    var name: String?
    var category: String?
    var country: String?
    var price: Int?
    var ImageName: String?
    
    var Screenshots: [String]?
    var description: String?
    var appInformation: [AppInformation]?
}

struct AppInformation: Decodable {
    let Name: String
    let Value: String
}
