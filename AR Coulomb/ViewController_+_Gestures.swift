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

    // MARK: - Initial Tap to place Topology Anchor
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        /// Create new Anchor Entity for Topology
        let anchor = AnchorEntity()
        anchor.name = "Topology"
        anchor.transform = placementIndicator.transform
        
        /// Disable the Placement Indicator, which also stops updating pi's transform
        EntityStore.shared.toggle_PlacementIndicator(anchor: placementIndicator, show: false)
        
        /// Remove gesture recognizer needed for the First Tap -> Topology Anchor Placement
        self.disableRecognizers(withName: "First Point Recognizer")

        /// Create a Topology Instance with the added anchor as topoAnchor
        self.topology = Topology()
        self.topology.pinToScene(viewController: self, topoAnchor: anchor)

        /// Open the bottom Coulomb Topology menu to choose topology
        performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
        
//        let location = recognizer.location(in: arView)
//
//        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
//
//        if let firstResult = results.first {
//            let anchor = ARAnchor(name: "Topology", transform: firstResult.worldTransform)
//            arView.session.add(anchor: anchor)
//            
//            /// Disable the Placement Indicator
//            EntityStore.shared.toggle_PlacementIndicator(anchor: placementIndicator, show: false)
//        } else {
//            print("No surface found.")
//        }
    }

    // MARK: - PointCharge LongPress
    @objc
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: arView)

        guard let hitEntity = arView.entity(at: location) else {return}

        if recognizer.state == .began {
            if hitEntity == trackedEntity {
                longPressedEntity = hitEntity
                pointChargeInteract(zoom: ZOOM_OUT_4_5, showLabel: true)

                trackedEntity = Entity()

                /// Find and set the new Selected PointChargeObj
                selectedPointChargeObj = topology.pointCharges.first(where: {$0.entity == longPressedEntity})! 
                
//                topology!.pointCharges.forEach{ pointChargeObj in
//                    if pointChargeObj.entity == longPressedEntity {
//                        selectedPointChargeObj = pointChargeObj
//                    }
//                }
                
                /// Show forces and distance indicators relative to the selectedPointChargeObj
                self.topology.showForces(for: selectedPointChargeObj)
                self.topology.showDistaneIndicators(for: selectedPointChargeObj)

                /// Disable and hide the StackView Buttons (add new pointCharge, add new topo)
                self.toggleStackView(hide: true, animated: false)
                
                self.status?.cancelScheduledMessage(for: .contentPlacement)

                /// Perform seague to CoulombMenu ViewController
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
        guard let location = touches.first?.location(in: self.arView) else {return}
        guard let hitEntity = self.arView.entity(at: location) else {return}

        if hitEntity.name == "pointCharge" {
            trackedEntity = hitEntity
            
            /// Show PointCharge Interaction
            self.pointChargeInteract(zoom: ZOOM_IN_5_4, showLabel: false)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if trackedEntity.name == "pointCharge" {
            self.topology.updateForces()
            self.topology.updateDistanceIndicators()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// If tracked entity is a pointCharge, check if its alignment differ less than 0.02m from the other particles.
        /// If so, align it to them
        if trackedEntity.name == "pointCharge" {
            self.pointChargeInteract(zoom: ZOOM_OUT_4_5, showLabel: true)

            let x = trackedEntity.position.x
            let z = trackedEntity.position.z

            // Loop through the scene anchors to find our "Point Charge Scene Anchor"
            arView.scene.anchors.forEach{ anchor in
                if anchor.name == "Point Charge Scene AnchorEntity" {
                    // Loop through its children (pointChargeEntities) and check their (x, z) differences
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

            /// Update all forces magnetudes and directions and Distance Indicators
            self.topology.updateForces()
            self.topology.updateDistanceIndicators()

            /// When touches end, no entity is tracked by the gesture
            trackedEntity = Entity()
        }
    }
    
    // MARK: - Enable / Disable Observers Functions
    
    // Should be called every time a pointCharge is created
    func enableRecognizers(withName name: String) {
        self.arView.gestureRecognizers?.forEach{ recognizer in
            
            /// Enable the pointCharge LongPressRecognizer
            if recognizer.name == name {
                recognizer.isEnabled = true
            }
            
            /// Installed gestures (EntityGesturesRecognizers for each point charge) were cancelling
            /// other touches, so turn that to false
            recognizer.cancelsTouchesInView = false
        }
    }
    /*  Should be called after the First Touch happened and the Topology
        Anchor is placed
    */
    func disableRecognizers(withName name: String) {
        self.arView.gestureRecognizers?.forEach{ recognizer in
            
            /// Disable the First Touch Topology Anchor Placement recognizer
            if recognizer.name == name {
                recognizer.isEnabled = false
            }
        }
    }
}

