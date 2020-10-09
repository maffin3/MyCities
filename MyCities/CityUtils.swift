//
//  CityUtils.swift
//  MyCities
//
//  Created by Maciej Czech on 06/10/2020.
//

import UIKit

class CityUtils {
    
    func showMessageToUser(title:String, message:String, fromController:UIViewController) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        fromController.present(alertController, animated: true, completion: nil)
    
    }

    static func setFavouriteCity(cityId:Int, isFavourite:Bool) {
        let defaults = UserDefaults.standard
        defaults.set(isFavourite, forKey: String(cityId))
    }

    static func addFavouriteCity(cityId:Int) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: String(cityId))
    }

    static func removeFavouriteCity(cityId:Int) {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: String(cityId))
    }
    
    static func isFavouriteCity(cityId:Int) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: String(cityId))
    }

    static func setupAppearance() {
        UINavigationBar.appearance().isTranslucent = false
    }
}
