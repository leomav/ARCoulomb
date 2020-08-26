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
    
    // MARK: - UI Elements
    
    let coachingOverlay = ARCoachingOverlayView()
    
    /// Button for appearing topos !!!!! CHANGE
    let addButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    @objc
    func performAddition(sender: UIButton) {
        print("Perform Addition")
        
        self.addButton.isEnabled = false
    }
    
    // MARK: - Properties
    
    var topology: Topology?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        /// Set up ARView
        setupARView()
        
        /// Set up coaching overlay.
        setupCoachingOverlay()
        
        /// Create the Topology Notification Observer
        setupObserverNewTopo()
        
        /// First tap gesture recognizer, will be deleted after first point of charge is added
        setupTapGestureRecognizer()

        /// Long Press Recognizer to enable parameters interaction with Point Charge (min press 1 sec)
        setupLongPressRecognizer()
        
        /// Set up the ADD Button (adds pointcharge to scene)
        configureAddButton()
    }
    
    // MARK: - Private Setup startup Functions
    
    private func setupARView() {
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        /// Add the Add Button to the arView before the button gets its contstraints (relatively to arView)
        arView.addSubview(addButton)
    }
    
    private func setupTapGestureRecognizer() {
        let firstPointTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        firstPointTapRecognizer.name = "First Point Recognizer"
        arView.addGestureRecognizer(firstPointTapRecognizer)
    }
    
    private func setupLongPressRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longPressRecognizer.name = "Long Press Recognizer"
        longPressRecognizer.minimumPressDuration = 1
        arView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.isEnabled =  false
    }
    
    private func configureAddButton () {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
            
        let image = UIImage(systemName: "plus", withConfiguration: config)
        
        addButton.setImage(image, for: .normal)
        
        let padding: CGFloat = 8.0
        
        addButton.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        addButton.addTarget(self, action: #selector(performAddition(sender:)), for: .touchUpInside)
        addButton.layer.cornerRadius = 10
        addButton.backgroundColor = UIColor(white: 0, alpha: 0.7)
        addButton.tintColor = UIColor.white
        
        /// At first, it's hidden and disabled until a topology is placed
        addButton.isHidden = true
        addButton.isEnabled = false
        
        addButton.bottomAnchor.constraint(equalTo: self.arView.bottomAnchor, constant: -50).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.arView.trailingAnchor, constant: -15).isActive = true
    }
    
    // MARK: - Notification Observers
    
    // Topology Observer
    
    /// Topology Observer: When new topology is selected
    func setupObserverNewTopo() {
        let notifName = Notification.Name(rawValue: topoNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(createTopology(notification:)), name: notifName, object: nil)
    }
    /// update the selected Positions
    @objc
    func createTopology(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? [SIMD3<Float>] {

            /// Empty current selectedPositionsArray and fill it again with the new positions
            topology!.selectedPositions.removeAll()
            topology!.selectedPositions.append(contentsOf: newValue)
            
            /// Place the selected Topology on the AnchorEntity placed in scene
            if topology!.topoAnchor != nil {
                topology!.placeTopology(for: topology!.topoAnchor!)
            } else {
                print("Error: No anchor is selected for topology placement!")
            }
            
            /// Enable the ADD Button
            self.addButton.isHidden = false
            self.addButton.isEnabled = true

        } else {
            print("Error: Not updated topology!")
        }
    }
    
    // Coulomb Removal Observer
    
    /// When a coulomb is deleted in the CoulombMenu ViewController
    func setupObserverPointChargeDeletion() {
        let notifName = Notification.Name(rawValue: removalNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(removePointCharge(notification: )), name: notifName, object: nil)
    }
    /// Remove the selected pointCharge
    @objc
    func removePointCharge(notification: Notification) {
        
        Alert.showDeletionConfirmation(on: self)
    }
    
    // Coulomb Value Observer
    
    /// When new value occurs for the selected PointChargeObj
    func createCbObserver() {
        let notifName = Notification.Name(rawValue: cbNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCoulombValue(notification:)), name: notifName, object: nil)
    }
    /// Set the new selected Point Charge obj's value, update its text, update its text, update all forces
    @objc
    func updateCoulombValue(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? Float {
            
            selectedPointChargeObj.value = newValue
            
            PointChargeClass.loadText(textEntity: longPressedEntity.children[1], material: coulombTextMaterial, coulombStringValue: "\(newValue) Cb")
            
            self.topology?.updateForces()
            
            /// Enable the ADD Button
            self.addButton.isHidden = false
            self.addButton.isEnabled = true
        } else {
            print("Error: Not updated coulomb value!")
        }
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
    
    
}

// MARK: - CONVERTER: Degrees <--> Radians
extension BinaryInteger {
    func degreesToRadians<F: FloatingPoint>() -> F {  F(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
