//
//  ViewController.swift
//  AR Fortia
//
//  Created by Leonidas Mavrotas on 1/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

// MARK: - Global Properties

let cbNotificationKey = "com.leomav.coulombValueChange"
let topoNotificationKey = "com.leomav.topologyChange"
let removalNotificationKey = "com.leomav.coulombRemoval"
let dismissalNotificationKey = "com.leomav.coulombMenuDismissal"

///// Add object Interaction and Gestures
//var virtualObjectInteraction: VirtualObjectInteraction?

/// PointCharge
var selectedPointChargeObj: PointChargeClass = PointChargeClass(onEntity: Entity(), withValue: 0)
var longPressedEntity: Entity = Entity()
var trackedEntity: Entity = Entity()

/// Coulomb Text Material
let coulombTextMaterial: SimpleMaterial = {
    var mat = SimpleMaterial()
    mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
    mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
    mat.tintColor = UIColor.white
    return mat
}()

let ZOOM_IN_5_4: Float = 1.25
let ZOOM_OUT_4_5: Float = 0.8

let Ke: Float = 9 * pow(10, 9)

// MARK: - ViewController (main)

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet var arView: ARView!
    
    /// Button for appearing topos !!!!! CHANGE
    let addButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    @objc
    func performAddition(sender: UIButton) {
        self.topology?.addPointChargeWithRandomPosition()
        
//        self.addButton.isEnabled = false
    }
    
    // MARK: - UI Elements
    
    let coachingOverlay = ARCoachingOverlayView()
    
    // MARK: - Properties
    
    var topology: Topology?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.arView.session.delegate = self
        
        /// Set up ARView
        self.setupARView()
        
        /// Set up coaching overlay.
        self.setupCoachingOverlay()
        
        /// Create the Topology Notification Observer
        self.setupObserverNewTopo()
        
        /// Create the CoulombMenu Dismissal Observer
        self.setupObserverCoulombMenuDismissal()
        
        /// First tap gesture recognizer, will be deleted after first point of charge is added
        self.setupTapGestureRecognizer()

        /// Long Press Recognizer to enable parameters interaction with Point Charge (min press 1 sec)
        self.setupLongPressRecognizer()
        
        /// Set up the ADD Button (adds pointcharge to scene)
        self.configureAddButton()
    }
    
    // MARK: - Private Setup startup Functions
    
    private func setupARView() {
        self.arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        self.arView.session.run(config)
        
        /// Add the Add Button to the arView before the button gets its contstraints (relatively to arView)
        self.arView.addSubview(addButton)
    }
    
    private func setupTapGestureRecognizer() {
        let firstPointTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        firstPointTapRecognizer.name = "First Point Recognizer"
        self.arView.addGestureRecognizer(firstPointTapRecognizer)
    }
    
    private func setupLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longPressRecognizer.name = "Long Press Recognizer"
        longPressRecognizer.minimumPressDuration = 1
        self.arView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.isEnabled =  false
    }
    
    private func configureAddButton () {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
            
        let image = UIImage(systemName: "plus", withConfiguration: config)
        
        self.addButton.setImage(image, for: .normal)
        
        let padding: CGFloat = 8.0
        
        self.addButton.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        self.addButton.addTarget(self, action: #selector(performAddition(sender:)), for: .touchUpInside)
        
        self.addButton.layer.cornerRadius = 10
//        self.addButton.imageView?.clipsToBounds = true
        
        self.addButton.tintColor = UIColor.white
        self.addButton.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        /// At first, it's hidden and disabled until a topology is placed
        self.hideAndDisableButton(btn: self.addButton)
        
        self.addButton.bottomAnchor.constraint(equalTo: self.arView.bottomAnchor, constant: -50).isActive = true
        self.addButton.trailingAnchor.constraint(equalTo: self.arView.trailingAnchor, constant: -15).isActive = true
    }

    // MARK: - (De)emphasize the tracked pointCharge Entity
    
    func pointChargeInteract(zoom: Float, showLabel: Bool) {
        /// (De)emphasize the Point Charge by scaling it down/up 0.8/1.25
        trackedEntity.setScale(SIMD3<Float>(zoom, zoom, zoom), relativeTo: trackedEntity)
        /// Show/Hide the value label
        trackedEntity.children.forEach{ child in
            if child.name == "text" {
                child.isEnabled = showLabel
            }
        }
    }
    
    // MARK: - Add Button Existance
    
    func showAndEnableButton(btn: UIButton) {
        btn.isHidden = false
        btn.isEnabled = true
    }
    
    func hideAndDisableButton(btn: UIButton) {
        btn.isHidden = true
        btn.isEnabled = false
    }
    
    
}

// MARK: - CONVERTER: Degrees <--> Radians
extension BinaryInteger {
    func degreesToRadians<F: FloatingPoint>() -> F {  F(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
