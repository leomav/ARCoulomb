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
/// entity:      pointChargeEntity
/// forces:     An array of the forces that the netforce is constructed from

class NetForce {
    static var volume: Int = 0
    let forceId: Int
    var magnetude: Float
    var angle: Float
    var length: Float = 0.05
     let arrowEntity: Entity
    let pointEntity: Entity
    var forces: [SingleForce]
    init(magnetude: Float, angle: Float, arrowEntity: Entity, pointEntity: Entity, forces: [SingleForce]) {
        NetForce.volume += 1
        self.forceId = NetForce.volume
        self.magnetude = magnetude
        self.angle = angle
        self.pointEntity = pointEntity
        self.arrowEntity = arrowEntity
        self.forces = forces
    }
    
    func calculate() {
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
        
        print(f1, f1_angle)
        
    }
    
    // Always f1 as the reference force
    func netForceOfTwo(f1: Float, f1_angle: Float, f2: Float, f2_angle: Float) -> (Float, Float) {
        let angle: Float
        if f1_angle <= f2_angle {
            angle = f2_angle - f1_angle
        } else {
            
            angle = Float(360).degreesToRadians + f2_angle - f1_angle
        }
        
        let netMagnetude = netForceMagnetude(f1: f1, f2: f2, angle: angle)
        let netAngle = netForceAngle(f1: f1, f2: f2, angle: angle)
        
        return (netMagnetude, netAngle)
    }
    
    private func netForceMagnetude(f1: Float, f2: Float, angle: Float) -> Float {
        return sqrt(f1*f1 + f2*f2 + 2*f1*f2*cos(angle))
    }
    
    private func netForceAngle(f1: Float, f2: Float, angle: Float) -> Float {
        return atan((f2 * sin(angle)) / (f1 + f2 * cos(angle)))
    }
    
}
