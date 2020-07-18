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
    func calculateNetForce() {
        var (f1, f1_angle) = (self.forces[0].magnetude, self.forces[0].angle)
        var iterator = 1
        while iterator < self.forces.count {
            let (f2, f2_angle) = (self.forces[iterator].magnetude, self.forces[iterator].angle)
            let (temp, temp_angle) = netForceOfTwo(f1: f1, f1_angle: f1_angle, f2: f2, f2_angle: f2_angle)
            f1 = temp; f1_angle = temp_angle
            
            iterator += 1
        }
        self.magnetude = f1
        self.angle = f1_angle
        
    }
    
    // Input: 2 forces' magnetudes and angles
    // Set as reference force the one with the smaller angle
    // Then proceed to finding the netForceMagnetude and netForceAngle.
    // CAREFUL: Don't forget to add the reference force's angle to the resulted netForceAngle.
    private func netForceOfTwo(f1: Float, f1_angle: Float, f2: Float, f2_angle: Float) -> (Float, Float) {
        let angle: Float
        let netMagnetude: Float
        let netAngle: Float
        if f1_angle <= f2_angle {
            angle = f2_angle - f1_angle
            netMagnetude = netForceMagnetude(f1: f1, f2: f2, angle: angle)
            netAngle = netForceAngle(f1: f1, f2: f2, angle: angle) + f1_angle
        } else {
            angle = f1_angle - f2_angle
            netMagnetude = netForceMagnetude(f1: f2, f2: f1, angle: angle)
            netAngle = netForceAngle(f1: f2, f2: f1, angle: angle) + f2_angle
        }
        return (netMagnetude, netAngle)
    }
    
    private func netForceMagnetude(f1: Float, f2: Float, angle: Float) -> Float {
        return sqrt(f1*f1 + f2*f2 + 2*f1*f2*cos(angle))
    }
    
    private func netForceAngle(f1: Float, f2: Float, angle: Float) -> Float {
        return atan((f2 * sin(angle)) / (f1 + f2 * cos(angle)))
    }
    
}
