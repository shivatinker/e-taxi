//
//  DGeocodeRecognizer.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import GoogleMaps
import PromiseKit

class DGeocodeRecognizer {
    
    let geocoder: GMSGeocoder
    
    public init() {
        self.geocoder = GMSGeocoder()
    }
    
    public func decodeLocation(_ location: CLLocationCoordinate2D) -> Promise<DLocation> {
        return Promise { seal in
            self.geocoder.reverseGeocodeCoordinate(location) { (response, er) in
                
                guard let response = response else {
                    print("Geocode error: ", er.debugDescription)
                    seal.fulfill(DLocation(geocode: "Unknown", location2d: location))
                    return
                }
                
                guard let address = response.firstResult()?.lines?.first else {
                    print("No address")
                    seal.fulfill(DLocation(geocode: "No address", location2d: location))
                    return
                }
                
                seal.fulfill(DLocation(geocode: address, location2d: location))
            }
        }
    }
}
