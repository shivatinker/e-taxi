//
//  DDriverInfoViewController.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import UIKit

class DDriverInfoViewController: UIViewController {
    private let avatarView = UIImageView()
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let govIdLabel = UILabel()
    private let vehicleNameLabel = UILabel()
    private let vehicleImageView = UIImageView()
    private let vehicleImage2View = UIImageView()
    private let driverNameLabel = UILabel()
    private let driverInfoView = UITextView()
    
    public var middleAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor> {
        backgroundView.topAnchor
    }
    
    override func viewDidLoad() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .clear
        view.addSubview(backgroundView)
        
        avatarView.backgroundColor = .white
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.layer.cornerRadius = 50
        avatarView.clipsToBounds = true
        avatarView.contentMode = .scaleAspectFill
        view.addSubview(avatarView)
        
        govIdLabel.translatesAutoresizingMaskIntoConstraints = false
        govIdLabel.textColor = .black
        govIdLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        view.addSubview(govIdLabel)
        
        driverNameLabel.translatesAutoresizingMaskIntoConstraints = false
        driverNameLabel.textColor = .black
        driverNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        driverNameLabel.textAlignment = .center
        view.addSubview(driverNameLabel)
        
        vehicleNameLabel.translatesAutoresizingMaskIntoConstraints = false
        vehicleNameLabel.textColor = .black
        vehicleNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        view.addSubview(vehicleNameLabel)
        
        vehicleImageView.backgroundColor = .clear
        vehicleImageView.translatesAutoresizingMaskIntoConstraints = false
        vehicleImageView.contentMode = .scaleAspectFit
        view.addSubview(vehicleImageView)
        
        driverInfoView.translatesAutoresizingMaskIntoConstraints = false
        driverInfoView.textColor = .black
        driverInfoView.isUserInteractionEnabled = false
        driverInfoView.isEditable = false
        driverInfoView.backgroundColor = .clear
        driverInfoView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        view.addSubview(driverInfoView)
        
        vehicleImage2View.backgroundColor = .clear
        vehicleImage2View.translatesAutoresizingMaskIntoConstraints = false
        vehicleImage2View.contentMode = .scaleAspectFit
        view.addSubview(vehicleImage2View)
        
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            avatarView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 26),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.centerYAnchor.constraint(equalTo: backgroundView.topAnchor),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor),
            
            govIdLabel.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 25),
            govIdLabel.widthAnchor.constraint(equalToConstant: 125),
            govIdLabel.heightAnchor.constraint(equalToConstant: 22),
            govIdLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 5),
            
            vehicleNameLabel.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 25),
            vehicleNameLabel.widthAnchor.constraint(equalToConstant: 125),
            vehicleNameLabel.heightAnchor.constraint(equalToConstant: 15),
            vehicleNameLabel.topAnchor.constraint(equalTo: govIdLabel.bottomAnchor, constant: 5),
            
            driverNameLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            driverNameLabel.widthAnchor.constraint(equalToConstant: 125),
            driverNameLabel.heightAnchor.constraint(equalToConstant: 15),
            driverNameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 5),
            
            vehicleImageView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: 5),
            vehicleImageView.widthAnchor.constraint(equalToConstant: 150),
            vehicleImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: +25),
            vehicleImageView.heightAnchor.constraint(equalToConstant: 50),
            
            driverInfoView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            driverInfoView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            driverInfoView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 100),
            driverInfoView.heightAnchor.constraint(equalToConstant: 155),
            
            vehicleImage2View.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            vehicleImage2View.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            vehicleImage2View.topAnchor.constraint(equalTo: driverInfoView.bottomAnchor, constant: -5),
            vehicleImage2View.heightAnchor.constraint(equalToConstant: 155),
        ])
    }
    
    public func update(_ driver: DDriver) {
        if let avatar = driver.avatar {
            self.avatarView.image = UIImage(cgImage: avatar)
        }
        self.govIdLabel.text = driver.vehicle.governmentId
        self.vehicleNameLabel.text = driver.vehicle.name
        if let image = driver.vehicle.image {
            self.vehicleImageView.image = UIImage(cgImage: image)
        }
        self.driverInfoView.text = driver.info
        self.driverNameLabel.text = driver.name
        self.vehicleImage2View.image = UIImage(cgImage: driver.infoImage)
    }
}
