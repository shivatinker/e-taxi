//
//  DMainViewController.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import CoreLocation
import UIKit
import IntentsUI
import PromiseKit

class DMainViewMode {
    public weak var mainVC: DMainViewController!
    
    internal var context: DContext {
        mainVC.context
    }
    
    func wasActivated() {
        
    }
    
    func wasDeactivated() {
        
    }
    
    func clientLocationUpdated(_ location: CLLocation) {
        
    }
}

class DMainViewModeChooseLocation: DMainViewMode, DMapViewModeChooseLocationDelegate {
    private let mapViewMode = DMapViewModeChooseLocation()
    
    private let callButton = UIButton(type: .system)
    private var chosenLocation: DLocation?
    
    override init() {
        super.init()
        
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setTitle("Go!", for: .normal)
        callButton.backgroundColor = .black
        callButton.setTitleColor(.white, for: .normal)
        callButton.addTarget(self, action: #selector(callButtonAction), for: .touchUpInside)
    }
    
    override func wasActivated() {
        mapViewMode.delegate = self
        mainVC.mapViewController.updateViewMode(mapViewMode)
        
        mainVC.pickedPhoto = nil
        mainVC.mediaBlock.photoButton.setActivated(false)
        
        mainVC.view.addSubview(callButton)
        NSLayoutConstraint.activate([
            callButton.bottomAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            callButton.leftAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.leftAnchor, constant: 17),
            callButton.rightAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.rightAnchor, constant: -17),
            callButton.heightAnchor.constraint(equalToConstant: 62)
        ])
        
        mainVC.view.sendSubviewToBack(mainVC.mapViewController.view)
        mainVC.view.bringSubviewToFront(callButton)
    }
    
    override func wasDeactivated() {
        callButton.removeFromSuperview()
        mapViewMode.delegate = nil
    }
    
    @objc func callButtonAction() {
        guard let location = self.chosenLocation else {
            return
        }
        
        let request = DTripRequest(source: location)
        context.dataModel.requestTrip(request)
            .done { trip in
                self.gotTrip(trip)
            }.catch { (e) in
                fatalError()
            }
    }
    
    private func gotTrip(_ trip: DTrip) {
        let viewMode = DMainViewModeTripTracking(trip: trip)
        mainVC.updateViewMode(viewMode)
    }
    
    func mapViewModeDidChooseLocation(_ location: CLLocationCoordinate2D) {
        context.geocodeRecognizer.decodeLocation(location)
            .done { location in
                self.chosenLocation = location
                print(location.geocode, location.location2d)
                DispatchQueue.main.async {
                    self.mainVC.addressLabel.text = location.geocode
                }
            }.catch { (e) in
                fatalError()
            }
    }
}

class DMainViewModeTripTracking: DMainViewMode, DMediaButtonDelegate {
    private let mapViewMode = DMapViewModeTripTracking()
    private let trip: DTrip
    private var arViewController: DARViewController!
    private var lastDriverLocation: CLLocationCoordinate2D?
    private var lastClientLocation: CLLocation?
    
    private var timer: Timer!
    
    private let tapGR = UITapGestureRecognizer()
    
    private let driverInfoVC = DDriverInfoViewController()
    
    private var bottomConstraint: NSLayoutConstraint!
    private var bottomVCExpanded = false
    
    init(trip: DTrip) {
        self.trip = trip
        super.init()
    }
    
