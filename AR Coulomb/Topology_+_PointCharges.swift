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
        /// Get a Random Position
        let randomPos = randomPosition()
        
        /// Create new PointCharge
        self.addPointCharge(to: randomPos)
        
        /// Enable the new LongPressRecognizer for thisPointCharge and set .cancelsTouchesInView to false
        self.enableRecognizers(withName: "Long Press Recognizer")
        
        /// ReCalculate all Forces
        self.reloadAllForces()
    }
    
    func addPointCharge(to pos: SIMD3<Float>) {
        /// Load the PointChargeEntity by cloning it
        let point = self.pointChargeEntityTemplate.clone(recursive: true)
        
        /// Add it to the AnchorEntity of the Topology
        self.topoAnchorEntity.addChild(point)
        
        /// Set its position relative to the Anchor Entity
        point.setPosition(pos, relativeTo: self.topoAnchorEntity)
        
        /// Create new PointChargeClass Object and append it to pointCharges[]
        let newPointChargeObj = PointChargeClass(onEntity: point, withValue: 5)
        pointCharges.append(newPointChargeObj)
        
        /// Create Text Entity for the pointCharge
        let textEntity = newPointChargeObj.createTextEntity(pointEntity: point)
        /// Load the mesh and material for the model of the text entity
        PointChargeClass.loadText(textEntity: textEntity, material: coulombTextMaterial, coulombStringValue: "\(newPointChargeObj.value) Cb")
        
        /// Install gestures, careful to set its ".cancelTouchesInView" to false cause it cancels touches gestures  other than
        /// the installed below (I do that in Topology Placement)
        point.generateCollisionShapes(recursive: false)
        self.viewController.arView.installGestures([.translation, .rotation], for: point as! HasCollision)
    }
    
    func removePointCharge() {
        /// First, find the selectedPointChargeObj and remove it from pointCharges[]
        for i in 0..<self.pointCharges.count {
            if selectedPointChargeObj == self.pointCharges[i] {
                self.pointCharges.remove(at: i)
                break
            }
        }
        
//        /// Then, remove the position of this longPressedEntity (selected Entity)
//        for i in 0..<self.selectedPositions.count {
//            if longPressedEntity.position == self.selectedPositions[i] {
//                self.selectedPositions.remove(at: i)
//                break
//            }
//        }
        
        /// And then remove the longPressedEntity (selected Entity)
        longPressedEntity.removeFromParent()
        //        longPressedEntity = Entity()
        
        /// Finally, calculate again All Forces
        self.reloadAllForces()
    }
    
    /// Calculate a random position between the selected positions
    private func randomPosition() -> SIMD3<Float>{
        let randPos: SIMD3<Float>
        
        var xmax: Float = -10000
        var xmin: Float = 10000
        var zmax: Float = -10000
        var zmin: Float = 10000
        
        pointCharges.forEach{ pointChargeObj in
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
        let randPos_x = Float.random(in: xmin ..< xmax)
        let randPos_z = Float.random(in: zmin ..< zmax)
        
        randPos = SIMD3<Float>(randPos_x, 0, randPos_z)
        
        return randPos
    }
}
