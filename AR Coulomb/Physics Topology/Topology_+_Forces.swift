//
//  ViewController_+_Forces.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 18/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import RealityKit

extension Topology {
    
    // ---------------------------------------------------------------------------------
    // -------------------------- Add FORCE (Obj & Entity) -----------------------------
    func addAllForces() {
        self.viewController?.arView.scene.anchors.forEach{ anchor in
            if anchor.name == "Point Charge Scene AnchorEntity" {
                
                /// Get the ArrowEntity out of the ArrowAnchor
                let arrowAnchor = try! Experience.loadBox()
                let arrowEntity = arrowAnchor.arrow!
                
                // TESTING TESTING TESTING TESTING TESTING
                /// Comment out the above two lines of code
                
                // Add a Force Object and Entity for every pointCharge<->pointCharge combo
                self.pointCharges.forEach{ pointChargeObj in
                    
                    /// Create NetForce Object
                    let netForce = self.createNetForce(for: pointChargeObj, arrowEntity: arrowEntity)
                    
                    /// Initialize and add a force to the pointChargeObj for every neighbor
                    self.pointCharges.forEach{ otherPointChargeObj in
                        if pointChargeObj.id != otherPointChargeObj.id {
                            
                            self.createSingleForce(from: otherPointChargeObj, to: pointChargeObj, netForce: netForce, arrowEntity: arrowEntity)
                        }
                    }
                }
                self.updateForces()
            }
        }
    }
    
    func showForces(for pointChargeObj: PointChargeClass) {
        self.netForces.forEach{ netForce in
            /// Disable the NetForce Arrow ...
            netForce.arrowEntity.isEnabled = false
            
            netForce.forces.forEach{ force in
                /// ... and the SingleForce Arrow for every PointChargeObj...
                force.arrowEntity.isEnabled = false
                
                if force.sourcePointCharge.id == pointChargeObj.id {
                    /// ... except from the Arrow pointing to selectedPointChargeObj
                    force.arrowEntity.isEnabled = true
                }
            }
        }
        
        /// Enable the Arrows for the SingleForces and the NetForce of the selectedPointChargeObj
        /// EXCEPT IF there are no other pointCharges, then there is no need for Arrows
        if self.pointCharges.count > 1 {
            pointChargeObj.entity.children.forEach{ child in
                if child.name == "NetForce Arrow" || child.name == "SingleForce Arrow" {
                    child.isEnabled = true
                }
            }
        }
    }
        
    // ---------------------------------------------------------------------------------
    // -------------------------- Update FORCES ----------------------------------------
    func updateForces() {
        self.netForces.forEach{ netForceObj in
            
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
    
    // Recalculate all Forces (after point charge was added/removed)
    func reloadAllForces() {
        self.clearAllForces()
        self.addAllForces()
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
    private func createArrowEntity(for pointChargeObj: PointChargeClass, name: String) -> Entity {
        // TESTING below lines
        let arrowEntity = SingleForce.loadArrowBody(pointEntity: pointChargeObj.entity)
        let arrowHeadAnchor = try! ArrowHead.load_ArrowHead()
        let arrowHeadEntity = arrowHeadAnchor.arrowHead
        arrowHeadEntity?.setParent(arrowEntity)
        arrowHeadEntity?.setScale(SIMD3<Float>(0.1,0.1,0.1), relativeTo: arrowHeadEntity)
        arrowHeadEntity?.setPosition(SIMD3<Float>(0.04,0,0), relativeTo: arrowEntity)
        arrowHeadEntity?.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: arrowEntity)
//        arrowHeadEntity?.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(0, 0, 0)), relativeTo: arrowEntity)

        /// Initialize and add NetForce Arrow Entity to the pointChargeObj
        let arrow = arrowEntity.clone(recursive: true)
//        arrow.name = name
        pointChargeObj.entity.addChild(arrow)
        
        /// Disable the arrow Entity.
        /// Later, the arrows relative to the selectedPointChargeObj will be enabled
        arrow.isEnabled = false
        
        return arrow
    }
    
    private func createNetForce(for pointChargeObj: PointChargeClass, arrowEntity: Entity) -> NetForce {
        /// Create Arrow Entity and add it to the pointChargeObj
//        let arrow = createArrowEntity(for: pointChargeObj, arrowEntity: arrowEntity, name: "NetForce Arrow")
        let arrow = createArrowEntity(for: pointChargeObj, name: "NetForce Arrow")

        /// Initialize NetForce Object with Arrow Entity
        let netForce = NetForce(magnetude: 0, angle: 0, arrowEntity: arrow ,point: pointChargeObj, forces: [])
        self.netForces.append(netForce)
        
        return netForce
    }
    
    private func createSingleForce(from otherPointChargeObj: PointChargeClass, to pointChargeObj: PointChargeClass, netForce: NetForce, arrowEntity: Entity){
        /// Create Arrow Entity and add it to the pointChargeObj
//        let arrow = createArrowEntity(for: pointChargeObj, arrowEntity: arrowEntity, name: "SingleForce Arrow")
        let arrow = createArrowEntity(for: pointChargeObj, name: "SingleForce Arrow")

        /// Create instance of Force Object with arrow entity
        let force = SingleForce(magnetude: 5, angle:0, arrowEntity: arrow, from: otherPointChargeObj, to: pointChargeObj)
        
        /// Integrate Force Obj to the Net Force Obj of the PointChargeObj
        netForce.forces.append(force)
    }
}
