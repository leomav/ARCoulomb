//
//  Topology_+_PointCharges.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import RealityKit

extension Topology {
    
    func addPointChargeWithRandomPosition() {
        if self.pointCharges.count == 6 {
            
            Alert.showPointChargesLimitReached(on: self.viewController!)
            
            return
        }
        
        /// Get a Random Position
        let randomPos = self.randomPosition()
        
        /// Create new PointCharge
        self.addPointCharge(to: randomPos)
        
        /// Enable the new LongPressRecognizer for thisPointCharge and set .cancelsTouchesInView to false
        self.viewController?.enableRecognizers(withName: "Long Press Recognizer")
        
        /// ReCalculate all Forces and Distance Indicators
        self.reloadAllForces()
        self.reloadDistanceIndicators()
        
        /// Enable Arrows for SingleForces and NetForce of the selectedPointChargeObj (the recently added)
        self.showForces(for: selectedPointChargeObj)
        self.showDistaneIndicators(for: selectedPointChargeObj)
        
        /// Disable and hide the StackView Buttons 
        self.viewController?.toggleStackView(hide: true, animated: false)
        
        /// Perform seague to CoulombMenu ViewController
        self.viewController?.performSegue(withIdentifier: "toCoulombMenuSegue", sender: nil)
    }
    
    // This function is used to add pointCharge, when coreData is used with PointChargeModel as parameter
    func add(pointCharge p: PointChargeModel) {
        /// Load the PointChargeEntity by cloning it
        let point = self.pointChargeEntityTemplate?.clone(recursive: true)
        
        /// Add it to the AnchorEntity of the Topology
        self.topoAnchorEntity?.addChild(point!)
        
        /// Create a position based on PointChargeModel coordinates
        let pos: SIMD3<Float> = p.position
        
        /// Set its position relative to the Anchor Entity
        point?.setPosition(pos, relativeTo: self.topoAnchorEntity)
        
        /// Create new PointChargeClass Object and append it to pointCharges[]
        let newPointChargeObj = PointChargeClass(on: point!, inside: self, withValue: p.value)
        self.pointCharges.append(newPointChargeObj)
        
        /// Set selectedEntity (longPressedEntity)
        selectedPointChargeObj = newPointChargeObj
        longPressedEntity = point!
        
        /// Create Text Entity for the pointCharge
//        let textPos = SIMD3<Float>(-0.02, (PointChargeClass.pointChargeRadius + 0.005), PointChargeClass.pointChargeRadius + 0.005)
//        let textEntity = EntityStore.shared.load_TextEntity(on: newPointChargeObj.entity, name: "Coulomb Text", position: textPos)
        /// Add Label Entity to pointCharge
//        newPointChargeObj.labelEntity = textEntity

        /// Load the mesh and material for the model of the text entity
//        EntityStore.shared.update_TextEntity(textEntity: textEntity, material: EntityStore.shared.textMaterial, stringValue: "\(newPointChargeObj.value) Cb")

        /// Install gestures, careful to set its ".cancelTouchesInView" to false cause it cancels touches gestures  other than
        /// the installed below (I do that in Topology Placement)
        self.viewController?.arView.installGestures([.translation, .rotation], for: point as! HasCollision)
        
        /// Enable the pointCharge LongPress Recognizer
        /// Careful that the above installedGesutres for translation and rotation disable the rest recognizers
        /// so for them set ".cancelsTouchesInView" to false, so that LongPress Recognizer is active
        self.viewController?.enableRecognizers(withName: "Long Press Recognizer")
    }
    
