//
//  DefaultPositions.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 2/12/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation


let defaultPositions: [[SIMD3<Float>]] = [
    [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0.1, 0, 0)],
    [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)],
    [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1)],
    [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)],
    [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0.1, 0, 0)],
    [SIMD3<Float>(-0.2, 0, 0.1), SIMD3<Float>(0, 0, 0.1), SIMD3<Float>(0, 0, -0.1), SIMD3<Float>(0.2, 0, 0.1)]
]
