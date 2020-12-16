//
//  Force.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 29/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit
import UIKit

/// forceId:    Id of the netforce entity
/// magnetude:  Force Magnetude (Newtons)
/// angle:      Angle (rads) of the force (arrowEntity) relativily to the pointChargeEntity (target)
/// length:     Length of the arrow entity
/// arrowEntity:    The Arrow Entity of the force
/// sourcePointCharge:      The source PointChargeClass object  which the force is coming from
/// targetPointCharge:     This PointChargeClass host object

class SingleForce {
    static var volume: Int = 0
    let forceId: Int
    var magnetude: Float
    var angle: Float
    var length: Float = 0.05
    let metersPerNewton: Float = 0.01
    
    /// Attraction computed property
    var attraction: Bool {
        let attraction: Bool
        
        /// Set the attraction:
        /// true: heteronyms -> lure eachother
        /// false: homonyms
        if self.sourcePointCharge.value * self.targetPointCharge.value < 0 {
            attraction = true
        } else {
            attraction = false
        }
        
        return attraction
    }
    
    var pivotEntity: Entity
    var arrowEntity: Entity
    var sourcePointCharge: PointChargeClass
    var targetPointCharge: PointChargeClass
    init(magnetude: Float, angle: Float, arrowEntity: Entity, from: PointChargeClass, to: PointChargeClass) {
        SingleForce.volume += 1
        
        self.forceId = SingleForce.volume
        self.magnetude = magnetude
        self.angle = angle
        
        /// SourcePointCharge: the pc the arrow shows to
        self.sourcePointCharge = from
        /// TargetPointCharge: the pc the arrow is drawn on to
        self.targetPointCharge = to
        
        /// Set the arrowEntity and its parent the pivotEntity
        /// Pivot entity is used to rotate the arrowEntity
        self.arrowEntity = arrowEntity
        self.pivotEntity = arrowEntity.parent!
        
    }
    
    func updateForceArrow() {
        /// - Tag: The next 2 comment lines do not apply anymore (look(at: _) initializing scale
        // First set look(at:_) cause it reinitialize the scale. Then set the scale x 0.05 and the position again
        // to the center of the pointCharge.
        
        /// - Tag:  CAREFUL: The arrow entity points with its tail, so REVERSE the look DIRECTION to get what you want
        // TESTING
        /// Tested that the following parameters was the only way to work :(.
        self.pivotEntity.look(at: self.sourcePointCharge.entity.position, from: self.targetPointCharge.entity.position, relativeTo: self.targetPointCharge.entity.parent)

        /// - Tag:  ORIENTATION: Look TO or AWAY ?
        // If you want the arrows to look to the other coulomb instead of looking away
        // add the following line so that it reverses its direction
        if self.attraction {
            self.pivotEntity.setOrientation(simd_quatf(angle: 180.degreesToRadians(), axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: self.pivotEntity)
        }
        
        
    }
    
    func updateForceAngle() {
        // Update forces' angles
        // MARK: - EXPLANATION
        // The orientation(relativeTo: ) function returns the simd_quatf. We take the
        // angle (radians) of it.
        // If the angle is <90 or >270 the angle returns the same (<90 form). For example
        // if the angle is 300, 60 will be returned. So there is no way
        // to know which case is true. Except from one, if we take also the imag.y part of
        // the simd_quatf. Then if y is > 0 --> <90 is true, else if y < 0 --> >270 is true.
        
        // TESTING
//        let orientation = self.arrowEntity.orientation(relativeTo: self.arrowEntity.parent)
//        if orientation.imag.y >= 0 {
//            self.angle = orientation.angle
//        } else {
//            self.angle = Float(360).degreesToRadians - orientation.angle
//            // *** FIXED BUG: angle was too close to 0 that the above made rounded up to 360
//            // So if angle is set to 360, reset it to 0.
//            if self.angle.radiansToDegrees == 360 {
//                self.angle = 0
//            }
//        }
        let orientation = self.pivotEntity.orientation(relativeTo: self.pivotEntity.parent)
        
        if orientation.imag.y >= 0 {
            self.angle = orientation.angle
        } else {
            self.angle = Float(360).degreesToRadians - orientation.angle
            // *** FIXED BUG: angle was too close to 0 that the above made rounded up to 360
            // So if angle is set to 360, reset it to 0.
            if self.angle.radiansToDegrees == 360 {
                self.angle = 0
            }
        }
    }
    
    func updateForceMagnetude(){
        self.magnetude = self.coulombsLaw()
    }
    
    private func coulombsLaw() -> Float{
        let coulombsProduct = self.sourcePointCharge.value * self.sourcePointCharge.multiplier * self.targetPointCharge.value * self.targetPointCharge.multiplier
        let distance = twoPointsDistance(x1: sourcePointCharge.entity.position.x,
                                         x2: targetPointCharge.entity.position.x,
                                         y1: sourcePointCharge.entity.position.z,
                                         y2: targetPointCharge.entity.position.z)
        let distance_pow = distance * distance
        let constant = Ke / distance_pow
        return constant * coulombsProduct
    }
    
    private func twoPointsDistance(x1: Float, x2: Float, y1: Float, y2: Float) -> Float {
        let distance: Float
        distance = sqrt(pow(x2-x1, 2) + pow(y2-y1, 2))
        return distance
    }
    
}