    func addPointCharge(to pos: SIMD3<Float>) {
        /// Load the PointChargeEntity by cloning it
        let point = self.pointChargeEntityTemplate?.clone(recursive: true)
        
        /// Add it to the AnchorEntity of the Topology
        self.topoAnchorEntity?.addChild(point!)
        
        /// Set its position relative to the Anchor Entity
        point?.setPosition(pos, relativeTo: self.topoAnchorEntity)
        
        /// Create new PointChargeClass Object and append it to pointCharges[]
        let newPointChargeObj = PointChargeClass(on: point!, inside: self, withValue: 5)
        self.pointCharges.append(newPointChargeObj)
        
        /// Set selectedEntity (longPressedEntity)
        selectedPointChargeObj = newPointChargeObj
        longPressedEntity = point!
        
        /// Create Text Entity for the pointCharge
//        let textPos = SIMD3<Float>(-0.02, (PointChargeClass.pointChargeRadius + 0.01), PointChargeClass.pointChargeRadius + 0.005)
//        let textEntity = EntityStore.shared.load_TextEntity(on: newPointChargeObj.entity, name: "Coulomb Text", position: textPos)
        /// Add Label Entity to pointCharge
//        newPointChargeObj.labelEntity = textEntity
        
        /// Load the mesh and material for the model of the text entity
//        EntityStore.shared.update_TextEntity(textEntity: textEntity, material: EntityStore.shared.textMaterial, stringValue: "\(newPointChargeObj.value) Cb")
        
        /// Install gestures, careful to set its ".cancelTouchesInView" to false cause it cancels touches gestures  other than
        /// the installed below (I do that in Topology Placement)
        self.viewController?.arView.installGestures([.translation, .rotation], for: point as! HasCollision)
        
        /// Enable the pointCharge LongPress Recognizer
        /// Careful that the above installedGesutres for translation and rotation disable the rest recognizers
        /// so for them set ".cancelsTouchesInView" to false, so that LongPress Recognizer is active
        self.viewController?.enableRecognizers(withName: "Long Press Recognizer")
    }
    
    func removeAllPointCharges() {
        self.pointCharges.forEach{ pointChargeObj in
            pointChargeObj.entity.removeFromParent()
        }
        self.pointCharges.removeAll()
    }
    
    func removePointCharge() {
        /// First, find the selectedPointChargeObj and remove it from pointCharges[]
        for i in 0..<self.pointCharges.count {
            if selectedPointChargeObj == self.pointCharges[i] {
                self.pointCharges.remove(at: i)
                break
            }
        }
        
        /// And then remove the longPressedEntity (selected Entity)
        longPressedEntity.removeFromParent()
        
        /// Finally, calculate again All Forces and Distance Indicators
        self.reloadAllForces()
        self.reloadDistanceIndicators()
        
        /// Set a new random selecrtedPointChargeObj ...
        if self.pointCharges.count > 0 {
            selectedPointChargeObj = self.pointCharges.last!
            longPressedEntity = selectedPointChargeObj.entity
        }
        /// ... and show the forces relative to it
        self.showForces(for: selectedPointChargeObj)
        self.showDistaneIndicators(for: selectedPointChargeObj)
    }
    
    // Show or Hide all PointCharges
    func togglePointCharges(show: Bool) {
        self.pointCharges.forEach{ pointChargeObj in
            pointChargeObj.entity.isEnabled = show
        }
    }
    
    // Show or Hide all PointCharges' coulomb label
    func toggleCoulombLabels(show: Bool) {
        self.pointCharges.forEach{ pointChargeObj in
            pointChargeObj.label.isEnabled = show
        }
    }
    
    /// Calculate a random position
    private func randomPosition() -> SIMD3<Float>{
        let randPos: SIMD3<Float>
        
        var xmax: Float = -10000
        var xmin: Float = 10000
        var zmax: Float = -10000
        var zmin: Float = 10000
        
        
        /// If there are not enough ( less than 2 ) pointCharges select a random position
        
        if self.pointCharges.count < 2 {
            if self.selectedPositions.isEmpty {
                /// If there are no selectedPositions, no topo was selected from the menu.
                /// So set a random position in a radius = 0.1 around the Anchor Entity of the topology (around the center)
                xmin = -0.1
                xmax = 0.1
                zmin = -0.1
                zmax = 0.1
            } else {
                /// Else if there are selectedPositions set a random position with them as a radius
                self.selectedPositions.forEach{ pos in
                    if pos.x > xmax {
                        xmax = pos.x
                    }
                    
                    if pos.x < xmin {
                        xmin = pos.x
                    }
                    
                    if pos.z > zmax {
                        zmax = pos.z
                    }
                    
                    if pos.z < zmin {
                        zmin = pos.z
                    }
                }
            }
            /// Else select one between the current pointCharges' positions
        } else {
            self.pointCharges.forEach{ pointChargeObj in
                let pos = pointChargeObj.entity.position
                
                if pos.x > xmax {
                    xmax = pos.x
                }
                
                if pos.x < xmin {
                    xmin = pos.x
                }
                
                if pos.z > zmax {
                    zmax = pos.z
                }
                
                if pos.z < zmin {
                    zmin = pos.z
                }
            }
        }
        
        let randPos_x = Float.random(in: xmin ..< xmax)
        let randPos_z = Float.random(in: zmin ..< zmax)
        
        randPos = SIMD3<Float>(randPos_x, 0, randPos_z)
        
        return randPos
    }
}
