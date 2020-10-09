//
//  CityNetJSONStack.swift
//  MyCities
//
//  Created by Maciej Czech on 06/10/2020.
//

import Foundation

class CityNetJSONStack {
    // MARK: - Constants
    //
    let defaultSession = URLSession(configuration: .default)
    
    //
    // MARK: - Variables And Properties
    //
    var dataTask: URLSessionDataTask?
    var dataTask1: URLSessionDataTask?
    var dataTask2: URLSessionDataTask?
    var errorMessage: String?
    var detailErrorMessage: String = ""
    var cities: [CityData] = []
    var imageBaseUrl: String?
    var cityDetail1: CityDetail1Data?
    var cityDetail2: CityDetail2Data?

    //
    // MARK: - Type Alias
    //
    typealias JSONDictionary = [String: Any]
    typealias CityListResult = ([CityData]?, String?, String?) -> Void
    typealias CityDetailResult = (CityDetail1Data?, CityDetail2Data?, String) -> Void

    // MARK:- External
    
    /// Downloads JSON basic data from server related to all cities
    /// - Parameter completion: block called when finished
    /// returns block with:
    /// cityArray[] - a returned array of cities
    /// imageBaseUrl (String) - base urla to download images
    /// errorMessage (String) - error message in case of an error
    /// NOTE:  when errorMessage is nil then the cityArray and imageBaseUrl are set.
    func getCitiesData(completion: @escaping CityListResult) {
        
        dataTask?.cancel()
      
        guard let url = URL(string: CityAddress.CityList) else {
            return
        }
      
        dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
          defer {
            self?.dataTask = nil
          }
          
            //
            if let error = error {
                self?.errorMessage = "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
            {
            
                self?.updateCitiesArray(data)
            
                //
                DispatchQueue.main.async {
                    completion(self?.cities, self?.imageBaseUrl, self?.errorMessage)
                }
            }
        }
        
        //
        dataTask?.resume()

    }

    // performs 2 concurent network requests in parallel, however they are synced up at the end using DispatchGroup
    
    
    /// Download detail info for all cities using 2 concurent async network requests that are synced together at the end.
    /// - Parameter completion: block to call when both requests are finished. It provides request results to callee object.
    ///
    /// NOTE: there is a simplification done here. It is supposed to download detail data for all cities, while it contains only for one. For the sake of the task, the same detailed data are displayed for each city.
    func getCityDetails(completion: @escaping CityDetailResult) {
        
        // create a group of asynchronic tasks we want to sync at the end
        let group = DispatchGroup()
        
        // create
        guard let url1 = URL(string: CityAddress.CityDetail1) else {
            return
        }
        guard let url2 = URL(string: CityAddress.CityDetail2) else {
            return
        }

        let task1 = defaultSession.dataTask(with: url1) { (data, response, error) in
            
            if let error = error {
                self.detailErrorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
            {
                self.updateCityDetails1(data)
            }
            // leaving a group - so allowing sync
            group.leave()
        }
        
        let task2 = defaultSession.dataTask(with: url2) { (data, response, error) in
            
            if let error = error {
                self.detailErrorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
            {
                self.updateCityDetails2(data)
            }
            // leaving a group - so allowing sync
            group.leave()
        }

        // entering a group with task 1
        group.enter()
        task1.resume()
        
        // entering a group with task 2
        group.enter()
        task2.resume()
        
        // attach a block to be executed when all tasks are done (in the main thread)
        group.notify(queue: .main) {
            // all tasks are finished
            completion(self.cityDetail1, self.cityDetail2, self.detailErrorMessage)
        }
      
    }

    //
    // MARK: - Private Methods
    //
    
    
    /// Parses detailed data received from server. Here: rating data
    /// - Parameter data: raw JSON data received from server
    /// NOTE: for the sake of simplicty there is only basic validation of received data
    private func updateCityDetails2(_ data: Data) {
        var response: JSONDictionary?
      
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            detailErrorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
      
        guard let array = response!["ratingList"] as? [Any] else {
            detailErrorMessage += "Dictionary2 does not contain results key\n"
            return
        }

        for ratingDictionary in array {
            if let ratingDictionary = ratingDictionary as? JSONDictionary,
               let cityId = ratingDictionary["cityId"] as? Int,
               let rating = ratingDictionary["rating"] as? Int
            {
                cityDetail2 = CityDetail2Data(cityId: cityId, rating: rating)
                
                // for sake of simplicity we take only the first item
                break
            } else {
                detailErrorMessage += "Problem parsing details2 dictionary\n"
            }
        }
    }

    /// Parses detailed data received from server. Here: visitors data
    /// - Parameter data: raw JSON data received from server
    /// NOTE: for the sake of simplicty there is only basic validation of received data
    private func updateCityDetails1(_ data: Data) {
        var response: JSONDictionary?
      
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            detailErrorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
      
        guard let array = response!["visitorList"] as? [Any] else {
            detailErrorMessage += "Dictionary1 does not contain results key\n"
            return
        }

        for visitorDictionary in array {
            if let visitorDictionary = visitorDictionary as? JSONDictionary,
               let cityId = visitorDictionary["cityId"] as? Int,
               let visitorArray = visitorDictionary["visitors"] as? Array<String>
            {
                cityDetail1 = CityDetail1Data(cityId: cityId, cityVisitors: visitorArray)
                
                // for sake of simplicity we take only the first item
                break
            } else {
                detailErrorMessage += "Problem parsing details1 dictionary\n"
            }
        }
    }
    
    /// Parses detailed data received from server. Here: basic data of all cities.
    /// - Parameter data: raw JSON data received from server
    /// NOTE: for the sake of simplicty there is only basic validation of received data
    private func updateCitiesArray(_ data: Data) {
        var response: JSONDictionary?
        cities.removeAll()
      
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage = "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
      
        guard let array = response!["cities"] as? [Any] else {
            errorMessage = "Dictionary does not contain results key\n"
            return
        }
      
        var index = 0
      
        for cityDictionary in array {
            if let cityDictionary = cityDictionary as? JSONDictionary,
               let cityId = cityDictionary["id"] as? Int,
               let cityName = cityDictionary["capital"] as? String,
               let country = cityDictionary["name"] as? String
            {
                cities.append(CityData(cityId: cityId, cityName: cityName, country: country))
                index += 1
            } else {
                errorMessage = "Problem parsing cityDictionary\n"
            }
        }
        
        guard let imageBaseUrl = response!["image_base_url"] as? String else {
            errorMessage = "Dictionary does not contain image_base_url key\n"
            return
        }
        self.imageBaseUrl = imageBaseUrl
    }

}