    override func wasActivated() {
        self.arViewController = DARViewController(context: context)
        mainVC.mapViewController.updateViewMode(mapViewMode)
        
        self.mapViewMode.disableAnimations = true
        self.mapViewMode.clientLocation = trip.source.location2d
        self.mapViewMode.disableAnimations = false
        
        mainVC.addChildVCAndView(driverInfoVC)
        driverInfoVC.update(trip.driver)
        driverInfoVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        bottomConstraint = driverInfoVC.view.topAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        
        NSLayoutConstraint.activate([
            bottomConstraint,
            driverInfoVC.view.leftAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.leftAnchor),
            driverInfoVC.view.rightAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.rightAnchor),
            driverInfoVC.view.heightAnchor.constraint(equalToConstant: 550),
        ])
        
        driverInfoVC.view.addGestureRecognizer(tapGR)
        tapGR.addTarget(self, action: #selector(tapgr))
        
        timer = .scheduledTimer(withTimeInterval: 1, repeats: true, block: { (tim) in
            let updateRequest = DTripUpdateRequest(trip: self.trip,
                                                   clientLocation2d: self.trip.source.location2d)
            self.context.dataModel.requestTripUpdate(updateRequest) {update in
                self.updateData(update)
            }
        })
    }
    
    @objc func tapgr() {
        UIView.animate(withDuration: 0.5) {
            self.bottomConstraint.constant = self.bottomVCExpanded ? -100 : -450
            self.mainVC.view.layoutIfNeeded()
        }
        bottomVCExpanded = !bottomVCExpanded
    }
    
    override func wasDeactivated() {
        arViewController.removeFromParent()
        driverInfoVC.removeFromParent()
        topView.removeFromSuperview()
        finishButton.removeFromSuperview()
        driverInfoVC.view.removeFromSuperview()
        arViewController.view.removeFromSuperview()
    }
    
    
    let topView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let tapgr2 = UITapGestureRecognizer()
    
    var arVisible = false
    
    var fst: Bool = true
    
    func updateData(_ data: DTripUpdate) {
        lastDriverLocation = data.driverLocation2d
        DispatchQueue.main.async {
            if (self.fst) {
                self.mapViewMode.disableAnimations = true
            }
            self.mapViewMode.driverLocation = data.driverLocation2d
            self.mapViewMode.driverAngle = data.driverBearing
            self.mapViewMode.path = data.path
            if (self.fst) {
                self.mapViewMode.disableAnimations = false
            }
            self.fst = false
        }
        
        if (data.state == .waitingForClient) {
            context.dataModel.requestPath(data.trip.source.location2d, data.driverLocation2d, travelMode: .walking) { (path) in
                DispatchQueue.main.async {
                    self.mapViewMode.path = path
                }
            }
            
            timer.invalidate()
            
            topView.addGestureRecognizer(tapgr2)
            tapgr2.addTarget(self, action: #selector(tapGR2action))
            mainVC.view.addSubview(topView)
            topView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            label.text = "Tap to open AR assistant"
            label.textAlignment = .center
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            topView.contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                topView.topAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.topAnchor),
                topView.leftAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.leftAnchor),
                topView.rightAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.rightAnchor),
                topView.heightAnchor.constraint(equalToConstant: 75),
            ])
            
            mainVC.addChildVCAndView(arViewController)
            arViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                arViewController.view.topAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.topAnchor),
                arViewController.view.leftAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.leftAnchor),
                arViewController.view.rightAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.rightAnchor),
                arViewController.view.heightAnchor.constraint(equalToConstant: 200),
            ])
            arViewController.view.isHidden = true
            
            mainVC.view.addSubview(finishButton)
            finishButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                finishButton.rightAnchor.constraint(equalTo: mainVC.view.safeAreaLayoutGuide.rightAnchor, constant: -10),
                finishButton.bottomAnchor.constraint(equalTo: driverInfoVC.middleAnchor, constant: -10),
            ])
            finishButton.setActivated(true)
            finishButton.delegate = self
        }
    }
    
    let finishButton = DMediaButton(actionType: .tick)
    
    func mediaButtonTap(_ button: DMediaButton) {
        if (button != finishButton) {
            return
        }
        
        let viewMode = DMainViewModeChooseLocation()
        mainVC.updateViewMode(viewMode)
    }
    
    @objc func tapGR2action() {
        arVisible = !arVisible
        
        if (arVisible) {
            topView.removeGestureRecognizer(tapgr2)
            arViewController.view.addGestureRecognizer(tapgr2)
        }
        else {
            arViewController.view.removeGestureRecognizer(tapgr2)
            topView.addGestureRecognizer(tapgr2)
        }
        
        arViewController.view.isHidden = !arVisible
        topView.isHidden = arVisible
    }
    
    func updateARTarget() {
        if let drLoc = lastDriverLocation,
           let clLoc = lastClientLocation
        {
            arViewController.targetBearingDegrees = clLoc.coordinate.degreesBearingToPoint(point: drLoc)
        }
    }
    
    override func clientLocationUpdated(_ location: CLLocation) {
        self.lastClientLocation = location
        updateARTarget()
    }
}

