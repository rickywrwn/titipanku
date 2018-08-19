//
//  TabController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 11/04/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit

var cekLogged : Bool = UserDefaults.standard.bool(forKey: "logged")

class TabController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    @objc func handleBack(){
        let loginCont = loginController()
        present(loginCont, animated: true, completion: {
            
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let layout = UICollectionViewFlowLayout()
        
        //let item1 = homeController(collectionViewLayout: layout)
        let item1 = UINavigationController(rootViewController: homeController(collectionViewLayout: layout));
        let icon1 = UITabBarItem(title: "Home", image: UIImage(named: "home")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "home")?.withRenderingMode(.alwaysOriginal))
        item1.tabBarItem = icon1
        
        let item4 = InboxController()
        let icon4 = UITabBarItem(title: "Inbox", image: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal))
        item4.tabBarItem = icon4
        
//        let item3 = TambahViewController()
//        let icon3 = UITabBarItem(title: "Tambah", image: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal))
//        item3.tabBarItem = icon3
        
        let item2 = UINavigationController(rootViewController: ExploreController(collectionViewLayout: layout))
        let icon2 = UITabBarItem(title: "Explore", image: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal))
        item2.tabBarItem = icon2
        
        let item5 =  UINavigationController(rootViewController: UserController(collectionViewLayout: layout))
        let icon5 = UITabBarItem(title: "User", image: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal))
        item5.tabBarItem = icon5
        
        let item6 =  UINavigationController(rootViewController: MoreController(collectionViewLayout: layout))
        let icon6 = UITabBarItem(title: "More", image: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal))
        item6.tabBarItem = icon6
        
        let controllers = [item1,item2,item4,item5,item6]  //array of the root view controllers displayed by the tab bar interface
        self.viewControllers = controllers
        
    }

    
    //Delegate methods
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title) ?")
       
        return true
    }
}
