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

let cbNotificationKey = "com.leomav.coulombValueChange"
let topoNotificationKey = "com.leomav.topologyChange"

let ZOOM_IN_5_4: Float = 1.25
let ZOOM_OUT_4_5: Float = 0.8

let Ke: Float = 9 * pow(10, 9)

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    let coulombTextMaterial: SimpleMaterial = {
        var mat = SimpleMaterial()
        mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
        mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
        mat.tintColor = UIColor.white
        return mat
    }()
    
    var selectedPositions: [SIMD3<Float>] = []
    
    var trackedEntity: Entity = Entity()
    var longPressedEntity: Entity = Entity()
    
    // Array of PointChargeClass Objects, that contain pointCharge info all
    // (id, entity)
    var pointCharges: [PointChargeClass] = []
    
    // Array of Force Objects that contain force info
    var netForces: [NetForce] = []
    
    // Button for appearing topos !!!!! CHANGE
    let btn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 50, y: 50, width: 150, height: 50))
        btn.setTitle("Choose Topo", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.addTarget(self, action: #selector(chooseTopoButtonAction(sender:)), for: .touchUpInside)
        btn.isEnabled = true
        
        return btn
    }()
    @objc func chooseTopoButtonAction(sender: UIButton) {
        performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
//        addStackView()
        createTopoObserver()
        
        // First tap gesture recognizer, will be deleted after first point of charge is added
        let firstPointTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        firstPointTapRecognizer.name = "First Point Recognizer"
        arView.addGestureRecognizer(firstPointTapRecognizer)
        
        // Long Press Recognizer to enable parameters interaction with Point Charge (min press 1 sec)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longPressRecognizer.name = "Long Press Recognizer"
        longPressRecognizer.minimumPressDuration = 1
        arView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.isEnabled =  false
        
        // !!!!!!!!!!!!!!!! ADD BUTTON
        arView.addSubview(btn)
        btn.topAnchor.constraint(equalTo: arView.topAnchor).isActive = true
        btn.leadingAnchor.constraint(equalTo: arView.leadingAnchor).isActive = true

    }
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }
    
    
    // ---------------------------------------------------------------------------------
    // --------------------------- TEXT ENTITY -----------------------------------------
    func createTextEntity(pointEntity: Entity) -> Entity {
        let textEntity: Entity = Entity()
        textEntity.name = "text"
        textEntity.setParent(pointEntity)
//        textEntity.setPosition(SIMD3<Float>(-0.02, -0.03, 0.03), relativeTo: pointEntity)
//        textEntity.setOrientation(simd_quatf(ix: -0.45, iy: 0, iz: 0, r: 0.9), relativeTo: pointEntity)
        textEntity.setPosition(SIMD3<Float>(-0.02, -0.03, 0), relativeTo: pointEntity)
        textEntity.setOrientation(simd_quatf(angle: Int(90).degreesToRadians(), axis: SIMD3<Float>(1, 0, 0)), relativeTo: pointEntity)

        
        return textEntity
    }
    
    func loadText(textEntity: Entity, material: SimpleMaterial, coulombStringValue: String) {
        let model: ModelComponent = ModelComponent(mesh: .generateText(coulombStringValue,
                                                                       extrusionDepth: 0.003,
                                                                       font: .systemFont(ofSize: 0.02),
                                                                       containerFrame: CGRect.zero,
                                                                       alignment: .left,
                                                                       lineBreakMode: .byCharWrapping),
                                                   materials: [material])
        textEntity.components.set(model)
    }
    
    
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Notification OBSERVERS -------------------------------
    func createCbObserver() {
        let notifName = Notification.Name(rawValue: cbNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCoulombValue(notification:)), name: notifName, object: nil)
    }
    
    @objc func updateCoulombValue(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? Float {
            loadText(textEntity: longPressedEntity.children[1], material: coulombTextMaterial, coulombStringValue: "\(newValue) Cb")
        } else {
            print("Error: Not updated coulomb value!")
        }
    }
    
    func createTopoObserver() {
        let notifName = Notification.Name(rawValue: topoNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTopology(notification:)), name: notifName, object: nil)
    }
    
    @objc func updateTopology(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? [SIMD3<Float>] {
            /// Empty current selectedPositionsArray and fill it again with the new positions
            selectedPositions.removeAll()
            selectedPositions.append(contentsOf: newValue)
        } else {
            print("Error: Not updated topology!")
        }
    }
    
    
    
    
    // ---------------------------------------------------------------------------------
    // -------------------------- pointCharge INTERACTION ------------------------------
    // Emphasize or Deemphasize
    func pointChargeInteraction(zoom: Float, showLabel: Bool) {
        // (De)emphasize the Point Charge by scaling it down/up 50%
        trackedEntity.setScale(SIMD3<Float>(zoom, zoom, zoom), relativeTo: trackedEntity)
        // Show/Hide the value label
        trackedEntity.children.forEach{ child in
            if child.name == "text" {
                child.isEnabled = showLabel
            }
        }
    }
    
    //    // Add  Coaching View to help user
    //    func overlayCoachingView() {
    //        let coachingView = ARCoachingOverlayView(frame: CGRect(x: 0, y:0, width: arView.frame.width, height: arView.frame.height))
    //
    //        coachingView.session = arView.session
    //        coachingView.activatesAutomatically = true
    //        coachingView.goal = .horizontalPlane
    //
    //        view.addSubview(coachingView)
    //    }
    
}

// MARK: - CONVERTER: Degrees <--> Radians
extension BinaryInteger {
    func degreesToRadians<F: FloatingPoint>() -> F {  F(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
