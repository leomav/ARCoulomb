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
        
        let arrowEntity = Force.createArrowEntity(on: self.pointChargeObj, magnetude: magnetude, name: "NetForce Arrow")

        super.init(magnetude: magnetude, angle: angle, arrowEntity: arrowEntity)
    }
    
    static func createForce(for pointChargeObj: PointChargeClass) -> NetForce {

        /// Initialize NetForce Object with Arrow Entity
        let netForce = NetForce(magnetude: 0, angle: 0, point: pointChargeObj, forces: [])
        
        /// Append it to netForces of topology. CAN BE DONE AFTER RETURN THOUGH.
//        self.netForces.append(netForce)
        
        return netForce
    }
    
    // Gets called at the init() phase, sets the scale and position of the arrowEntity
//    private func initializeArrowEntity() {
////        self.arrowEntity.setPosition(SIMD3<Float>(0, 0, 0), relativeTo: self.pointChargeObj.entity)
//    }
    
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
//        let fx = X_Force_Component; let fy  = Y_Force_Component
//
//        self.magnetude = self.netForceMagnetude(fx: fx, fy: fy)
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
        
        /// Instead of that, use the following netForceMagnetude function.
//        self.updateForceMagnetude()
        
        /// When magnetude gets updated, the Fx, Fy components will be updated also...
        self.magnetude = self.netForceMagnetude(fx: netFx, fy: netFy)
        /// ... and will be ready for use in updateForceAngle()
        self.updateForceAngle()
        
//        self.magnetude = self.netForceMagnetude(fx: netFx, fy: netFy)
//        self.angle = self.netForceAngle(fx: netFx, fy: netFy)
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
    
    // CALCULATE the Fx, Fy components of Force f with angle f_angle
//    private func calculateForceComponents(f: Float, f_angle: Float) -> (Float, Float){
//        let quarter = f_angle.radiansToDegrees / 90
//        let f_angleMod = (f_angle.radiansToDegrees.truncatingRemainder(dividingBy: 90)).degreesToRadians
//
//        let fx: Float
//        let fy: Float
//
//        /// To calculate correctly the Fx, Fy components, the Force Magnetude
//        /// has to have its ABSOLUTE VALUE
//        /// Thankfully, it is saved that way in the SingleForce Object
//
//        if quarter < 1 {
//            // 4th quarter
//            fx = f * sin(f_angleMod)
//            fy = -f * cos(f_angleMod)
//        } else if quarter < 2 {
//            // 1st quarter
//            fx = f * cos(f_angleMod)
//            fy = f * sin(f_angleMod)
//        } else if quarter < 3 {
//            // 2nd quarter
//            fx = -f * sin(f_angleMod)
//            fy = f * cos(f_angleMod)
//        } else {
//            // 3rd quarter
//            fx = -f * cos(f_angleMod)
//            fy = -f * sin(f_angleMod)
//            //
//        }
//        return (fx, fy)
//    }
    
   
    
}
