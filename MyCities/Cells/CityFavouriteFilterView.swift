//
//  CityFavouriteFilterView.swift
//  MyCities
//
//  Created by Maciej Czech on 06/10/2020.
//

import UIKit

/// Protocol to inform delegate about changed selection of segmented control
protocol CityFavouriteFilterViewDelegate: AnyObject {
    func segmentButtonDidChangeValue(view: CityFavouriteFilterView)
}

/// View with segmented control to be uased as filter control in table view header
class CityFavouriteFilterView: UIView {

    weak var delegate:CityFavouriteFilterViewDelegate?
    
    public private(set) var segmentedButton:UISegmentedControl!

    init(frame: CGRect, items:Array<String>, delegate:CityFavouriteFilterViewDelegate) {
        super.init(frame: frame)
        
        self.delegate = delegate
        
        segmentedButton = UISegmentedControl(items: items)
        
        segmentedButton.translatesAutoresizingMaskIntoConstraints = false
        segmentedButton.selectedSegmentIndex = 0
        
        self.addSubview(segmentedButton)
        
        //Set layout
        let viewsDict = ["segmentedButton": segmentedButton]

        segmentedButton.addTarget(self, action: #selector(self.segmentValueHasChanged), for: .valueChanged)
        segmentedButton.backgroundColor = CityColor.Green
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[segmentedButton]-(8)-|", options: .alignAllCenterX, metrics: nil, views: viewsDict as [String : Any]));
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[segmentedButton]-(8)-|", options: .alignAllCenterX, metrics: nil, views: viewsDict as [String : Any]));
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func segmentValueHasChanged(segment:UISegmentedControl) {        
        delegate?.segmentButtonDidChangeValue(view: self)
    }

    func setFilterButtonEnabled(isEnabled:Bool) {
        self.segmentedButton.isEnabled = isEnabled
    }
}
