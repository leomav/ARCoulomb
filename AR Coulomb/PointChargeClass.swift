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
    var multiplier: Float = 0.000001
    
    init(onEntity entity: Entity, withValue value: Float) {
        PointChargeClass.volume += 1
        
        self.id = PointChargeClass.volume
        self.entity = entity
        self.value = value
    }
    
    // MARK: - Text Entity
    
    func createTextEntity(pointEntity: Entity) -> Entity {
        let textEntity: Entity = Entity()
        textEntity.name = "text"
        textEntity.setParent(pointEntity)
        // textEntity.setPosition(SIMD3<Float>(-0.02, -0.03, 0.03), relativeTo: pointEntity)
        // textEntity.setOrientation(simd_quatf(ix: -0.45, iy: 0, iz: 0, r: 0.9), relativeTo: pointEntity)
        textEntity.setPosition(SIMD3<Float>(-0.02, -0.03, 0), relativeTo: pointEntity)
        textEntity.setOrientation(simd_quatf(angle: Int(90).degreesToRadians(), axis: SIMD3<Float>(1, 0, 0)), relativeTo: pointEntity)

        return textEntity
    }
    
    static func loadText(textEntity: Entity, material: SimpleMaterial, coulombStringValue: String) {
        let model: ModelComponent = ModelComponent(mesh: .generateText(coulombStringValue,
                                                                       extrusionDepth: 0.003,
                                                                       font: .systemFont(ofSize: 0.02),
                                                                       containerFrame: CGRect.zero,
                                                                       alignment: .left,
                                                                       lineBreakMode: .byCharWrapping),
                                                   materials: [material])
        textEntity.components.set(model)
    }
    
}
