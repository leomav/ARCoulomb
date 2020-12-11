//
//  Entities.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 10/12/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import RealityKit

class EntityStore {
    static let shared = EntityStore()
    
    init() {}
    
    // MARK: - PointCharge
    func load_PointChargeEntity() -> Entity {
        let pointChargeEntity: Entity
        
        /// Import the Point Charge Model, clone the entity as many times as needed
        let pointChargeAnchor = try! PointCharge.load_PointCharge()
        pointChargeEntity = pointChargeAnchor.pointCharge!
        
        return pointChargeEntity
    }
    
    // MARK: - Text
    func load_TextEntity(pointCharge: PointChargeClass) -> Entity {
        let textEntity: Entity = Entity()
        textEntity.name = "text"
        textEntity.setParent(pointCharge.entity)
        textEntity.setPosition(SIMD3<Float>(-0.02, -0.03, 0), relativeTo: pointCharge.entity)
        textEntity.setOrientation(simd_quatf(angle: Int(90).degreesToRadians(), axis: SIMD3<Float>(1, 0, 0)), relativeTo: pointCharge.entity)
        
        return textEntity
    }
    
    func update_TextEntity(textEntity: Entity, material: SimpleMaterial, coulombStringValue: String) {
        let model: ModelComponent = ModelComponent(mesh: .generateText(coulombStringValue,
                                                                       extrusionDepth: 0.003,
                                                                       font: .systemFont(ofSize: 0.02),
                                                                       containerFrame: CGRect.zero,
                                                                       alignment: .left,
                                                                       lineBreakMode: .byCharWrapping),
                                                   materials: [material])
        textEntity.components.set(model)
    }
    
    
    // MARK: - Arrow Body
    func load_ArrowBodyEntity(pointEntity: Entity) -> Entity {
        let material: SimpleMaterial = {
            var mat = SimpleMaterial()
            mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
            mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
            mat.tintColor = UIColor.white
            return mat
        }()
        
//        let model: ModelComponent = ModelComponent(mesh: .generateBox(width: 0.1, height: 0.002, depth: 0.002), materials: [material] )
        let model: ModelComponent = ModelComponent(mesh: .generateBox(width: 0.002, height: 0.002, depth: 0.1), materials: [material] )
        
        let bodyEntity: Entity = Entity()
        pointEntity.addChild(bodyEntity)
//        bodyEntity.setPosition(SIMD3<Float>(-0.04, 0, 0), relativeTo: pointEntity)
//        bodyEntity.setPosition(SIMD3<Float>(0, 0, 0), relativeTo: pointEntity)
//        bodyEntity.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(1, 0, 0)), relativeTo: pointEntity)
        
        bodyEntity.components.set(model)

        return bodyEntity
    }
    
    // MARK: - Arrow Head
    func load_ArrowHead(arrowEntity: Entity) {
        let arrowHeadAnchor = try! ArrowHead.load_ArrowHead()
        let arrowHeadEntity = arrowHeadAnchor.arrowHead! as Entity
        
        /// Positioning
        arrowEntity.addChild(arrowHeadEntity)
        arrowHeadEntity.setScale(SIMD3<Float>(0.1,0.1,0.1), relativeTo: arrowHeadEntity)
//        arrowHeadEntity.setPosition(SIMD3<Float>(0.04,0,0), relativeTo: arrowEntity)
        arrowHeadEntity.setPosition(SIMD3<Float>(0,0,0.04), relativeTo: arrowEntity)
//        arrowHeadEntity.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: arrowEntity)
        arrowHeadEntity.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(0, 0, 1.0)), relativeTo: arrowEntity)

        
    }
    
}
