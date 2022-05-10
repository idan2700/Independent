//
//  LocationViewController.swift
//  Independent
//
//  Created by Idan Levi on 08/05/2022.
//

import UIKit

protocol LocationViewControllerDelegate: AnyObject {
    func didPickLocation(location: String)
}

class LocationViewController: UIViewController {
    
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: LocationViewModel!
    weak var delegate: LocationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchBar()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapCurrentLocation(_ sender: UIButton) {
        viewModel.didTapCurrentLocation()
    }
    
    private func setSearchBar() {
        if let textfield = locationSearchBar.value(forKey: "searchField") as? UITextField {
            let atrbString = NSAttributedString(string: "יש להזין מיקום", attributes: [.foregroundColor : UIColor(named: "30white")!, .font : UIFont.systemFont(ofSize: 15)])
            textfield.attributedPlaceholder = atrbString
            textfield.textColor = UIColor(named: "50white") ?? .white
            textfield.backgroundColor = UIColor(named: "10white") ?? .white
            textfield.makeRoundCorners(radius: 5)
        }
        locationSearchBar.delegate = self
        locationSearchBar.text = viewModel.currentLocation
    }
}

extension LocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.didStartToSearchLocation(searchText: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.locationSearchBar.text = nil
    }
}

extension LocationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesCell") as? PlacesTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension LocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        if cellViewModel.place == cellViewModel.city {
            self.locationSearchBar.text = cellViewModel.city
        } else {
            self.locationSearchBar.text = "\(cellViewModel.place), \(cellViewModel.city)"
        }
        delegate?.didPickLocation(location: locationSearchBar.text ?? "")
        self.dismiss(animated: true, completion: nil)
    }
}

extension LocationViewController: LocationViewModelDelegate {
    func presentLocationPermissionMessage() {
        presentErrorAlert(with: "על מנת לאפשר לנו לאתר את מיקומך, יש לאשר שימוש בשרותי מיקום בהגדרות המכשיר" ,buttonTitle: "הגדרות") { 
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func returnWithCurrentLocation(location: String) {
        delegate?.didPickLocation(location: location)
        self.dismiss(animated: true, completion: nil)
    }
}
