//
//  DMapViewController.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import GoogleMaps
import UIKit

protocol DTouchGestureRecognizerDelegate : AnyObject {
    func touchGestureRecognizerTouchesBegan(_ gr: DTouchGestureRecognizer)
    func touchGestureRecognizerTouchesEnded(_ gr: DTouchGestureRecognizer)
}

class DTouchGestureRecognizer: UIGestureRecognizer {
    public weak var touchDelegate: DTouchGestureRecognizerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchGestureRecognizerTouchesBegan(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchGestureRecognizerTouchesEnded(self)
    }
}

class DMapViewMode: DTouchGestureRecognizerDelegate {
    internal weak var mapVC: DMapViewController!
    
    func touchGestureRecognizerTouchesBegan(_ gr: DTouchGestureRecognizer) {
        
    }
    
    func touchGestureRecognizerTouchesEnded(_ gr: DTouchGestureRecognizer) {
        
    }
    
    func cameraChanged() {
        
    }
    
    func wasActivated() {
        
    }
    
    func wasDeactivated() {
        
    }
}

class DMapViewModeNormal: DMapViewMode {
    
}

protocol DMapViewModeChooseLocationDelegate: AnyObject {
    func mapViewModeDidChooseLocation(_ location: CLLocationCoordinate2D)
}

class DMapViewModeChooseLocation: DMapViewMode {
    public weak var delegate: DMapViewModeChooseLocationDelegate?
    
    private let markerView = DMarkerView()
    
    override init() {
        super.init()
        
        markerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func wasActivated() {
        mapVC.view.addSubview(markerView)
        NSLayoutConstraint.activate([
            markerView.centerXAnchor.constraint(equalTo: mapVC.mapView.centerXAnchor),
            markerView.centerYAnchor.constraint(equalTo: mapVC.mapView.centerYAnchor, constant: -13),
        ])
        selectCameraTarget()
    }
    
    override func wasDeactivated() {
        markerView.removeFromSuperview()
    }
    
    override func touchGestureRecognizerTouchesBegan(_ gr: DTouchGestureRecognizer) {
        markerView.state = .detached
    }
    
    override func touchGestureRecognizerTouchesEnded(_ gr: DTouchGestureRecognizer) {
        selectCameraTarget()
        //        marker.position = location
        //        mapVC.marker.icon = UIImage.init(named: "marker_pinned")
        //        mapVC.marker.map = self.mapView
    }
    
    private func selectCameraTarget() {
        markerView.state = .pinned
        let location = mapVC.mapView.camera.target
        delegate?.mapViewModeDidChooseLocation(location)
    }
}

class DMapViewModeTripTracking: DMapViewMode {
    private let markerView = DMarkerView()
    private let carView = UIImageView(image: UIImage.init(named: "car_icon"))
    
    public var disableAnimations: Bool = false
    
    public var clientLocation: CLLocationCoordinate2D? {
        didSet{
            update(animated: true)
        }
    }
    public var driverLocation: CLLocationCoordinate2D?{
        didSet{
            update(animated: true)
        }
    }
    public var driverDirection: CLLocationDirection?{
        didSet{
            update(animated: true)
        }
    }
    public var driverAngle: Double?{
        didSet{
            update(animated: true)
        }
    }
    
    public var path: [CLLocationCoordinate2D]? {
        didSet{
            update(animated: false)
        }
    }
    
