//
//  ViewController_+_Forces.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 18/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import RealityKit
import Foundation

extension Topology {
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Add FORCE (Obj & Entity) -----------------------------
    func addAllForces() {
        self.viewController?.arView.scene.anchors.forEach{ anchor in
            if anchor.name == "Topology" {
                
                // Add a Force Object and Entity for every pointCharge<->pointCharge combo
                self.pointCharges.forEach{ pointChargeObj in
                    
                    /// Create NetForce Object
                    let netForce = Force.createNetForce(for: pointChargeObj)
                    self.netForces.append(netForce)

                    /// Initialize and add a force to the pointChargeObj for every neighbor
                    self.pointCharges.forEach{ otherPointChargeObj in
                        if pointChargeObj.id != otherPointChargeObj.id {
                            
//                            self.createSingleForce(from: otherPointChargeObj, to: pointChargeObj, netForce: netForce, arrowEntity: arrowEntity)
                            let singleForce = Force.createSingleForce(from: otherPointChargeObj, to: pointChargeObj)
                            netForce.forces.append(singleForce)
                        }
                    }
                }
            }
        }
    }
    
    func showForces(for pointChargeObj: PointChargeClass) {
//        self.netForces.forEach{ netForce in
//            /// Disable the NetForce Arrow ...
//            netForce.arrowEntity.isEnabled = false
//
//            netForce.forces.forEach{ force in
//                /// ... and the SingleForce Arrow for every PointChargeObj...
//                force.arrowEntity.isEnabled = false
//
//                if force.sourcePointCharge.id == pointChargeObj.id {
//                    /// ... except from the Arrow pointing to selectedPointChargeObj
//                    force.arrowEntity.isEnabled = true
//                }
//            }
//        }
//        
//        /// Enable the Arrows for the SingleForces and the NetForce of the selectedPointChargeObj
//        /// EXCEPT IF there are no other pointCharges, then there is no need for Arrows
//        if self.pointCharges.count > 1 {
//            pointChargeObj.entity.children.forEach{ child in
//                if child.name == "Pivot Arrow" {
//                    child.children.forEach{ child in
//                        if child.name == "NetForce Arrow" || child.name == "SingleForce Arrow" {
//                            child.isEnabled = true
//                        }
//                    }
//                }
//            }
//        }
        
        
        // NEW TRY
        self.toggleAllForces(show: false)
        pointChargeObj.netForce?.arrowEntity.isEnabled = true
        pointChargeObj.netForce?.forces.forEach{ force in
            force.arrowEntity.isEnabled = true
        }
        pointChargeObj.forcesOnOthers.forEach{ force in
            force.arrowEntity.isEnabled = true
        }
        
        
    }
        
    // MARK:- UPDATE FORCES
    
    func updateForces(reDraw: Bool = true) {
        
        self.netForces.forEach{ netForceObj in
            
            netForceObj.forces.forEach{ forceObj in
                forceObj.updateForce(reDraw: reDraw)
            }
            
            // Calculate Force Magnitude, Angle
            netForceObj.updateForce()
            
            // Update Net Force Arrow orientation
            netForceObj.updateForceArrowOrientation()
            
            // Update Net Force Arrow
            if (reDraw) {
                netForceObj.updateArrowModel()
            }
        }
        
        // RE-DRAW: Angle Overview View
        if abs(selectedForceAngleFloatValue.radiansToDegrees - previouslySelectedForceAngleFloatValue.radiansToDegrees) >= 1 {
//            print(previouslySelectedForceAngleFloatValue.radiansToDegrees, selectedForceAngleFloatValue.radiansToDegrees)

            self.viewController?.angleOverview.setNeedsDisplay()
        }
        self.viewController?.angleLabel.setNeedsDisplay()

        // Update Angle Overview angles
//        self.viewController?.angleOverview.updateAllForcesAngles(netForce: selectedPointChargeObj.netForce!)
    }
    
    func updateForces(for pointCharge: PointChargeClass, reDraw: Bool = true) {
        
        ///  Forces rendered on the pointCharge
        pointCharge.netForce?.forces.forEach{ force in
            force.updateForce(reDraw: reDraw)
        }
        /// Calculate Net Force Magnitude, Angle
        pointCharge.netForce?.updateForce()
        
        /// Update Net Force Arrow orientation
        pointCharge.netForce?.updateForceArrowOrientation()
        
        /// Update Net Force Arrow
        if (reDraw) {
            pointCharge.netForce?.updateArrowModel()
        }
        
        /// Forces rendered with respect to that pointCharge on others
        pointCharge.forcesOnOthers.forEach{ force in
            force.updateForce(reDraw: reDraw)
        }
        
        // RE-DRAW: Angle Overview View
        if abs(selectedForceAngleFloatValue.radiansToDegrees - previouslySelectedForceAngleFloatValue.radiansToDegrees) >= 1 {
//            print(previouslySelectedForceAngleFloatValue.radiansToDegrees, selectedForceAngleFloatValue.radiansToDegrees)
            self.viewController?.angleOverview.setNeedsDisplay()
        }
        self.viewController?.angleLabel.setNeedsDisplay()

        
        // Update Angle Overview angles
//        self.viewController?.angleOverview.updateAllForcesAngles(netForce: selectedPointChargeObj.netForce!)
    }
    
