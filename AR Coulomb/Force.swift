//
//  Force.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 18/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit

class Force {
    static var volume: Int = 0
    var forceId: Int = 0
    var magnetude: Float = 0.0
    var angle: Float = 0.0
    var length: Float = 0.05
    var arrowEntity: Entity = Entity()
    
    init(magnetude: Float, angle: Float, arrowEntity: Entity) {
        Force.volume += 1
        self.forceId = Force.volume
        self.magnetude = magnetude
        self.angle = angle
        self.arrowEntity = arrowEntity
    }
    
}
