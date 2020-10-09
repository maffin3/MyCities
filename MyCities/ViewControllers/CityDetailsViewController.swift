//
//  CityDetailsViewController.swift
//  MyCities
//
//  Created by Maciej Czech on 06/10/2020.
//

import UIKit

protocol CityDetailsViewDelegate: AnyObject {
    func favouriteDidChangeFor(cityId: Int)
}

/// Shows detailed info about the selected city
class CityDetailsViewController: UIViewController {

    var selectedCity:CityData!
    weak var delegate:CityDetailsViewDelegate?
    
    let netJSONStack = CityNetJSONStack()
    let utils = CityUtils()

    // presenting
    var isCityFavourite: Bool = false {
        
        didSet {
            // update UI
            self.updateUIFavouriteButton()
            
            // save persistantly
            CityUtils.setFavouriteCity(cityId: self.selectedCity!.cityId, isFavourite: self.isCityFavourite)
            
            // call delegate to update relevant row in table view
            self.delegate?.favouriteDidChangeFor(cityId: self.selectedCity!.cityId)
        }

    }
    
    // screen elements
    private var cityPicImageView = UIImageView()
    private var cityNameLabel = UILabel()
    private var countryLabel = UILabel()
    private var visitedByLabel = UILabel()
    private var ratingLabel = UILabel()
    private var favouriteLabel = UILabel()
    private var favouriteButton = UIButton()
    
    // fetched detailed data
    private var visitorsData:CityDetail1Data?
    private var ratingData:CityDetail2Data?

    init(selectedCity:CityData, delegate:CityDetailsViewDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.selectedCity = selectedCity
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
        
        buildScreenElements()
        
        // load additional data from server
        setupData()
        
        updateUIFavouriteButton()
    }
    
    // MARK:- Private

    private func updateUIFavouriteButton() {
        favouriteButton.setImage(self.isCityFavourite ? UIImage(named: "star_button") : UIImage(named: "star_button_gray"), for: .normal)
    }
    
    private func setupData() {
        
        self.isCityFavourite = self.selectedCity!.isFavourite()
        
        netJSONStack.getCityDetails { (detail1, detail2, errorMessage) in
            
            // NOTE: completition is executed in the main thread
            if errorMessage != "" {
                
                self.utils.showMessageToUser(title: NSLocalizedString("alert", comment: ""), message: NSLocalizedString("no_city_details_data_available", comment: "") + errorMessage, fromController: self)
                return
            }
            
            // set local data model
            if let visitorsData = detail1 {
                self.visitorsData = visitorsData
            }
            
            if let ratingData = detail2 {
                self.ratingData = ratingData
            }
            
            // refresh UI
            self.refreshCityDetailedInfo()
        }
    }
    
    private func refreshCityDetailedInfo() {
        
        visitedByLabel.text = NSLocalizedString("visited_by", comment: "") + ": " + String(visitorsData?.cityVisitors.count ?? 0)
        ratingLabel.text = NSLocalizedString("city_rating", comment: "") + ": " + String(ratingData?.rating ?? 0)
    
    }
    
    private func setupViewController() {
        
        self.view.backgroundColor = .white
        self.navigationItem.title = self.selectedCity?.cityName
    
    }

    private func buildScreenElements() {
        
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cityNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        cityNameLabel.textAlignment = .center
        cityNameLabel.text = self.selectedCity?.cityName
        
        cityPicImageView.translatesAutoresizingMaskIntoConstraints = false
        cityPicImageView.contentMode = .scaleAspectFit
        cityPicImageView.image = (self.selectedCity?.cityPicture() ?? UIImage(named: "city_icon"))
        
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        countryLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        countryLabel.textAlignment = .center
        countryLabel.text = self.selectedCity?.country

        visitedByLabel.translatesAutoresizingMaskIntoConstraints = false
        visitedByLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        visitedByLabel.textAlignment = .left
        visitedByLabel.isUserInteractionEnabled = true
        visitedByLabel.textColor = CityColor.Green

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        ratingLabel.textAlignment = .left

        favouriteLabel.translatesAutoresizingMaskIntoConstraints = false
        favouriteLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        favouriteLabel.textAlignment = .right
        favouriteLabel.text = NSLocalizedString("favourite", comment: "")

        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.addTarget(self, action: #selector(changeFavouriteAction(sender:)), for: .touchUpInside)
        
        self.view.addSubview(cityNameLabel)
        self.view.addSubview(cityPicImageView)
        self.view.addSubview(countryLabel)
        self.view.addSubview(visitedByLabel)
        self.view.addSubview(ratingLabel)
        self.view.addSubview(favouriteLabel)
        self.view.addSubview(favouriteButton)
        
        // setup layout
        let viewsDict = ["cityNameLabel": cityNameLabel, "cityPicImageView": cityPicImageView, "countryLabel":countryLabel, "visitedByLabel":visitedByLabel, "ratingLabel":ratingLabel, "favouriteLabel":favouriteLabel, "favouriteButton":favouriteButton]
        

        // layout main elements: image and city name
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[cityNameLabel]-(8)-[cityPicImageView(200)]-(8)-[countryLabel]-(12)-[visitedByLabel]-(12)-[ratingLabel]-(20)-[favouriteButton]", options: .alignAllCenterX, metrics: nil, views: viewsDict));
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[cityNameLabel]-(8)-|", options: .alignAllCenterY, metrics: nil, views: viewsDict));
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[cityPicImageView]-(8)-|", options: .alignAllCenterY, metrics: nil, views: viewsDict));
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[countryLabel]-(8)-|", options: .alignAllCenterY, metrics: nil, views: viewsDict));
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[visitedByLabel]-(8)-|", options: .alignAllCenterY, metrics: nil, views: viewsDict));
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[ratingLabel]-(8)-|", options: .alignAllCenterY, metrics: nil, views: viewsDict));
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[favouriteLabel]-(12)-[favouriteButton]", options: .alignAllCenterY, metrics: nil, views: viewsDict));

        self.view.addConstraint(NSLayoutConstraint(item: favouriteButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: favouriteButton, attribute: .centerY, relatedBy: .equal, toItem: favouriteLabel, attribute: .centerY, multiplier: 1.0, constant: 0))

        // setup tap recognizer on visitor's label
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showVisitorDetailsAction(sender:)))
        visitedByLabel.addGestureRecognizer(tapRecognizer)
        
    }

    // MARK:- Private Actions
    
    @objc private func changeFavouriteAction(sender:Any?) {
        self.isCityFavourite = !self.isCityFavourite
    }
    
    @objc private func showVisitorDetailsAction(sender:Any?) {

        // create view controler
        let visitorViewController = CityVisitorListViewController()
        visitorViewController.selectedCity = self.selectedCity
        visitorViewController.visitors = self.visitorsData?.cityVisitors
        
        // present it in navigation controller modally - full screen
        let nc = UINavigationController(rootViewController: visitorViewController)
        nc.modalPresentationStyle = .fullScreen
        
        self.present(nc, animated: true, completion: nil)
                
    }
}
