//
//  TopologyModel.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 2/12/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import UIKit

class DefaultTopologyModel {
    var positions: [SIMD3<Float>]
    var image: Data
    var name: String
    var descr: String
    
    init(positions: [SIMD3<Float>], image: Data, name: String, description: String) {

        self.positions = positions
        self.image = image
        self.name = name
        self.descr = description
    }
}
