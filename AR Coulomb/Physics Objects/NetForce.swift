//
//  NetForce.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 14/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit

/// forceId:    Id of the netforce entity
/// magnetude:  Force Magnetude (Newtons)
/// angle:      Angle (rads) of the force (arrowEntity) relativily to the pointEntity
/// length:     Length of the arrow entity
/// arrowEntity:    The Arrow Entity of the force
/// pointChargeObj:      The PointChargeClass host object
/// forces:     An array of the forces that the netforce is constructed from



class NetForce: Force {
    static var netForcesTotal: Int = 0
    let netForceId: Int
    let pointChargeObj: PointChargeClass
    var forces: [SingleForce]
    
//    init(magnetude: Float, angle: Float, arrowEntity: Entity, point: PointChargeClass, forces: [SingleForce]) {
    init(magnetude: Float, angle: Float, point: PointChargeClass, forces: [SingleForce]) {
        NetForce.netForcesTotal += 1
        self.netForceId = NetForce.netForcesTotal
        
        self.pointChargeObj = point
        
        self.forces = forces
        
        let arrowEntity = Force.createArrowModel(on: self.pointChargeObj, magnetude: magnetude, name: "NetForce Arrow")

        super.init(magnetude: magnetude, angle: angle, arrowEntity: arrowEntity)
    }
    
    static func createForce(for pointChargeObj: PointChargeClass) -> NetForce {

        /// Initialize NetForce Object with Arrow Entity
        let netForce = NetForce(magnetude: 0, angle: 0, point: pointChargeObj, forces: [])
        
        return netForce
    }
    
    
    // Update Net Force
    func updateForce() {
        self.calculateNetForce()
        
//        self.updateArrowModel()
    }
    
    // Update the ORIENTATION of the arrowEntity
    override func updateForceArrowOrientation() {
        self.pivotEntity.setOrientation(simd_quatf(angle: self.angle, axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: self.pointChargeObj.entity)
//        self.arrowEntity.setOrientation(simd_quatf(angle: self.angle, axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: self.pointChargeObj.entity)
    }
    
    override func updateForceAngle() {
        //
        let fx = X_Force_Component; let fy = Y_Force_Component
        
        self.angle = self.netForceAngle(fx: fx, fy: fy)
    }
    
    override func updateForceMagnetude() {
        //
    }
    
    // CALCULATE the Net Force
    // Analyze every force of the pointChargeObj to Fx, Fy components
    // Add all the Fx components, then all the Fy components
    // Finally, calculate the netforce between the sumFx, sumFy
    func calculateNetForce() {
        var netFx: Float = 0
        var netFy: Float = 0
        
        self.forces.forEach{ force in
//            let fx: Float; let fy: Float
//            (fx, fy) = self.calculateForceComponents(f: force.magnetude, f_angle: force.angle)
//            netFx += fx
//            netFy += fy
            
            netFx += force.X_Force_Component
            netFy += force.Y_Force_Component
            
        }
        
        /// - Tag: CAREFUL
        /// DON'T USE:  <updateForceMagnetude()> and <updateForceAngle()>
        /// They use X_Force_Component, Y_Force_Component which are not correctly
        /// evaluated until the magnetude and angle are calculated.
        ///
        /// Use  the following instead, which take as args the netFx, netFy calculated above.
        self.magnetude = self.netForceMagnetude(fx: netFx, fy: netFy)
        self.angle = self.netForceAngle(fx: netFx, fy: netFy)
    }
    
    private func netForceMagnetude(fx: Float, fy: Float) -> Float {
        return sqrt(fx*fx + fy*fy)
    }
    
    
    private func netForceAngle(fx: Float, fy: Float) -> Float {
        if fx >= 0 && fy >= 0 {
            // 1st quarter
            return Float(90.degreesToRadians) + atan(fy / fx)
        } else if fx <= 0 && fy >= 0 {
            // 2nd quarter
            return Float(180.degreesToRadians) + atan(-fx / fy)
        } else if fx <= 0 && fy <= 0 {
            // 3rd quarter
            return Float(270.degreesToRadians) + atan(-fy / -fx)
            
        } else if fx >= 0 && fy <= 0 {
            // 4th quarter
            return atan(fx / -fy)
        } else {
            return 0
        }
    }
}
