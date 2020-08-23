//
//  ViewController_+_ObjectPlacement.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 1/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import ARKit
import RealityKit

extension ViewController: ARSessionDelegate {
    
    
    func placeObject(for anchor: ARAnchor) {
        
        /// Add the anchor of the scene where the user tapped
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.name = "Point Charge Scene AnchorEntity"
        arView.scene.addAnchor(anchorEntity)
        
        /// Import the Point Charge Model, clone the entity as many times as needed
        let pointChargeAnchor = try! PointCharge.load_PointCharge()
        let pointChargeEntity = pointChargeAnchor.pointCharge!
        
        for pos in selectedPositions {
            let point = pointChargeEntity.clone(recursive: true)
            anchorEntity.addChild(point)
            point.setPosition(pos, relativeTo: anchorEntity)
            
            /// Create new PointChargeClass Object and append it to pointCharges[]
            let newPoint = PointChargeClass(entity: point, value: 5)
            pointCharges.append(newPoint)
            
            /// Create Text Entity for the pointCharge
            let textEntity = createTextEntity(pointEntity: point)
            /// Load the mesh and material for the model of the text entity
            loadText(textEntity: textEntity, material: coulombTextMaterial, coulombStringValue: "\(newPoint.value) Cb")
            
            /// Install gestures
            point.generateCollisionShapes(recursive: false)
            arView.installGestures([.translation, .rotation], for: point as! HasCollision)
        }
        
        arView.gestureRecognizers?.forEach { recognizer in
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
        createCbObserver()
        
        /// Add all forces to all the pointCharge Objects
        addAllForces()
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "PointCharge" {
                
                /// Open the bottom Coulomb Topology menu to choose topology
                performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
                
                /// Set the AnchorEntity for the topology of the scene (where the user tapped)
                topoAnchor = anchor
            }
        }
    }
}
