//
//  DMediaBlockView.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import UIKit

enum DMediaActionType {
    case camera
    case audio
    case text
    case tick
    case panorama
    case call
    case chat
}

protocol DMediaButtonDelegate: AnyObject {
    func mediaButtonTap(_ button: DMediaButton)
}

class DMediaButton: UIImageView {
    public let actionType: DMediaActionType
    public weak var delegate: DMediaButtonDelegate?
    
    private let gr = UITapGestureRecognizer()
    
    init(actionType: DMediaActionType) {
        self.actionType = actionType
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
        
        setActivated(false)
        
        self.translatesAutoresizingMaskIntoConstraints = false;
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 43),
            self.widthAnchor.constraint(equalTo: self.heightAnchor),
        ])
        
        self.layer.cornerRadius = 43.0 / 2.0;
        self.clipsToBounds = true
        self.contentMode = .center
        
        switch actionType {
        case .audio: self.image = UIImage(named: "audio")
        case .camera: self.image = UIImage(named: "photo")
        case .text: self.image = UIImage(named: "text")
        case .tick: self.image = UIImage(named: "tick")
        case .panorama: self.image = UIImage(named: "panorama")
        case .call: self.image = UIImage(named: "call")
        case .chat: self.image = UIImage(named: "chat")
        }
        
        self.contentScaleFactor = 0.7
        
        addGestureRecognizer(gr)
        gr.addTarget(self, action: #selector(grr))
    }
    
    @objc func grr() {
        delegate?.mediaButtonTap(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setActivated(_ activated: Bool) {
        self.backgroundColor = activated ? .green : .white
        self.tintColor = activated ? .white : .black
    }
}

class DMediaBlockView: UIView {
    public let photoButton = DMediaButton(actionType: .camera)
    public let textButton = DMediaButton(actionType: .text)
    public let audioButton = DMediaButton(actionType: .audio)
    public let panoramaButton = DMediaButton(actionType: .panorama)
    
    init() {
        super.init(frame: .zero)
        
        addSubview(photoButton)
        addSubview(textButton)
        addSubview(audioButton)
        addSubview(panoramaButton)
        
        NSLayoutConstraint.activate([
            panoramaButton.bottomAnchor.constraint(equalTo: photoButton.topAnchor, constant: -18),
            panoramaButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            panoramaButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            photoButton.bottomAnchor.constraint(equalTo: textButton.topAnchor, constant: -18),
            photoButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            photoButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            textButton.bottomAnchor.constraint(equalTo: audioButton.topAnchor, constant: -18),
            textButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            textButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            audioButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            audioButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            audioButton.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
