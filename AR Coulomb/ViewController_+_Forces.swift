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
                
                let arrowAnchor = try! Experience.loadBox()
                let arrowEntity = arrowAnchor.arrow!
                
                // Add a Force Object and Entity for every pointCharge<->pointCharge combo
                pointCharges.forEach{ pointChargeObj in
                    // Initialize and add net force arrow to the pointChargeObj
                    let arrow = arrowEntity.clone(recursive: true)
                    arrow.name = "NetForce Arrow"
                    pointChargeObj.entity.addChild(arrow)
                    // Initialize net force
                    let netForce = NetForce(magnetude: 0, angle: 0, arrowEntity: arrow ,point: pointChargeObj, forces: [])
                    netForces.append(netForce)
                    
                    // Initialize and add a force to the pointChargeObj for every neighbor
                    pointCharges.forEach{ otherPointChargeObj in
                        if pointChargeObj.id != otherPointChargeObj.id {
                            
                            let arrow = arrowEntity.clone(recursive: true)
                            arrow.name = "Force Arrow"
                            pointChargeObj.entity.addChild(arrow)
                            
                            // Create instance of Force with arrow entity
                            let force = SingleForce(magnetude: 5, angle:0, arrowEntity: arrow, from: otherPointChargeObj, to: pointChargeObj)
                            
                            // Integrate force to the net force of the object
                            netForce.forces.append(force)
                        }
                    }
                }
                updateForces()
            }
        }
    }
    
    
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Update FORCES ARROWS ---------------------------------
    func updateForces() {
        netForces.forEach{ netForceObj in
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
