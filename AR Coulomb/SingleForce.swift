//
//  Force.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 29/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit

/// forceId:    Id of the netforce entity
/// magnetude:  Force Magnetude (Newtons)
/// angle:      Angle (rads) of the force (arrowEntity) relativily to the pointChargeEntity (target)
/// length:     Length of the arrow entity
/// arrowEntity:    The Arrow Entity of the force
/// sourceEntity:      The source of the force coming to this pointChargeEntity
/// targetEntity:     This pointChargeEntity

class SingleForce {
    static var volume: Int = 0
    let forceId: Int
    var magnetude: Float
    var angle: Float
    var length: Float = 0.05
    let arrowEntity: Entity
    var sourceEntity: Entity
    var targetEntity: Entity
    init(magnetude: Float, angle: Float, arrowEntity: Entity, from: Entity, to: Entity) {
        SingleForce.volume += 1
        self.forceId = SingleForce.volume
        self.magnetude = magnetude
        self.angle = angle
        self.arrowEntity = arrowEntity
        self.sourceEntity = from
        self.targetEntity = to
    }
}
