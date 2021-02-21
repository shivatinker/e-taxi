//
//  Utils.swift
//  ARMap
//
//  Created by Andrii Zinoviev on 20.01.2021.
//

import Foundation
import SceneKit
import CoreLocation

public extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public func MDegreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
public func MRadiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

public extension SCNVector3 {
    static func +(vec1: SCNVector3, vec2: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(vec1.x + vec2.x,
                              vec1.y + vec2.y,
                              vec1.z + vec2.z)
    }
    
    static func *(val: Float, vec: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(val * vec.x,
                              val * vec.y,
                              val * vec.z)
    }
}

public extension CLLocationCoordinate2D {
    func degreesBearingToPoint(point: CLLocationCoordinate2D) -> Double {
        
        let lat1 = MDegreesToRadians(degrees: self.latitude)
        let lon1 = MDegreesToRadians(degrees: self.longitude)
        
        let lat2 = MDegreesToRadians(degrees: point.latitude)
        let lon2 = MDegreesToRadians(degrees: point.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return MRadiansToDegrees(radians: radiansBearing)
    }
}

public extension NSLayoutConstraint {
    static func activateConstraints(for innerView: UIView, in outerView: UIView) {
        innerView.translatesAutoresizingMaskIntoConstraints = false
        activate([
            innerView.topAnchor.constraint(equalTo: outerView.safeAreaLayoutGuide.topAnchor),
            innerView.bottomAnchor.constraint(equalTo: outerView.safeAreaLayoutGuide.bottomAnchor),
            innerView.leftAnchor.constraint(equalTo: outerView.safeAreaLayoutGuide.leftAnchor),
            innerView.rightAnchor.constraint(equalTo: outerView.safeAreaLayoutGuide.rightAnchor),
        ])
    }
}

public extension UIViewController {
    func addChildVCAndView(_ child: UIViewController) {
        self.view.addSubview(child.view)
        addChild(child)
        child.didMove(toParent: self)
    }
}

public extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2 , width: size.width, height: size.height)
    }
}
