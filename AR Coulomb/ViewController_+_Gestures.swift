//
//  ViewController_+_Gestures.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 1/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit
import ARKit

extension ViewController {
    
    // MARK: - Initial Tap
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .vertical)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "PointCharge", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("No horizontal surface found.")
        }
    }
    
    // MARK: - PointCharge LongPress
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        guard let hitEntity = arView.entity(at: location) else {return}
        
        if recognizer.state == .began {
            if hitEntity == trackedEntity {
                
                longPressedEntity = hitEntity
                
                pointChargeInteraction(zoom: ZOOM_OUT_4_5, showLabel: true)
                
                trackedEntity = Entity()
                
                performSegue(withIdentifier: "toCoulombMenuSegue", sender: nil)
            }
        }
        
        if recognizer.state == .ended {
            if hitEntity.name == "pointCharge" {
            }
        }
    }
    
    // MARK: - Drag & Drop PointChargeEntities
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: arView) else {return}
        guard let hitEntity = arView.entity(at: location) else {return}
        
        if hitEntity.name == "pointCharge" {
            trackedEntity = hitEntity
            
            pointChargeInteraction(zoom: ZOOM_IN_5_4, showLabel: false)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if trackedEntity.name == "pointCharge" {
            updateArrows()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// If tracked entity is a pointCharge, check if its alignment differ less than 0.02m from the other particles.
        /// If so, align it to them
        if trackedEntity.name == "pointCharge" {
            pointChargeInteraction(zoom: ZOOM_OUT_4_5, showLabel: true)
            
            let x = trackedEntity.position.x
            let z = trackedEntity.position.z
            
            /// Loop through the scene anchors to find our "Point Charge Scene Anchor"
            arView.scene.anchors.forEach{ anchor in
                if anchor.name == "Point Charge Scene AnchorEntity" {
                    /// Loop through its children (pointChargeEntities) and check their (x, z) differences
                    anchor.children.forEach{ child in
                        if child.position.x != x && child.position.z != z{
                            if abs(child.position.x - x) < 0.02 {
                                trackedEntity.position.x = child.position.x
                            }
                            if abs(child.position.z - z) < 0.02 {
                                trackedEntity.position.z = child.position.z
                            }
                        }
                    }
                }
            }
            
            /// Update forces' arrows directions
            updateArrows()
            
            print(trackedEntity.children[3].orientation(relativeTo: trackedEntity).imag.y)
            print(trackedEntity.children[3].orientation(relativeTo: trackedEntity).angle.radiansToDegrees)
            print(trackedEntity.children[4].orientation(relativeTo: trackedEntity).imag.y)
            print(trackedEntity.children[4].orientation(relativeTo: trackedEntity).angle.radiansToDegrees)
            print(trackedEntity.children[2].orientation(relativeTo: trackedEntity).imag.y)
            print(trackedEntity.children[2].orientation(relativeTo: trackedEntity).angle.radiansToDegrees)
            print("Forces")
            print(netForces[0].forces[0].magnetude)
            print(netForces[0].forces[1].magnetude)
            // !!!!!!!!!!!! DELETE AFTER TESTING !!!!!!!!!!!!!
//            var tempbool = false
//            var temp1: Entity = Entity()
//            var temp2: Entity = Entity()
//            trackedEntity.children.forEach{ child in
//                
//                if child.name == "Force Arrow" {
//                    if tempbool == false {
//                        temp1 = child
//                        print(temp1)
//                        print(trackedEntity.children.firstIndex(of: child)!)
//                        tempbool = true
//                    } else {
//                        temp2 = child
//                        print(temp2)
//                        print(trackedEntity.children.firstIndex(of: child)!)
//                    }
//                }
//            }
//            print("-------------------------- ORIENTATION --------------------------")
//            print(temp1.orientation(relativeTo: trackedEntity).angle.radiansToDegrees)
//            
//            print("angle")
//            print(netForces[0].forces[0].angle.radiansToDegrees)
//            
//            print("------- --------- --------")
//            print(temp2.orientation(relativeTo: trackedEntity).angle.radiansToDegrees)
//            print("angle")
//            print(netForces[0].forces[1].angle.radiansToDegrees)
//            
//            print("net force (magnetude, angle)")
//            print(netForces[0].magnetude, netForces[0].angle.radiansToDegrees)
//            print("-------------------------- ORIENTATION --------------------------")

            
            /// When touches end, no entity is tracked by the gesture
            trackedEntity = Entity()
        }
    }
}
