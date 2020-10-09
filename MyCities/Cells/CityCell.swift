//
//  CityCell.swift
//  MyCities
//
//  Created by Maciej Czech on 05/10/2020.
//

import UIKit

/// Table view cell for City object on a list of cities
class CityCell: UITableViewCell {

    private var cityImageView = UIImageView()
    private var cityNameLabel = UILabel()
    private var starImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator

        buildScreenElements()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK:- External
    func configureCell(image:UIImage, cityName:String, favourite:Bool) {
        cityImageView.image = image
        cityNameLabel.text = cityName
        starImageView.isHidden = !favourite
    }
    
    // MARK:- Private
    
    private func buildScreenElements() {
        
        // basic setup
        cityImageView.translatesAutoresizingMaskIntoConstraints = false
        cityImageView.contentMode = .scaleAspectFit
        
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cityNameLabel.textColor = CityColor.Blue
        cityNameLabel.font = UIFont.boldSystemFont(ofSize: 19.0)

        starImageView.image = UIImage(named: "star_icon")
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // add screen elements to contentView
        contentView.addSubview(cityImageView)
        contentView.addSubview(cityNameLabel)
        contentView.addSubview(starImageView)
        
        // setup layout
        let viewsDict = ["cityImageView": cityImageView, "cityNameLabel": cityNameLabel, "starImageView":starImageView]
        

        // layout main elements: image and city name
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[starImageView]-(8)-[cityImageView(80)]-(8)-[cityNameLabel]-(8)-|", options: .alignAllCenterY, metrics: nil, views: viewsDict));
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[cityImageView(80)]-(8@500)-|", options: .alignAllCenterX, metrics: nil, views: viewsDict));

        contentView.addConstraint(NSLayoutConstraint(item: cityImageView, attribute: .centerY, relatedBy: .equal, toItem: cityNameLabel, attribute: .centerY, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: cityImageView, attribute: .centerY, relatedBy: .equal, toItem: starImageView, attribute: .centerY, multiplier: 1.0, constant: 0))


    }
}
