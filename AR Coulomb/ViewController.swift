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
var selectedPointChargeObj: PointChargeClass = PointChargeClass(entity: Entity(), value: 0)
var longPressedEntity: Entity = Entity()
var trackedEntity: Entity = Entity()

/// PointCarge Topology
var topoAnchor: ARAnchor?
var selectedPositions: [SIMD3<Float>] = []
var pointCharges: [PointChargeClass] = []
var netForces: [NetForce] = []

let ZOOM_IN_5_4: Float = 1.25
let ZOOM_OUT_4_5: Float = 0.8

let Ke: Float = 9 * pow(10, 9)

// MARK: - ViewController (main)

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet var arView: ARView!
    
    /// Button for appearing topos !!!!! CHANGE
//    let btn: UIButton = {
//        let btn = UIButton(frame: CGRect(x: 50, y: 50, width: 150, height: 50))
//        btn.setTitle("Choose Topo", for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
//        btn.addTarget(self, action: #selector(chooseTopoButtonAction(sender:)), for: .touchUpInside)
//        btn.isEnabled = true
//
//        return btn
//    }()
//    
//    @objc
//    func chooseTopoButtonAction(sender: UIButton) {
//        performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
//    }
    
    // MARK: - UI Elements
    
    let coachingOverlay = ARCoachingOverlayView()
    
    let coulombTextMaterial: SimpleMaterial = {
        var mat = SimpleMaterial()
        mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
        mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
        mat.tintColor = UIColor.white
        return mat
    }()
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        /// Set up ARView
        setupARView()
        
//        virtualObjectInteraction = VirtualObjectInteraction(view: arView, controller: self)
        
        /// Set up coaching overlay.
        setupCoachingOverlay()
        
        /// Create the Topology Notification Observer
        createTopoObserver()
        
        /// First tap gesture recognizer, will be deleted after first point of charge is added
        setupTapGestureRecognizer()

        /// Long Press Recognizer to enable parameters interaction with Point Charge (min press 1 sec)
        setupLongPressRecognizer()
        
        // !!!!!!!!!!!!!!!! ADD BUTTON
        //arView.addSubview(btn)
        //btn.topAnchor.constraint(equalTo: arView.topAnchor).isActive = true
        //btn.leadingAnchor.constraint(equalTo: arView.leadingAnchor).isActive = true

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
            selectedPositions.removeAll()
            selectedPositions.append(contentsOf: newValue)
            
            /// Place the selected Topology on the AnchorEntity placed in scene
            if topoAnchor != nil {
                placeObject(for: topoAnchor!)
            } else {
                print("Error: No anchor is selected for topology placement!")
            }

        } else {
            print("Error: Not updated topology!")
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