class DMainViewController: UIViewController {
    internal var pickedPhoto: UIImage?
    
    private let locationManager = CLLocationManager()
    
    internal let addressView = UIImageView()
    internal let addressLabel = UILabel()
    
    internal let context: DContext
    
    internal let mapViewController: DMapViewController
    
    private var needsToUpdateMapLocation: Bool = true
    
    private var viewMode: DMainViewMode = DMainViewMode()
    
    internal let mediaBlock = DMediaBlockView()
    
    public init(context: DContext) {
        self.context = context
        self.mapViewController = DMapViewController(context: context)
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateViewMode(_ viewMode: DMainViewMode) {
        self.viewMode.wasDeactivated()
        self.viewMode.mainVC = nil
        
        self.viewMode = viewMode
        self.viewMode.mainVC = self
        self.viewMode.wasActivated()
    }
    
    override func viewDidLoad() {
        self.addChildVCAndView(mapViewController)
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(for: mapViewController.mapView, in: view)
        
        view.addSubview(mediaBlock)
        mediaBlock.translatesAutoresizingMaskIntoConstraints = false
        
        addressView.image = UIImage(named: "address_bg")!
        addressView.contentMode = .scaleToFill
        addressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addressView)
        
        addressLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        addressLabel.textAlignment = .center
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressView.addSubview(addressLabel)
        NSLayoutConstraint.activateConstraints(for: addressLabel, in: addressView)
        
        NSLayoutConstraint.activate([
            mediaBlock.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 11),
            mediaBlock.heightAnchor.constraint(equalToConstant: 200),
            mediaBlock.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            addressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addressView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            addressView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            addressView.heightAnchor.constraint(equalToConstant: 36),
        ])
        
        mediaBlock.audioButton.delegate = self
        mediaBlock.textButton.delegate = self
        mediaBlock.photoButton.delegate = self
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        userActivity = NSUserActivity(activityType: "current_location")
        let title = "Book a ride right here"
        userActivity?.title = title
        userActivity?.suggestedInvocationPhrase = title
        userActivity?.isEligibleForPrediction = true
        
        updateViewMode(DMainViewModeChooseLocation())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
}

extension DMainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.viewMode.clientLocationUpdated(location)
            if (needsToUpdateMapLocation) {
                needsToUpdateMapLocation = false
                mapViewController.setLocation(location.coordinate)
            }
        }
    }
}

extension DMainViewController: DMediaButtonDelegate {
    func mediaButtonTap(_ button: DMediaButton) {
        switch button.actionType {
        case .audio:
            break
        case .camera:
            if let image = pickedPhoto {
                let vc = DImageViewController(image: image)
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.deleteHandler = {
                    self.pickedPhoto = nil
                    self.mediaBlock.photoButton.setActivated(false)
                }
                present(vc, animated: true, completion: nil)
            }
            else {
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.allowsEditing = true
                vc.delegate = self
                present(vc, animated: true)
            }
        case .text:
            break
        default:
            fatalError()
        }
    }
}

extension DMainViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // print out the image size as a test
        print(image.size)
        self.pickedPhoto = image
        mediaBlock.photoButton.setActivated(true)
    }
}

extension DMainViewController: UINavigationControllerDelegate {
    
}
