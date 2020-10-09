//
//  CityDetail1Data.swift
//  MyCities
//
//  Created by Maciej Czech on 07/10/2020.
//

import UIKit

class CityDetail1Data {
    let cityId: Int
    let cityVisitors: Array<String>

    //
    // MARK: - Initialization
    //
    init(cityId:Int, cityVisitors:Array<String>) {
        self.cityId = cityId
        self.cityVisitors = cityVisitors
    }

}
