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

///// Add object Interaction and Gestures
//var virtualObjectInteraction: VirtualObjectInteraction?

/// PointCharge
var selectedPointChargeObj: PointChargeClass = PointChargeClass(onEntity: Entity(), withValue: 0)
var longPressedEntity: Entity = Entity()
var trackedEntity: Entity = Entity()

/// PointCarge Topology
//var topoAnchor: ARAnchor?
//var selectedPositions: [SIMD3<Float>] = []
//var pointCharges: [PointChargeClass] = []
//var netForces: [NetForce] = []

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
    let btn: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.addTarget(self, action: #selector(performDeletion(sender:)), for: .touchUpInside)
        
        btn.layer.cornerRadius = 10
        
        btn.backgroundColor = UIColor.white
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        
        let image = UIImage(systemName: "trash", withConfiguration: config)
        
        btn.setImage(image, for: .normal)
        
        btn.tintColor = UIColor.red
        
        btn.isEnabled = true
        
        return btn
    }()
    
    let trashImageView: UIImageView = {
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        
        let image = UIImage(systemName: "trash", withConfiguration: config)
        
        let padding: CGFloat = -3.0
        
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white
        imageView.tintColor = UIColor.red
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    @objc
    func performDeletion(sender: UIButton) {
        print("Perform Deletion")
    }
    
    // MARK: - UI Elements
    
    let coachingOverlay = ARCoachingOverlayView()
    
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
        createTopoObserver()
        
        /// First tap gesture recognizer, will be deleted after first point of charge is added
        setupTapGestureRecognizer()

        /// Long Press Recognizer to enable parameters interaction with Point Charge (min press 1 sec)
        setupLongPressRecognizer()
    }
    
    // MARK: - Private Setup startup Functions
    
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
    
    private func setupARView() {
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }
    
    // MARK: - Notification Observers
    
    /// Topology Observer: When new topology is selected
    func createTopoObserver() {
        let notifName = Notification.Name(rawValue: topoNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTopology(notification:)), name: notifName, object: nil)
    }
    /// update the selected Positions
    @objc
    func updateTopology(notification: Notification) {
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

        } else {
            print("Error: Not updated topology!")
        }
    }
    
    // MARK: - Coulomb Observer:
    
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
