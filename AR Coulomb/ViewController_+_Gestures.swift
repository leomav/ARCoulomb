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
        /// Update selected ARPlaneAnchor
//        self.selectedARPlaneAnchor = self.currentARPlaneAnchor
        
        /// Create new Anchor Entity for Topology
        let anchor = AnchorEntity()
        /// Set its properties
        anchor.name = "Topology"	
        anchor.transform = placementIndicator.transform
        
        /// Disable the Placement Indicator, which also stops updating indicator's transform
        EntityStore.shared.toggle_PlacementIndicator(anchor: placementIndicator, show: false)
        
        /// Remove gesture recognizer needed for the First Tap -> Topology Anchor Placement
        self.disableRecognizers(withName: "First Point Recognizer")

        /// Create a Topology Instance with the added anchor as topoAnchor
        self.topology = Topology()
        self.topology.pinToScene(viewController: self, topoAnchor: anchor)

        /// Open the bottom Coulomb Topology menu to choose topology
        self.performSegueToTopoMenu()
    }

    // MARK: - PointCharge LongPress
    @objc
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        
        /// Re-enable all pointCharge Labels because on first touch (see below) we disable them
        self.topology.toggleCoulombLabels(show: true)
        
        let location = recognizer.location(in: arView)

        guard let hitEntity = arView.entity(at: location) else {return}

        if recognizer.state == .began {
            
            if hitEntity == trackedEntity {
                longPressedEntity = hitEntity
//                pointChargeInteract(zoom: ZOOM_IN_5_4, showLabel: false)

                trackedEntity = Entity()

                /// Find and set the new Selected PointChargeObj
                selectedPointChargeObj = topology.pointCharges.first(where: {$0.entity == longPressedEntity})! 
                
                /// Show forces and distance indicators relative to the selectedPointChargeObj
                self.topology.showForces(for: selectedPointChargeObj)
                self.topology.updateDistanceIndicators(for: selectedPointChargeObj)
                self.topology.showDistaneIndicators(for: selectedPointChargeObj)

                /// Disable and hide the StackView Buttons (add new pointCharge, add new topo)
                self.toggleStackView(hide: true, animated: false)
                
                
//                self.angleOverview.selectForceDrawing(index: selectedPointChargeObj.netForce!.forceId)
                
                /// Hide Angle Overview View
                self.angleOverview.isHidden = true
                self.angleLabel.isHidden = true
                
                self.status?.cancelScheduledMessage(for: .contentPlacement)

                /// Perform seague to CoulombMenu ViewController
                performSegue(withIdentifier: "toCoulombMenuSegue", sender: nil)
            }
        }

        if recognizer.state == .ended {
            if hitEntity.name == "pointCharge" {
//            self.pointChargeInteract(zoom: ZOOM_OUT_4_5, showLabel: true)
            }
        }
    }

    // MARK: - Drag & Drop PointChargeEntities
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self.arView) else {return}
        guard let hitEntity = self.arView.entity(at: location) else {return}
        
        // DEBUG
//        self.arView.gestureRecognizers?.forEach{ r in
//            print(r)
//        }
        //

        if hitEntity.name == "pointCharge" {
            
            trackedEntity = hitEntity
            
            /// Update Angle Overview Selected Force Draw
//            if !(topology.pointCharges.isEmpty) && selectedPointChargeObj.entity.id != trackedEntity.id {
            if !(topology.pointCharges.isEmpty) {

                // Deselect the previous selected force by
                // deselecting them all first
                selectedPointChargeObj.netForce?.selected = false
                selectedPointChargeObj.netForce?.forces.forEach{ f in
                    f.selected = false
                }
                
                // Find the tapped PointCharge Object
                let tappedPointCharge: PointChargeClass = self.topology.pointCharges.first { (p) -> Bool in
                    p.entity.id == trackedEntity.id
                }!
                
                // If the tappedPointCharge is the selectedPointCharge, select its netForce
                if (tappedPointCharge.entity.id == selectedPointChargeObj.entity.id) {
                    selectedPointChargeObj.netForce?.selected = true
                    selectedForceObj = selectedPointChargeObj.netForce!
                    if let angle = selectedPointChargeObj.netForce?.angle {
                        if abs(angle.radiansToDegrees - selectedForceAngleFloatValue.radiansToDegrees) >= 1 {
                            selectedForceAngleFloatValue = angle
                        }
                    }
                        //"\(String(describing: selectedPointChargeObj.netForce?.angle))°"
                } else {
                    // Else, find and select the right force on the selected Point Charge
                    let selectedForce = tappedPointCharge.forcesOnOthers.first { (force) -> Bool in
                        (selectedPointChargeObj.netForce?.forces.contains(where: { (f) -> Bool in
                            force.forceId == f.forceId
                        }))!
                    }
                    selectedForce?.selected = true
                    selectedForceObj = selectedForce!
                    if let angle = selectedForce?.angle {
                        if abs(angle.radiansToDegrees - selectedForceAngleFloatValue.radiansToDegrees) >= 1 {
                            selectedForceAngleFloatValue = angle
                        }

                    }
//                    selectedForceValue = "\(String(describing: selectedForce?.angle))°"
                }
                
                
                

//                self.angleOverview.selectForceDrawing(index: selectedForce!.forceId)
            }
            
            // DELETE AFTER
//            print(selectedPointChargeObj.netForce!.forceId, selectedPointChargeObj.netForce?.selected)
//            selectedPointChargeObj.netForce?.forces.forEach{ f in
//                print(f.forceId, f.selected)
//            }
            
            /// Show PointCharge Interaction
//            self.pointChargeInteract(zoom: ZOOM_IN_5_4, showLabel: false)
            
            /// Hide all forces
            self.topology.toggleAllForces(show: false)
            
            /// Hide all Coulomb Labels
            self.topology.toggleCoulombLabels(show: false)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if trackedEntity.name == "pointCharge" {
            self.topology.updateForces(for: selectedPointChargeObj, reDraw: false)
            self.topology.updateDistanceIndicators(for: selectedPointChargeObj)
            
            
            let angle = selectedForceObj.angle
            if abs(angle.radiansToDegrees - selectedForceAngleFloatValue.radiansToDegrees) >= 1 {
                selectedForceAngleFloatValue = angle
            }
            
            
            // Update angles in Angle Overview
//            self.angleOverview.updateAllForcesAngles(netForce: selectedPointChargeObj.netForce!)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /// If tracked entity is a pointCharge, check if its alignment differ less than 0.02m from the other particles.
        /// If so, align it to them
        if trackedEntity.name == "pointCharge" {
//            self.pointChargeInteract(zoom: ZOOM_OUT_4_5, showLabel: true)
            
            /// Enable Forces again
            self.topology.showForces(for: selectedPointChargeObj)
            
            /// Show all Coulomb Labels
            self.topology.toggleCoulombLabels(show: true)

            let x = trackedEntity.position.x
            let z = trackedEntity.position.z

            // Loop through the scene anchors to find our 'Topology' AnchorEntity
            arView.scene.anchors.forEach{ anchor in
                if anchor.name == "Topology" {
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

            /// Update all forces magnitude,directions and all Distance Indicators
            self.topology.updateForces(for: selectedPointChargeObj)
            self.topology.updateDistanceIndicators(for: selectedPointChargeObj)

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

