//
//  CityVisitorListViewController.swift
//  MyCities
//
//  Created by Maciej Czech on 07/10/2020.
//

import UIKit

/// View controller presenting list of visitors.
class CityVisitorListViewController: UITableViewController {

    var visitors: Array<String>?
    var selectedCity:CityData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visitors?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = visitors?[indexPath.row]
        
        return cell
    }

    // MARK:- Private
    
    private func setupViewController() {
        if #available(iOS 13.0, *) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeViewControllerAction(sender:)))
        } else {
            // Fallback on earlier versions
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeViewControllerAction(sender:)))
        }

        self.navigationItem.title = NSLocalizedString("visitors_in", comment: "") + " " + (selectedCity?.cityName ?? "")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")

    }
    
    @objc private func closeViewControllerAction(sender:Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}
