//
//  PointCharge.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 30/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit

class PointChargeClass {
    static var volume: Int = 0
    let id: Int
    let entity: Entity
    var value: Float
    
    init(entity: Entity, value: Float) {
        PointChargeClass.volume += 1
        
        self.entity = entity
        self.id = PointChargeClass.volume
        self.value = value
    }
    
}
