//
//  CityData.swift
//  MyCities
//
//  Created by Maciej Czech on 06/10/2020.
//

import UIKit

class CityData {

    let cityId: Int
    let cityName: String
    let country: String

    //
    // MARK: - Initialization
    //
    init(cityId:Int, cityName:String, country:String) {
        self.cityId = cityId
        self.cityName = cityName
        self.country = country
    }
    
    func cityPicture() -> UIImage? {
    
        let cityImage = UIImage(contentsOfFile: self.imageFileLocalURL().path)
        
        return cityImage
    }
    
    func imageFileName() -> String {
        return "city_pic" + String(cityId) + ".jpg"
    }
    
    func imageFileLocalURL() -> URL {
        return CityData.imageFilesLocalLocationURL().appendingPathComponent(self.imageFileName())
    }
    
    func imageRemoteURL(baseImageRemotePath:String) -> URL? {
        return URL(string: baseImageRemotePath + "/" + self.imageFileName())
    }
    
    func isFavourite() -> Bool {
        return CityUtils.isFavouriteCity(cityId: self.cityId)
    }
    
    func makeFavourite() {
        CityUtils.addFavouriteCity(cityId: self.cityId)
    }
    
    func cancelFavourite() {
        CityUtils.removeFavouriteCity(cityId: self.cityId)
    }

    // MARK:- Static methods
    
    static func imageFilePath(for url: URL) -> URL {
        return CityData.imageFilesLocalLocationURL().appendingPathComponent(url.lastPathComponent)
    }
    
    static func imageFilesLocalLocationURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
