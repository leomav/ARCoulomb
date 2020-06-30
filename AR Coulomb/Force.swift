//
//  Force.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 29/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit

class Force {
    static var volume: Int = 0
    let forceId: Int
    var magnetude: Float
    var length: Float = 0.05
    let entity: Entity
    var sourceEntity: Entity
    var targetEntity: Entity
    init(magnetude: Float, entity: Entity, from: Entity, to: Entity) {
        Force.volume += 1
        self.forceId = Force.volume
        self.magnetude = magnetude
        
        self.entity = entity
        self.sourceEntity = from
        self.targetEntity = to
    }
}