    // Recalculate all Forces (after point charge was added/removed)
    func reloadAllForces() {
        self.clearAllForces()
        self.addAllForces()
        
        /// Initialize again Angle Overview ForcesDrawings Dict
//        self.viewController?.angleOverview.updateForcesDrawings(netForce: selectedPointChargeObj.netForce!)
        /// Select a ForceDrawing
//        self.viewController?.angleOverview.selectForceDrawing(index: selectedPointChargeObj.netForce!.forceId)
        
        /// Update Forces (values, arrows, angles, etc...)
        self.updateForces()

    }
    
    func clearAllForces() {
        /// First clear all Arrow Entities from existing Forces Objects
        self.netForces.forEach{ netForce in
            netForce.forces.forEach{ force in
                force.arrowEntity.removeFromParent()
            }
            netForce.arrowEntity.removeFromParent()
        }
        
        /// Then delete All Forces Objects
        self.netForces.removeAll()
    }
    
    // Show or Hide all forces
    func toggleAllForces(show: Bool) {
        self.netForces.forEach{ netForce in
            netForce.forces.forEach{ force in
                force.arrowEntity.isEnabled = show
            }
            netForce.arrowEntity.isEnabled = show
        }
    }
    
    
    // MARK: - Private functions
    
//    private func createArrowEntity(for pointChargeObj: PointChargeClass, arrowEntity: Entity, name: String) -> Entity {
//    private func createArrowEntity(for pointChargeObj: PointChargeClass, name: String) -> Entity {
//        // TESTING 2
//        let arrowEntity = EntityStore.shared.load_ArrowBodyEntity(pointEntity: pointChargeObj.entity)
//        EntityStore.shared.load_ArrowHead(on: arrowEntity)
//
//        /// Initialize and add NetForce Arrow Entity to the pointChargeObj
////        let arrow = arrowEntity.clone(recursive: true)
//        let arrow = arrowEntity
//        arrow.name = name
//
//        /// Create an empty pivot entity
//        let pivotEntity: Entity = Entity()
//        pivotEntity.name = "Pivot Arrow"
//
//        /// Add the pivot entity as a direct PointCharge Entity child
//        pointChargeObj.entity.addChild(pivotEntity)
//        pivotEntity.setPosition(SIMD3<Float>(0,0,0), relativeTo: pointChargeObj.entity)
//
//        /// Make the pivot entity parent of the arrow
//        pivotEntity.addChild(arrow)
//        arrow.setPosition(SIMD3<Float>(0,0,0.05), relativeTo: pivotEntity)
//
//        /// Now, each time we want to rotate the arrow, we just have to rotate
//        /// its parent pivot point entity, EASIER
//
//        /// Disable the arrow Entity.
//        /// Later, the arrows relative to the selectedPointChargeObj will be enabled
//        arrow.isEnabled = false
//
//        return arrow
//    }
    
//    private func createNetForce(for pointChargeObj: PointChargeClass, arrowEntity: Entity) -> NetForce {
//        /// Create Arrow Entity and add it to the pointChargeObj
////        let arrow = createArrowEntity(for: pointChargeObj, arrowEntity: arrowEntity, name: "NetForce Arrow")
//        let arrow = createArrowEntity(for: pointChargeObj, name: "NetForce Arrow")
//
//        /// Initialize NetForce Object with Arrow Entity
//        let netForce = NetForce(magnitude: 0, angle: 0, arrowEntity: arrow ,point: pointChargeObj, forces: [])
//
//        /// Append it to netForces of topology. CAN BE DONE AFTER RETURN THOUGH.
//        self.netForces.append(netForce)
//
//        return netForce
//    }
//
//    private func createSingleForce(from otherPointChargeObj: PointChargeClass, to pointChargeObj: PointChargeClass, netForce: NetForce, arrowEntity: Entity){
//        /// Create Arrow Entity and add it to the pointChargeObj
////        let arrow = createArrowEntity(for: pointChargeObj, arrowEntity: arrowEntity, name: "SingleForce Arrow")
//        let arrow = createArrowEntity(for: pointChargeObj, name: "SingleForce Arrow")
//
//        /// Create instance of Force Object with arrow entity
//        let force = SingleForce(magnitude: 5, angle:0, arrowEntity: arrow, from: otherPointChargeObj, to: pointChargeObj)
//
//        /// Integrate Force Obj to the Net Force Obj of the PointChargeObj. CAN BE DONE AFTER RETURN THOUGH.
//        netForce.forces.append(force)
//    }
}
