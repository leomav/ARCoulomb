//
//  Topology.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 24/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import ARKit
import RealityKit

class Topology {
    
    /// The ViewController which contains the topology
    let viewController: ViewController
    /// Anchor of the topology in the scene
    var topoAnchor: ARAnchor?
    /// Selected positions for the pointCharges Entities
    var selectedPositions: [SIMD3<Float>]
    /// All the pointCharge Objects
    var pointCharges: [PointChargeClass]
    /// All the netForces
    var netForces: [NetForce]
    
    init(viewController: ViewController, topoAnchor: ARAnchor, selectedPositions: [SIMD3<Float>]) {
        self.viewController = viewController
        self.topoAnchor = topoAnchor
        self.selectedPositions = selectedPositions
        self.pointCharges = []
        self.netForces = []
        
        /// Create an Observer for selectedPointChargeObj's Coulomb Value
        //createCbObserver()
    }
    
//    /// Topology Observer: When new topology is selected
//    func createTopoObserver() {
//        let notifName = Notification.Name(rawValue: topoNotificationKey)
//        NotificationCenter.default.addObserver(self, selector: #selector(updateTopology(notification:)), name: notifName, object: nil)
//    }
//    /// update the selected Positions
//    @objc
//    func updateTopology(notification: Notification) {
//        if let newValue = (notification.userInfo?["updatedValue"]) as? [SIMD3<Float>] {
//            /// Empty current selectedPositionsArray and fill it again with the new positions
//            self.selectedPositions.removeAll()
//            self.selectedPositions.append(contentsOf: newValue)
//
//            /// Place the selected Topology on the AnchorEntity placed in scene
//            if self.topoAnchor != nil {
//                viewController.placeObject(for: self.topoAnchor!)
//            } else {
//                print("Error: No anchor is selected for topology placement!")
//            }
//
//        } else {
//            print("Error: Not updated topology!")
//        }
//    }
    
//    // MARK: - Coulomb Observer:
//    
//    /// When new value occurs for the selected PointChargeObj
//    func createCbObserver() {
//        let notifName = Notification.Name(rawValue: cbNotificationKey)
//        NotificationCenter.default.addObserver(self.viewController, selector: #selector(updateCoulombValue(notification:)), name: notifName, object: nil)
//    }
//    /// Set the new selected Point Charge obj's value, update its text, update its text, update all forces
//    @objc
//    func updateCoulombValue(notification: Notification) {
//        if let newValue = (notification.userInfo?["updatedValue"]) as? Float {
//            
//            selectedPointChargeObj.value = newValue
//            
//            PointChargeClass.loadText(textEntity: longPressedEntity.children[1], material: coulombTextMaterial, coulombStringValue: "\(newValue) Cb")
//            
//            self.viewController.updateForces()
//        } else {
//            print("Error: Not updated coulomb value!")
//        }
//    }
    
    // MARK: - Topology private functions
    
    func placeTopology(for topoAnchor: ARAnchor) {
        /// Add the Anchor Entity to the scene (where the user tapped)
        let anchorEntity = AnchorEntity(anchor: topoAnchor)
        anchorEntity.name = "Point Charge Scene AnchorEntity"
        self.viewController.arView.scene.addAnchor(anchorEntity)
        
        /// Import the Point Charge Model, clone the entity as many times as needed
        let pointChargeAnchor = try! PointCharge.load_PointCharge()
        let pointChargeEntity = pointChargeAnchor.pointCharge!
        
        for pos in selectedPositions {
            addPointCharge(to: pos, pointChargeEntity: pointChargeEntity, onAnchorEntity: anchorEntity)
//            let point = pointChargeEntity.clone(recursive: true)
//            anchorEntity.addChild(point)
//            point.setPosition(pos, relativeTo: anchorEntity)
//
//            /// Create new PointChargeClass Object and append it to pointCharges[]
//            let newPoint = PointChargeClass(in: viewController, onEntity: point, withValue: 5)
//            pointCharges.append(newPoint)
//
//            /// Create Text Entity for the pointCharge
//            let textEntity = createTextEntity(pointEntity: point)
//            /// Load the mesh and material for the model of the text entity
//            loadText(textEntity: textEntity, material: coulombTextMaterial, coulombStringValue: "\(newPoint.value) Cb")
//
//            /// Install gestures
//            point.generateCollisionShapes(recursive: false)
//            viewController.arView.installGestures([.translation, .rotation], for: point as! HasCollision)
        }
        
        self.viewController.arView.gestureRecognizers?.forEach { recognizer in
            /// Remove gesture recognizer for the first point of charge
            if recognizer.name == "First Point Recognizer" {
                recognizer.isEnabled = false
            }
            /// Enable the pointCharge  LongPress Recognizer
            if recognizer.name == "Long Press Recognizer" {
                recognizer.isEnabled = true
            }
            
            /// Installed gestures (EntityGesturesRecognizers for each point charge) were cancelling
            /// other touches, so turn that to false
            recognizer.cancelsTouchesInView = false
        }
        
        /// Create observer for changes in selected PointChargObj's coulomb Value
        self.viewController.createCbObserver()
        
        /// Add all forces to all the pointCharge Objects
        self.viewController.addAllForces()
    }
    
    private func addPointCharge(to pos: SIMD3<Float>, pointChargeEntity: Entity, onAnchorEntity anchorEntity: Entity) {
        /// Load the PointChargeEntity by cloning it
        let point = pointChargeEntity.clone(recursive: true)
        
        /// Add it to the AnchorEntity of the Topology
        anchorEntity.addChild(point)
        
        /// Set its position relative to the Anchor Entity
        point.setPosition(pos, relativeTo: anchorEntity)
        
        /// Create new PointChargeClass Object and append it to pointCharges[]
        let newPointChargeObj = PointChargeClass(onEntity: point, withValue: 5)
        pointCharges.append(newPointChargeObj)
        
        /// Create Text Entity for the pointCharge
        let textEntity = newPointChargeObj.createTextEntity(pointEntity: point)
        /// Load the mesh and material for the model of the text entity
        PointChargeClass.loadText(textEntity: textEntity, material: coulombTextMaterial, coulombStringValue: "\(newPointChargeObj.value) Cb")
        
        /// Install gestures
        point.generateCollisionShapes(recursive: false)
        self.viewController.arView.installGestures([.translation, .rotation], for: point as! HasCollision)
    }
    
    private func removePointCharge() {
        // TODO
    }
}
