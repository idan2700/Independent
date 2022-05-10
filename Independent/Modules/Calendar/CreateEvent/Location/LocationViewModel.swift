//
//  LocationViewModel.swift
//  Independent
//
//  Created by Idan Levi on 08/05/2022.
//

import Foundation
import MapKit
import CoreLocation

protocol LocationViewModelDelegate: AnyObject {
    func reloadData()
    func returnWithCurrentLocation(location: String)
    func presentLocationPermissionMessage()
}

class LocationViewModel: NSObject {
    
    private var matchingItems: [MKMapItem] = []
    private let locationManager = CLLocationManager()
    var currentLocation: String
    weak var delegate: LocationViewModelDelegate?
    
    init(delegate: LocationViewModelDelegate?, currentLocation: String) {
        self.delegate = delegate
        self.currentLocation = currentLocation
    }
   
    var numberOfRows: Int {
        return matchingItems.count
    }
    
    func getCellViewModel(at indexPath: IndexPath)-> PlacesTableViewCellViewModel {
        return PlacesTableViewCellViewModel(matchingItem: matchingItems[indexPath.row])
    }
    
    func didStartToSearchLocation(searchText: String) {
        let initialLocation = CLLocation(latitude: 31.771959, longitude: 35.217018)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let region = MKCoordinateRegion(center: initialLocation.coordinate, span: MKCoordinateSpan())
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let self = self else {return}
            guard let response = response else {return}
            DispatchQueue.main.async {
                self.matchingItems = response.mapItems
                self.delegate?.reloadData()
            }
        }
    }
    
    func didTapCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                   case .notDetermined, .restricted, .denied:
                delegate?.presentLocationPermissionMessage()
                   case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                   @unknown default:
                       break
               }
        } else {
            delegate?.presentLocationPermissionMessage()
        }
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        locationManager.stopUpdatingLocation()
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemark, error in
            guard let placemark = placemark?.first else {return}
            let currentLocation = "\(placemark.postalAddress?.street ?? ""), \(placemark.postalAddress?.city ?? "")"
            self.delegate?.returnWithCurrentLocation(location: currentLocation)
        }
    }
}
