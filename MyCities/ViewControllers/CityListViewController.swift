//
//  CityListViewController.swift
//  MyCities
//
//  Created by Maciej Czech on 05/10/2020.
//

import UIKit

/// Main screen of the app - list of cities
class CityListViewController: UITableViewController {

    let netJSONStack = CityNetJSONStack()
    var netDownloadStack: CityNetDownloadStack?
    let utils = CityUtils()

    var imageBaseUrl: String?
    var cityIndexes: Dictionary<Int, IndexPath > = [:]

    // model
    var cityListArray: [CityData] = []
    var filteredListArray: [CityData] = []

    //
    var isFilterEnabled:Bool = false {
        didSet {
            if self.isFilterEnabled {
                self.prepareFilteredData()
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
        
        // load data from server
        setupData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFilterEnabled {
            return self.filteredListArray.count
        } else {
            return self.cityListArray.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCellID", for: indexPath) as! CityCell

        var cityData:CityData?
        
        if self.isFilterEnabled {
            cityData = filteredListArray[indexPath.row]
        } else {
            cityData = cityListArray[indexPath.row]
        }
        
        // Configure the cell...
        cell.configureCell(image: (cityData!.cityPicture() ?? UIImage(named: "city_icon"))!,
                           cityName: cityData!.cityName,
                           favourite: cityData!.isFavourite())

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectedCity:CityData!
        
        if self.isFilterEnabled {
            selectedCity = self.filteredListArray[indexPath.row]
        } else {
            selectedCity = self.cityListArray[indexPath.row]
        }
        let detailViewController = CityDetailsViewController(selectedCity: selectedCity, delegate: self)
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }


    // MARK:- Private
    
    private func prepareFilteredData() {
        
        
            // prepare filtered array
            self.filteredListArray.removeAll()
            self.filteredListArray.append(contentsOf: self.cityListArray.filter { (cityData) -> Bool in
                return cityData.isFavourite()
            })
            self.catalogIndexesForRefresh()
        
    }
    
    private func catalogIndexesForRefresh() {
        
        self.cityIndexes.removeAll()
        
        // catalog cities for refresh
        for (index, item) in self.cityListArray.enumerated() {
            self.cityIndexes[item.cityId] = IndexPath(row: index, section: 0)
        }
    }
    
    private func setupViewController() {
        
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("my_cities", comment: "Header of a home screen")
        
        // setup table view
        tableView.register(CityCell.self, forCellReuseIdentifier: "cityCellID")
        tableView.tableHeaderView = CityFavouriteFilterView(frame: CGRect(x: 0, y: 0, width: 0, height: 60), items: ["All","Favourite"], delegate: self)

    }
    
    private func setupData() {
        
        // disable filtering
        if let filterView = self.tableView.tableHeaderView as? CityFavouriteFilterView {
            filterView.setFilterButtonEnabled(isEnabled: false)
        }

        // fetch data from server
        netJSONStack.getCitiesData { (returnedCities, imageBaseUrl, errorMessage) in
            
            // NOTE: completition is executed in the main thread
            if let errorMessage = errorMessage {
                
                self.utils.showMessageToUser(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("no_city_data_available", comment: "") + errorMessage, fromController: self)
                return
            }
            
            //
            if let imageBaseUrl = imageBaseUrl {
                self.imageBaseUrl = imageBaseUrl
            }
            
            // initialize download stack
            self.netDownloadStack = nil
            self.netDownloadStack = CityNetDownloadStack(imgBaseUrlString: self.imageBaseUrl!, delegate: self, bgSessionId: "pl.controlsoft.MyCities.bgSession")
            
            // cleanup previous entries
            self.cityListArray.removeAll()
            
            if let returnedCities = returnedCities {
                
                // update underlaing data set
                self.cityListArray.append(contentsOf: returnedCities)
                
                self.catalogIndexesForRefresh()
                
                // reload text data in tableview
                self.tableView.reloadData()
                
                // enable filtering
                if let filterView = self.tableView.tableHeaderView as? CityFavouriteFilterView {
                    filterView.setFilterButtonEnabled(isEnabled: true)
                }
                
                // start image download in background
                self.netDownloadStack?.downloadImagesForCities(cities: self.cityListArray)
            }
            
        }
    }
}

// MARK: - CityNetDownloadStackDelegate
//
extension CityListViewController: CityNetDownloadStackDelegate {
    
    func cityImageDidDownloadFor(cityId: Int) {
        
        let indexPathToReload = self.cityIndexes[cityId]!
        
        // conditional refresh - in order to avoid refreshing table view cells that are not visible or the whole table view is not visible
        if self.tableView.indexPathsForVisibleRows!.contains(indexPathToReload) {
            // reload relevant cell if found
            self.tableView.reloadRows(at: [indexPathToReload], with: .none)
        }
        
    }
    
}

// MARK:- CityDetailsViewDelegate

extension CityListViewController: CityDetailsViewDelegate {
    func favouriteDidChangeFor(cityId: Int) {

        if self.isFilterEnabled {
            // re-prepare filtered data
            self.prepareFilteredData()
            self.tableView.reloadData()
        } else {
            let indexPathToReload = self.cityIndexes[cityId]!
            self.tableView.reloadRows(at: [indexPathToReload], with: .none)
        }
        
    }

}

// MARK:- CityFavouriteFilterViewDelegate
extension CityListViewController: CityFavouriteFilterViewDelegate {
    
    func segmentButtonDidChangeValue(view: CityFavouriteFilterView) {
        self.isFilterEnabled = (view.segmentedButton.selectedSegmentIndex == 1)
    }
    
}