    override init() {
        super.init()
        markerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func wasActivated() {
        mapVC.view.addSubview(markerView)
        markerView.isHidden = true
        
        mapVC.view.addSubview(carView)
        carView.contentMode = .scaleAspectFit
        carView.frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        carView.isHidden = true
    }
    
    override func wasDeactivated() {
        markerView.removeFromSuperview()
        carView.removeFromSuperview()
        mapVC.pathView.path = nil
        mapVC.pathView.setNeedsDisplay()
    }
    
    override func cameraChanged() {
        update(animated: false)
    }
    
    private func update(animated: Bool) {
        self.carView.transform = .init(rotationAngle: CGFloat.pi / 2 + CGFloat(MDegreesToRadians(degrees: self.driverAngle ?? 0)))
        UIView.animate(withDuration: (!disableAnimations) && animated ? 1.5: 0) {
            if let clientLocation = self.clientLocation {
                self.markerView.isHidden = false
                let point = self.mapVC.mapView.projection.point(for: clientLocation)
                self.markerView.center = point.applying(.init(translationX: 0, y: 0))
            }
            
            if let driverLocation = self.driverLocation {
                self.carView.isHidden = false
                self.carView.center = self.mapVC.mapView.projection.point(for: driverLocation).applying(.init(translationX: 0, y: 15))
            }
        }
        if let path = path {
            let cgPath = CGMutablePath()
            for loc in path {
                if (cgPath.isEmpty) {
                    cgPath.move(to: self.mapVC.mapView.projection.point(for: loc))
                }
                else {
                    cgPath.addLine(to: self.mapVC.mapView.projection.point(for: loc))
                }
            }
            mapVC.pathView.path = cgPath
            mapVC.pathView.setNeedsDisplay()
        }
        else {
            mapVC.pathView.path = nil
            mapVC.pathView.setNeedsDisplay()
        }
    }
}

class DPathView: UIView {
    public var path: CGPath?
    
    override func draw(_ rect: CGRect) {
        if let path = path {
            let uiPath = UIBezierPath(cgPath: path)
            UIColor.blue.setStroke()
            uiPath.lineWidth = 3
            uiPath.stroke()
        }
    }
}

class DMapViewController: UIViewController {
    
    // MARK: Private vars
    internal let context: DContext
    internal var mapView: GMSMapView
    private var touchGestureRecognizer = DTouchGestureRecognizer()
    private var viewMode: DMapViewMode = DMapViewModeNormal()
    internal var pathView = DPathView()
    
    // MARK: Init
    public init(context: DContext) {
        self.context = context
        mapView = GMSMapView(frame: .zero,
                             camera: GMSCameraPosition(latitude: 46.4815, longitude: 30.7347, zoom: 16))
        
        super.init(nibName: nil, bundle: nil)
        view.addSubview(mapView)
        NSLayoutConstraint.activateConstraints(for: mapView, in: view)
        
        pathView.isUserInteractionEnabled = false
        pathView.backgroundColor = .clear
        view.addSubview(pathView)
        NSLayoutConstraint.activateConstraints(for: pathView, in: mapView)
        
        mapView.isMyLocationEnabled = true
        mapView.settings.consumesGesturesInView = false
        mapView.settings.compassButton = true
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        
        for favourite in context.favourites {
            let marker = GMSMarker(position: favourite.location2d)
            marker.icon = UIImage(named: "star")!
            marker.map = mapView
        }
        
        mapView.delegate = self
        
        self.mapView.addGestureRecognizer(touchGestureRecognizer)
        touchGestureRecognizer.touchDelegate = self
        
        updateViewMode(DMapViewModeNormal())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateViewMode(_ newMode: DMapViewMode) {
        self.viewMode.wasDeactivated()
        self.viewMode.mapVC = nil
        
        self.viewMode = newMode
        self.viewMode.mapVC = self
        self.viewMode.wasActivated()
        self.viewMode.cameraChanged()
    }
    
    public func setLocation(_ loc: CLLocationCoordinate2D) {
        self.mapView.moveCamera(.setTarget(loc))
    }
}

extension DMapViewController: DTouchGestureRecognizerDelegate {
    func touchGestureRecognizerTouchesBegan(_ gr: DTouchGestureRecognizer) {
        self.viewMode.touchGestureRecognizerTouchesBegan(gr)
    }
    
    func touchGestureRecognizerTouchesEnded(_ gr: DTouchGestureRecognizer) {
        self.viewMode.touchGestureRecognizerTouchesEnded(gr)
    }
}

extension DMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.viewMode.cameraChanged()
    }
}
