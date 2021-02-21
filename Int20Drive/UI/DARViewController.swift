//
//  DARViewController.swift
//  Int20Drive
//
//  Created by Andrii Zinoviev on 20.02.2021.
//

import Foundation
import UIKit
import ARKit

public class MARObject: NSObject {
    public let node: SCNNode
    
    func update(sceneView: ARSCNView) {
        
    }
    
    public init(node: SCNNode) {
        self.node = node
        super.init()
    }
}

public class MARDirectionMarker: MARObject {
    public var bearingDegrees: Double
    public var heightDegrees: Double
    
    public var color: UIColor {
        didSet {
            node.geometry!.firstMaterial!.diffuse.contents = color
        }
    }
    
    public init(bearingDegrees: Double, color: UIColor, heightDegrees: Double = 0) {
        self.bearingDegrees = bearingDegrees
        self.heightDegrees = heightDegrees
        self.color = color
        
        let geometry = SCNSphere(radius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = color
        geometry.firstMaterial = material
        
        super.init(node: SCNNode(geometry: geometry))
    }
    
    public convenience init() {
        self.init(bearingDegrees: 0, color: .white)
    }
    
    public override func update(sceneView: ARSCNView) {
        super.update(sceneView: sceneView)
        guard let cameraPosition = sceneView.pointOfView?.position else {
            return
        }
        let bearingRadians = MDegreesToRadians(degrees: self.bearingDegrees)
        let heightRadians = MDegreesToRadians(degrees: self.heightDegrees)
        self.node.position = (cameraPosition + SCNVector3(sin(bearingRadians), sin(heightRadians), -cos(bearingRadians)))
    }
}


class DARViewController: UIViewController {
    
    private let context: DContext
    
    // MARK: MARViewController
    
    public var targetBearingDegrees: Double? {
        didSet {
            if let targetBearingDegrees = targetBearingDegrees {
                targetMarker.node.isHidden = false
                targetMarker.bearingDegrees = targetBearingDegrees
            }
            else {
                targetMarker.node.isHidden = true
                targetMarker.bearingDegrees = 0
            }
        }
    }
    
    // MARK: Private vars
    
    private let targetMarker = MARDirectionMarker(bearingDegrees: 0, color: .cyan)
    private var objects: Set<MARObject> = []
    
    private var sceneView: ARSCNView
    
    // MARK: Init
    
    public init(context: DContext) {
        self.context = context
        sceneView = ARSCNView()
        sceneView.autoenablesDefaultLighting = true
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(sceneView)
        NSLayoutConstraint.activateConstraints(for: sceneView, in: view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        sceneView.delegate = self
        
        let coachingView = ARCoachingOverlayView()
        coachingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingView.goal = .tracking
        coachingView.session = sceneView.session
        coachingView.activatesAutomatically = true
        coachingView.delegate = self
        sceneView.addSubview(coachingView)
        
        let compassHeightAngle = 15.0
        let compassMarkers = [
            MARDirectionMarker(bearingDegrees:   0, color: .red  , heightDegrees: compassHeightAngle),
            MARDirectionMarker(bearingDegrees: 180, color: .blue , heightDegrees: compassHeightAngle),
            MARDirectionMarker(bearingDegrees: -90, color: .green, heightDegrees: compassHeightAngle),
            MARDirectionMarker(bearingDegrees:  90, color: .green, heightDegrees: compassHeightAngle),
        ]
        for marker in compassMarkers {
            addObject(marker)
        }

        targetMarker.node.isHidden = true
        addObject(targetMarker)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration, options: [.resetTracking])
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: Private
    
    private func addObject(_ object: MARObject) {
        objects.insert(object)
        sceneView.scene.rootNode.addChildNode(object.node)
    }
    
    private func removeObject(_ object: MARObject) {
        assert(objects.contains(object))
        object.node.removeFromParentNode()
        objects.remove(object)
    }
}

extension DARViewController: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        for object in self.objects {
            object.update(sceneView: sceneView)
        }
    }
}

extension DARViewController: ARCoachingOverlayViewDelegate {
    
}
