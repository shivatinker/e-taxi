//
//  DDataModel.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import CoreGraphics
import CoreLocation
import UIKit
import PromiseKit
import GoogleMapsDirections

enum MyError: Error {
    case runtimeError(String)
}

protocol DDataModel {
    func requestTrip(_ request: DTripRequest) -> Promise<DTrip>
    func requestTripUpdate(_ request: DTripUpdateRequest, callback: @escaping ((DTripUpdate) -> Void))
    func requestPath(_ src: CLLocationCoordinate2D, _ dst: CLLocationCoordinate2D, travelMode: GoogleMapsDirections.TravelMode, callback: @escaping ([CLLocationCoordinate2D]?) -> Void)
}

struct DDriver {
    let id: Int
    let name: String
    let vehicle: DVehicle
    let avatar: CGImage?
    let info: String
    let infoImage: CGImage
}

struct DVehicle {
    let id: Int
    let name: String
    let governmentId: String
    let color: CGColor
    let image: CGImage?
}

struct DTripRequest {
    let source: DLocation
}

struct DTripUpdateRequest {
    let trip: DTrip
    let clientLocation2d: CLLocationCoordinate2D
}

struct DTripUpdate {
    let trip: DTrip
    let state: DTripState
    let driverLocation2d: CLLocationCoordinate2D
    let driverBearing: Double
    let path: [CLLocationCoordinate2D]?
}

enum DTripState {
    case waitingForDriver
    case waitingForClient
    case inProgress
    case finished
}

struct DTrip {
    let id: Int
    let driver: DDriver
    let source: DLocation
}

struct DLocation {
    let geocode: String
    let location2d: CLLocationCoordinate2D
}

struct DFavouriteLocation {
    let geocode: String
    let location2d: CLLocationCoordinate2D
    let image: UIImage?
}

class DMockDataModel: DDataModel {
    
    private let drivers: [DDriver] = [
        DDriver(id: 1,
                name: "Dmitriy",
                vehicle: DVehicle(id: 1,
                                  name: "BMW X5",
                                  governmentId: "BH 3123 AK",
                                  color: UIColor.red.cgColor,
                                  image: UIImage.init(named: "jeep")?.cgImage),
                avatar: UIImage.init(named: "business")?.cgImage,
                info: """
    -Год выпуска: 2018
    -Цвет: мокрый асфальт
    -Тип: легковой
    -Сервисный центр: ВРЕР-1 УДАІ В Г. Одесса
    -Топливо: Бензин
    -Адрес регистрации: Г.Одесса, район Приморский

    Дополнительная информация от водителя:
    О багаже предупреждайте заранее, пожалуйста.


    """,
                infoImage: UIImage.init(named: "overall")!.cgImage!),
        
        DDriver(id: 2,
                name: "Andrii",
                vehicle: DVehicle(id: 1,
                                  name: "Cool car",
                                  governmentId: "BH 7777 BC",
                                  color: UIColor.red.cgColor,
                                  image: UIImage.init(named: "car1_image")?.cgImage),
                avatar: UIImage.init(named: "andrii")?.cgImage,
                info: """
    Катаю в городе, люблю iOS
    """,
                infoImage: UIImage.init(named: "overall")!.cgImage!),
        
    ]
    
    func requestTrip(_ request: DTripRequest) -> Promise<DTrip> {
        return Promise { seal in
            cnt = 0
            seal.fulfill(DTrip(id: 0,
                               driver: drivers.randomElement()!,
                               source: request.source))
        }
    }
    
    private var cnt = 0;
    private var driverStartLoc: CLLocationCoordinate2D!
    private var driverEndLoc: CLLocationCoordinate2D!
    private var currentPath: [CLLocationCoordinate2D]?
    private var lastDriverLocation: CLLocationCoordinate2D?
    
    private func randomLocationNear(_ loc: CLLocationCoordinate2D, radius: Double) -> CLLocationCoordinate2D {
        let rand1 = Double(Double(arc4random()) / Double(UINT32_MAX)) * radius
        let rand2 = Double(Double(arc4random()) / Double(UINT32_MAX)) * radius
        return CLLocationCoordinate2D(latitude: loc.latitude + rand1,
                                      longitude: loc.longitude + rand2)
    }
    
    func requestTripUpdate(_ request: DTripUpdateRequest, callback: @escaping ((DTripUpdate) -> Void)) {
        if (cnt > 0 && cnt >= self.currentPath!.count) {
            callback(DTripUpdate(trip: request.trip,
                                 state: .waitingForClient,
                                 driverLocation2d: driverEndLoc,
                                 driverBearing: self.lastDriverLocation?.degreesBearingToPoint(point: driverEndLoc) ?? 0,
                                 path: self.currentPath))
            self.lastDriverLocation = nil
            return
        }
        
        if (cnt == 0) {
            driverEndLoc = randomLocationNear(request.trip.source.location2d, radius: 0.003)
            driverStartLoc = randomLocationNear(request.clientLocation2d, radius: 0.04)
            requestPath(driverStartLoc, driverEndLoc, travelMode: .driving) {path in
                if let path = path {
                    self.currentPath = path
                    callback(DTripUpdate(trip: request.trip,
                                         state: .waitingForDriver,
                                         driverLocation2d: path[self.cnt],
                                         driverBearing: self.lastDriverLocation?.degreesBearingToPoint(point: path[self.cnt]) ?? 0,
                                         path: path))
                    self.lastDriverLocation = path[self.cnt]
                }
                self.cnt+=1
            }
        }
        else {
            if let path = self.currentPath {
                callback(DTripUpdate(trip: request.trip,
                                     state: .waitingForDriver,
                                     driverLocation2d: path[self.cnt],
                                     driverBearing: self.lastDriverLocation?.degreesBearingToPoint(point: path[self.cnt]) ?? 0,
                                     path: path))
                self.lastDriverLocation = path[self.cnt]
            }
            self.cnt+=1
        }
    }
    
    
    
    func requestPath(_ src: CLLocationCoordinate2D, _ dst: CLLocationCoordinate2D, travelMode: GoogleMapsDirections.TravelMode, callback: @escaping ([CLLocationCoordinate2D]?) -> Void) {
        GoogleMapsDirections.direction(fromOriginCoordinate: GoogleMapsDirections.LocationCoordinate2D(latitude: src.latitude, longitude: src.longitude),
                                       toDestinationCoordinate: GoogleMapsDirections.LocationCoordinate2D(latitude: dst.latitude, longitude: dst.longitude),
                                       travelMode: travelMode,
                                       wayPoints: nil,
                                       alternatives: nil,
                                       avoid: nil,
                                       language: nil,
                                       units: nil,
                                       region: nil,
                                       arrivalTime: nil,
                                       departureTime: nil,
                                       trafficModel: nil,
                                       transitMode: nil,
                                       transitRoutingPreference: nil) { (resp, e) in
            guard let resp = resp else {
                print("Shit")
                return
            }
            
            if (resp.status != .ok) {
                print("Shit status")
                return
            }
            
            guard let steps = resp.routes.first?.legs.first?.steps else {
                print("Shit steps")
                return
            }
            
            var polyline = [src]
            
            polyline.append(contentsOf: steps.compactMap({$0.endLocation}).map({CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}))
            
            debugPrint(polyline)
            callback(polyline)
            
        }
    }
}
