//
//  PlacesTableViewCellViewModel.swift
//  Independent
//
//  Created by Idan Levi on 17/11/2021.
//

import Foundation
import MapKit

class PlacesTableViewCellViewModel {
    
    private var matchingItem: MKMapItem
    
    init(matchingItem: MKMapItem){
        self.matchingItem = matchingItem
    }
    
    var place: String {
        return matchingItem.placemark.name ?? ""
    }
    
    var address: String {
        return matchingItem.placemark.title ?? ""
    }
    
    var city: String {
        return matchingItem.placemark.postalAddress?.city ?? ""
    }
}
