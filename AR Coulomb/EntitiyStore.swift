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
    
    // MARK: - Arrow Body Material
    
    func load_ArrowBodyMaterial(magnetude: Float) -> ModelComponent{
        let material: SimpleMaterial = {
            var mat = SimpleMaterial()
            mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
            mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
            mat.tintColor = UIColor.white
            return mat
        }()
        
        let length: Float = magnetude * Force.metersPerNewton
        
        print("Length \(length) = magnetude \(magnetude) * metersPerNewton \(Force.metersPerNewton)")
        let model: ModelComponent = ModelComponent(mesh: .generateBox(width: 0.002, height: 0.002, depth: length), materials: [material] )
        
        return model
    }
    
    // MARK: - Arrow Body
    
    func load_ArrowBodyEntity(pointEntity: Entity, magnetude: Float) -> Entity {
//        let material: SimpleMaterial = {
//            var mat = SimpleMaterial()
//            mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
//            mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
//            mat.tintColor = UIColor.white
//            return mat
//        }()
//
//        let model: ModelComponent = ModelComponent(mesh: .generateBox(width: 0.002, height: 0.002, depth: 0.1), materials: [material] )
        
        
        let bodyEntity: Entity = Entity()
        pointEntity.addChild(bodyEntity)
//        bodyEntity.setPosition(SIMD3<Float>(-0.04, 0, 0), relativeTo: pointEntity)
//        bodyEntity.setPosition(SIMD3<Float>(0, 0, 0), relativeTo: pointEntity)
//        bodyEntity.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(1, 0, 0)), relativeTo: pointEntity)
        
        print(magnetude)
        
        self.update_ArrowBodyEntityLength(arrowBodyEntity: bodyEntity, magnetude: magnetude)

        return bodyEntity
    }
    
    // MARK: - Arrow Head
    func load_ArrowHead(on arrowEntity: Entity, magnetude: Float) {
        let arrowHeadAnchor = try! ArrowHead.load_ArrowHead()
        let arrowHeadEntity = arrowHeadAnchor.arrowHead! as Entity
        
        /// Positioning
        arrowEntity.addChild(arrowHeadEntity)
        arrowHeadEntity.setScale(SIMD3<Float>(0.1,0.1,0.1), relativeTo: arrowHeadEntity)
        
        /// Get actual length in meters
        let length = magnetude * Force.metersPerNewton
        /// Set Position relatively to arrow entity (distance = half its length)
        /// CAREFUL: TO BE EXACT FOR THIS ARROW HEAD MODEL, REMOVE <----0.005m---->
        arrowHeadEntity.setPosition(SIMD3<Float>(0, 0, length/2 - 0.005), relativeTo: arrowEntity)
        
        /// Set orientation
        arrowHeadEntity.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(0, 0, 1.0)), relativeTo: arrowEntity)
    }
    
    // MARK: - Update Arrow Entity Length when Force Magnetude changes
    func update_ArrowBodyEntityLength(arrowBodyEntity: Entity, magnetude: Float) {
        let model = load_ArrowBodyMaterial(magnetude: magnetude)
        arrowBodyEntity.components.set(model)
    }
    
}
