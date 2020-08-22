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



class NetForce {
    static var volume: Int = 0
    let forceId: Int
    var magnetude: Float
    var angle: Float
    var length: Float = 0.05
    let arrowEntity: Entity
    let pointChargeObj: PointChargeClass
    var forces: [SingleForce]
    init(magnetude: Float, angle: Float, arrowEntity: Entity, point: PointChargeClass, forces: [SingleForce]) {
        NetForce.volume += 1
        self.forceId = NetForce.volume
        self.magnetude = magnetude
        self.angle = angle
        self.pointChargeObj = point
        self.arrowEntity = arrowEntity
        self.forces = forces
        
        self.initializeArrowEntity()
    }
    
    // Gets called at the init() phase, sets the scale and position of the arrowEntity
    private func initializeArrowEntity() {
        self.arrowEntity.setScale(SIMD3<Float>(0.1, 0.1, 0.1), relativeTo: self.arrowEntity)
        self.arrowEntity.setPosition(SIMD3<Float>(0, 0, 0), relativeTo: self.pointChargeObj.entity)
    }
    
    // Update the ORIENTATION of the arrowEntity
    func updateNetForceArrow() {
        self.arrowEntity.setOrientation(simd_quatf(angle: self.angle, axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: self.pointChargeObj.entity)
    }
    
    // CALCULATE the net force
    // Analyze every force of the pointChargeObj to Fx, Fy components
    // Add all the Fx components, then all the Fy components
    // Finally, calculate the netforce between the sumFx, sumFy
    func calculateNetForce() {
        var netFx: Float = 0
        var netFy: Float = 0
        self.forces.forEach{ force in
            let fx: Float; let fy: Float
            (fx, fy) = self.calculateForceComponents(f: force.magnetude, f_angle: force.angle)
            netFx += fx
            netFy += fy
        }
        
        self.magnetude = self.netForceMagnetude(fx: netFx, fy: netFy)
        self.angle = self.netForceAngle(fx: netFx, fy: netFy)
    }
    
    // CALCULATE the Fx, Fy components of Force f with angle f_angle
    private func calculateForceComponents(f: Float, f_angle: Float) -> (Float, Float){
        let quarter = f_angle.radiansToDegrees / 90
        let f_angleMod = (f_angle.radiansToDegrees.truncatingRemainder(dividingBy: 90)).degreesToRadians

        let fx: Float
        let fy: Float
        
        if quarter < 1 {
            // 4th quarter
            fx = f * sin(f_angleMod)
            fy = -f * cos(f_angleMod)
        } else if quarter < 2 {
            // 1st quarter
            fx = f * cos(f_angleMod)
            fy = f * sin(f_angleMod)
        } else if quarter < 3 {
            // 2nd quarter
            fx = -f * sin(f_angleMod)
            fy = f * cos(f_angleMod)
        } else {
            // 3rd quarter
            fx = -f * cos(f_angleMod)
            fy = -f * sin(f_angleMod)
            //
            
            
            //if self.forceId == 3 {
            //    print("components: " + String(fx) + ", " + String(fy))
            //}
        }
        return (fx, fy)
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
            //
            
            
            //if self.forceId == 3 {
            //    print("netFy: " + String(fy) + ", /netFx: " + String(fx))
            //}
            
            
            return Float(270.degreesToRadians) + atan(-fy / -fx)
            
        } else if fx >= 0 && fy <= 0 {
            // 4th quarter
            return atan(fx / -fy)
        } else {
            return 0
        }
    }
    
}
