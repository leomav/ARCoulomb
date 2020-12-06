//
//  TopologyModel.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 2/12/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation

class PointChargeModel {
    var position: SIMD3<Float>
    var value: Float
    var multiplier:Float = 0.000001
    
    init(position: SIMD3<Float>, value: Float) {
        self.position = position
        self.value = value
    }
    
    // MARK: - Getters and setters
    
    func setPosition (position: SIMD3<Float>) {
        self.position = position
    }
    
    func getPosition () -> SIMD3<Float> {
        return self.position
    }
    
    func setValue(value: Float) {
        self.value = value
    }
    
    func getImage() -> Float {
        return self.value
    }
    
    func setMultiplier(value: Float) {
        self.multiplier = value
    }
    
    func getMultiplier() -> Float {
        return self.multiplier
    }
}
