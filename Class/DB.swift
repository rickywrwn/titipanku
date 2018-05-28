//
//  DB.swift
//  titipanku
//
//  Created by Ricky Wirawan on 04/04/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import Foundation
import Alamofire

class DB: NSObject {
    
    public func doWriteToLoginLog(url : String, parameters : Parameters){
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON {
            response in
            print(response)
            /*
             if let result = response.result.value {
             //converting it as NSDictionary
             let jsonData = result as! NSDictionary
             print(jsonData)
             }*/
        }
    }
    
}
