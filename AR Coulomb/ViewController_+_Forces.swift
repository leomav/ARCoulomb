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
    func addForces() {
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
                    let netForce = NetForce(magnetude: 0, angle: 0, arrowEntity: arrow ,pointEntity: pointChargeObj.entity, forces: [])
                    netForces.append(netForce)
                    
                    // Initialize and add a force to the pointChargeObj for every neighbor
                    pointCharges.forEach{ otherPointChargeObj in
                        if pointChargeObj.id != otherPointChargeObj.id {
                            
                            let arrow = arrowEntity.clone(recursive: true)
                            arrow.name = "Force Arrow"
                            pointChargeObj.entity.addChild(arrow)
                            
                            // Create instance of Force with arrow entity
                            let force = SingleForce(magnetude: 5, angle:0, arrowEntity: arrow, from: otherPointChargeObj.entity, to: pointChargeObj.entity)
                            
                            // Integrate force to the net force of the object
                            netForce.forces.append(force)
                        }
                    }
                }
                updateArrows()
            }
        }
    }
    
    
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Update FORCES ARROWS ---------------------------------
    func updateArrows() {
        netForces.forEach{ netForceObj in
            netForceObj.forces.forEach{ forceObj in
//                let from = forceObj.sourceEntity
//                let at = forceObj.targetEntity
//                let arrow = forceObj.arrowEntity
//
//                /// First set look(at:_) cause it reinitialize the scale. Then set the scale x 0.1 and the position again
//                /// to the center of the pointCharge.
//                /// CAREFUL: The arrow entity points with its tail, so reverse the look direction to get what you want
//                arrow.look(at: from.position, from: at.position, relativeTo: at)
//                arrow.setScale(SIMD3<Float>(0.05, 0.05, 0.05), relativeTo: arrow)
//                arrow.setPosition(SIMD3<Float>(0, 0, 0), relativeTo: at)
//                // MARK: - ORIENTATION
//                // If you want the arrows to look to the other coulomb insted of looking away
//                // add the following line so that it reverses its orientation
//                // : arrow.setOrientation(simd_quatf(angle: 180.degreesToRadians(), axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: arrow)
//
//                // Update forces' angles
//                // MARK: - EXPLANATION
//                // The orientation(relativeTo: ) function returns the simd_quatf. We take the
//                // angle (radians) of it.
//                // If the angle is <90 or >270 the angle returns the same (<90 form). For example
//                // if the angle is 300, 60 will be returned. So there is no way
//                // to know which case is true. Except from one, if we take also the imag.y part of
//                // the simd_quatf. Then if y is > 0 --> <90 is true, else if y <0 --> >270 is true.
//                let orientation = arrow.orientation(relativeTo: arrow.parent)
//                if orientation.imag.y >= 0 {
//                    forceObj.angle = orientation.angle
//                } else {
//                    forceObj.angle = Float(360).degreesToRadians - orientation.angle
//                }
                forceObj.updateForceArrow()
                forceObj.updateForceAngle()
            }
            netForceObj.calculateNetForce()
            
            // Update netForce arrow angle
//            let arrow = netForceObj.arrowEntity
//            arrow.setOrientation(simd_quatf(angle: netForceObj.angle, axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: trackedEntity)
            netForceObj.updateNetForceArrow()
        }
    }
}
