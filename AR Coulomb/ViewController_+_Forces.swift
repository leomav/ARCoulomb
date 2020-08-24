//
//  ViewController_+_Forces.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 18/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import RealityKit

extension ViewController {
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Add FORCE (Obj & Entity) -----------------------------
    func addAllForces() {
        arView.scene.anchors.forEach{ anchor in
            if anchor.name == "Point Charge Scene AnchorEntity" {
                
                /// Get the ArrowEntity out of the ArrowAnchor
                let arrowAnchor = try! Experience.loadBox()
                let arrowEntity = arrowAnchor.arrow!
                
                // Add a Force Object and Entity for every pointCharge<->pointCharge combo
                topology?.pointCharges.forEach{ pointChargeObj in
                    
                    /// Create NetForce Object
                    let netForce = createNetForce(for: pointChargeObj, arrowEntity: arrowEntity)
                    
                    /// Initialize and add a force to the pointChargeObj for every neighbor
                    topology?.pointCharges.forEach{ otherPointChargeObj in
                        if pointChargeObj.id != otherPointChargeObj.id {
                            
                            createSingleForce(from: otherPointChargeObj, to: pointChargeObj, netForce: netForce, arrowEntity: arrowEntity)
                        }
                    }
                }
                updateForces()
            }
        }
    }
    
    private func createArrowEntity(for pointChargeObj: PointChargeClass, arrowEntity: Entity) -> Entity {
        /// Initialize and add NetForce Arrow Entity to the pointChargeObj
        let arrow = arrowEntity.clone(recursive: true)
        arrow.name = "NetForce Arrow"
        pointChargeObj.entity.addChild(arrow)
        
        return arrow
    }
    
    private func createNetForce(for pointChargeObj: PointChargeClass, arrowEntity: Entity) -> NetForce {
        /// Create Arrow Entity and add it to the pointChargeObj
        let arrow = createArrowEntity(for: pointChargeObj, arrowEntity: arrowEntity)
        
        /// Initialize NetForce Object with Arrow Entity
        let netForce = NetForce(magnetude: 0, angle: 0, arrowEntity: arrow ,point: pointChargeObj, forces: [])
        topology?.netForces.append(netForce)
        
        return netForce
    }
    
    private func createSingleForce(from otherPointChargeObj: PointChargeClass, to pointChargeObj: PointChargeClass, netForce: NetForce, arrowEntity: Entity){
        /// Create Arrow Entity and add it to the pointChargeObj
        let arrow = createArrowEntity(for: pointChargeObj, arrowEntity: arrowEntity)
        
        /// Create instance of Force Object with arrow entity
        let force = SingleForce(magnetude: 5, angle:0, arrowEntity: arrow, from: otherPointChargeObj, to: pointChargeObj)
        
        /// Integrate Force Obj to the Net Force Obj of the PointChargeObj
        netForce.forces.append(force)
    }
        
    
    func clearAllForces() {
        
    }
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Update FORCES ARROWS ---------------------------------
    func updateForces() {
        topology?.netForces.forEach{ netForceObj in
            netForceObj.forces.forEach{ forceObj in
                forceObj.updateForceArrow()
                forceObj.updateForceAngle()
                forceObj.updateForceMagnetude()
            }
            netForceObj.calculateNetForce()
            
            // Update Net Force Arrow orientation
            netForceObj.updateNetForceArrow()
        }
    }
}
