//
//  CountriesListViewController.swift
//  EmijiChat
//
//  Created by Bender on 25.07.17.
//  Copyright © 2017 Impersonator. All rights reserved.
//

import UIKit

class CountriesListViewController: UIViewController {

    var delegate: CountryReceiveData?
    fileprivate var countries: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countries = CountryUtils.shared.getAllCountries()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension CountriesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryChooseCell", for: indexPath)
        
        cell.textLabel?.text = countries[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.pass(countryName: countries[indexPath.row].name, countryPhoneCode: countries[indexPath.row].code)
        dismiss(animated: true, completion: nil)
    }
}
