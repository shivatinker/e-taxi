//
//  DContext.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import CoreLocation

class DContext {
    public let configuration: DConfiguration = DConfiguration.shared
    public let dataModel: DDataModel = DMockDataModel()
    public let geocodeRecognizer: DGeocodeRecognizer = DGeocodeRecognizer()
    public var favourites: [DFavouriteLocation] = [DFavouriteLocation(geocode: "Home",
                                                                      location2d: CLLocationCoordinate2D(latitude: 46.4862,
                                                                                                         longitude: 30.7131),
                                                                      image: nil)]
}
