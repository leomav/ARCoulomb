//
//  DefaultPositions.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 2/12/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit


//let defaultPositions: [[SIMD3<Float>]] = [
//    [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0.1, 0, 0)],
//    [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)],
//    [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1)],
//    [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)],
//    [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0.1, 0, 0)],
//    [SIMD3<Float>(-0.2, 0, 0.1), SIMD3<Float>(0, 0, 0.1), SIMD3<Float>(0, 0, -0.1), SIMD3<Float>(0.2, 0, 0.1)]
//]


let defaultTopologies: [DefaultTopologyModel] = [
    DefaultTopologyModel(positions: [SIMD3<Float>(0, 0, 0)], image: (UIImage(named: "Single_Point")?.pngData())!, name: "Default: Create New", description: "Create a new topology"),
    DefaultTopologyModel(positions: [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0.1, 0, 0)], image: (UIImage(named: "Two_Points")?.pngData())!, name: "Default: Two Points", description: "Simple 2 points of charge topology"),
    DefaultTopologyModel(positions: [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)], image: (UIImage(named: "Three_Points_UpRightGamma")?.pngData())!, name: "Default: Three Points (1)", description: "Gama(up-right) 3 points of charge topology"),
    DefaultTopologyModel(positions: [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1)], image: (UIImage(named: "Three_Points_UpLeftGamma")?.pngData())!, name: "Default: Three Points (2)", description: "Gama(up-left) 3 points of charge topology"),
    DefaultTopologyModel(positions: [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0.1, 0, 0)], image: (UIImage(named: "Three_Points_Line")?.pngData())!, name: "Default: Three Points (3) 5", description: "Line 3 points of charge topology"),
    DefaultTopologyModel(positions: [SIMD3<Float>(-0.1, 0, 0.1), SIMD3<Float>(-0.1, 0, -0.1), SIMD3<Float>(0.1, 0, 0.1), SIMD3<Float>(0.1, 0, -0.1)], image: (UIImage(named: "Four_Points_Square")?.pngData())!, name: "Default: Four Points ()1", description: "Square 4 points of charge topology"),
    DefaultTopologyModel(positions: [SIMD3<Float>(-0.1, 0, 0), SIMD3<Float>(0, 0, 0), SIMD3<Float>(0, 0, -0.1), SIMD3<Float>(0.1, 0, 0)], image: (UIImage(named: "Four_Points")?.pngData())!, name: "Default: Four Points (2)", description: "Reverse-T 4 points of charge topology")
]


