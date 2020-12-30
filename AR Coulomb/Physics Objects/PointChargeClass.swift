//
//  PointCharge.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 30/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import RealityKit

class PointChargeClass {
    static var volume: Int = 0
    let id: Int
    let entity: Entity
    var value: Float
    static var multiplier: Float = 0.000001
    static var pointChargeRadius: Float = 0.02
    
    init(onEntity entity: Entity, withValue value: Float) {
        PointChargeClass.volume += 1
        
        self.id = PointChargeClass.volume
        self.entity = entity
        self.value = value
    }
    
    static func ==(lhs: PointChargeClass, rhs: PointChargeClass) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getPositionX() -> Float {
        return self.entity.position.x
    }
    
    func getPositionY() ->  Float{
        return self.entity.position.y
    }
    
    func getPositionZ() -> Float{
        return self.entity.position.z
    }
    
    
    
}
