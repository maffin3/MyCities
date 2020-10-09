//
//  AppDelegate.swift
//  MyCities
//
//  Created by Maciej Czech on 05/10/2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow()
        let vc = CityListViewController()
        let nc = UINavigationController(rootViewController: vc)
        
        // setup appearance of various screen elements
        CityUtils.setupAppearance()
        
        self.window!.rootViewController = nc
        self.window!.makeKeyAndVisible()
        
        return true
    }



}

