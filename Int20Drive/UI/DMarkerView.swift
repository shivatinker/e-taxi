//
//  DMarkerView.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import UIKit

enum DMarkerViewState {
    case detached
    case pinned
}

class DMarkerView: UIImageView {
    private static let markerImageDetached = UIImage.init(named: "marker_detached")
    private static let markerImagePinned = UIImage.init(named: "marker_pinned")
    
    public var state: DMarkerViewState = .pinned {
        didSet {
            update()
        }
    }
    
    public init() {
        super.init(frame: .zero)
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update() {
        switch self.state {
        case .detached: self.image = Self.markerImageDetached
        case .pinned: self.image = Self.markerImagePinned
        }
    }
}
