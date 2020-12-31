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
        let pointChargeEntity: PointChargeEntity = PointChargeEntity()
        pointChargeEntity.name = "pointCharge"

        self.update_PointChargeModel(on: pointChargeEntity)

        return pointChargeEntity
    }
    
    func update_PointChargeEntity(pointChargeEntity: Entity, radius: Float, color: UIColor) {
        self.update_PointChargeModel(on: pointChargeEntity, radius: radius, color: color)
    }
    
    func update_PointChargeModel(on pointChargeEntity: Entity, radius: Float = PointChargeClass.pointChargeRadius, color: UIColor = UIColor.red) {
        // Add ModelComponent
        let model = load_PointChargeModel(radius: radius, color: color)
        pointChargeEntity.components.set(model)
        
        // Add CollisionComponent
        /// Make the collision sphere object radius little bigger than the model itself
        pointChargeEntity.components.set(CollisionComponent(shapes: [.generateSphere(radius: radius * 1.2)]))
    }
    
    private func load_PointChargeModel(radius: Float, color: UIColor) -> ModelComponent {
        let material: SimpleMaterial = {
            var mat = SimpleMaterial()
            mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
            mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
            mat.tintColor = color
            
            return mat
        }()
        
        let model: ModelComponent = ModelComponent(mesh: .generateSphere(radius: radius), materials: [material])
        
        return model
    }
    
    // MARK: - Text
    func load_TextEntity(pointCharge: PointChargeClass) -> Entity {
        let textEntity: Entity = Entity()
        textEntity.name = "text"
        textEntity.setParent(pointCharge.entity)
        textEntity.setPosition(SIMD3<Float>(-0.02, -(PointChargeClass.pointChargeRadius + 0.005), PointChargeClass.pointChargeRadius + 0.005), relativeTo: pointCharge.entity)
//        textEntity.setOrientation(simd_quatf(angle: Int(90).degreesToRadians(), axis: SIMD3<Float>(1, 0, 0)), relativeTo: pointCharge.entity)
        
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
    
    private func load_ArrowBody_ModelComponent(length: Float) -> ModelComponent{
        let material: SimpleMaterial = {
            var mat = SimpleMaterial()
            mat.metallic = MaterialScalarParameter(floatLiteral: 0.2)
            mat.roughness = MaterialScalarParameter(floatLiteral: 0.1)
            mat.tintColor = UIColor.white
            return mat
        }()
        
        let model: ModelComponent = ModelComponent(mesh: .generateBox(width: 0.002, height: 0.002, depth: length), materials: [material] )
        
        return model
    }
    
    private func update_ArrowBody_Entity_Length(arrowBodyEntity: Entity, length: Float) {
        let model = load_ArrowBody_ModelComponent(length: length)
        arrowBodyEntity.components.set(model)
    }
    
    func load_ArrowBody_Entity(pointEntity: Entity, magnetude: Float) -> Entity {
        let bodyEntity: Entity = Entity()
        pointEntity.addChild(bodyEntity)
        
        bodyEntity.name = "Arrow Body Entity"

        return bodyEntity
    }
    
    func update_ArrowBody_Entity(arrowBodyEntity: Entity, magnetude: Float) {
        /// Get the actual length in meters
        let length = magnetude * Force.metersPerNewton
        
        /// Arrow Body center needs to be <arrow-length>/2 + <pointCharge-Radius> meters away from Pivot Entity (Arrow's Parent)
        let pos = length/2 + 0.02
        arrowBodyEntity.setPosition(SIMD3<Float>(0, 0, pos), relativeTo: arrowBodyEntity.parent)
        
        /// Update Arrow Body Length
        self.update_ArrowBody_Entity_Length(arrowBodyEntity: arrowBodyEntity, length: length)
    }
    
    // MARK: - Arrow Head
    
    func load_ArrowHead(on arrowEntity: Entity, magnetude: Float) {
        let arrowHeadAnchor = try! ArrowHead.load_ArrowHead()
        let arrowHeadEntity = arrowHeadAnchor.arrowHead! as Entity
        
        /// <Set name>
        arrowHeadEntity.name = "Arrow Head Entity"
        
        /// <Add Head to Body>
        arrowEntity.addChild(arrowHeadEntity)
        
        /// <Scale the model (0.1)>
        arrowHeadEntity.setScale(SIMD3<Float>(0.1,0.1,0.1), relativeTo: arrowHeadEntity)
        
        /// <Orientation>
        //        arrowHeadEntity.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(0, 0, 1.0)), relativeTo: arrowEntity)
        //        arrowHeadEntity.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(0, 1.0, 0)), relativeTo: arrowEntity)
        //        arrowHeadEntity.setOrientation(simd_quatf(angle: 90.degreesToRadians(), axis: SIMD3<Float>(1.0, 0, 0)), relativeTo: arrowEntity)

        /// <Positioning>
        /// Get actual length in meters
        let length = magnetude * Force.metersPerNewton
        /// Set Position relatively to arrow entity (distance = half its length)
        /// CAREFUL: TO BE EXACT FOR THIS ARROW HEAD MODEL, REMOVE <----0.005m---->
        arrowHeadEntity.setPosition(SIMD3<Float>(0, 0, length/2 - 0.005), relativeTo: arrowEntity)
        
//        self.update_ArrowHead(on: arrowEntity, magnetude: magnetude)
    }
    
    func update_ArrowHead(on arrowEntity: Entity, magnetude: Float) {
        
        /// Find arrow Head Entity and update
        arrowEntity.children.forEach{ entity in
            if entity.name == "Arrow Head Entity" {
                let arrowHeadEntity = entity
                
                /// - Tag: Positioning
                /// Get actual length in meters
                let length = magnetude * Force.metersPerNewton
                /// Set Position relatively to arrow entity (distance = half its length)
                /// CAREFUL: TO BE EXACT FOR THIS ARROW HEAD MODEL, REMOVE <----0.005m---->
                arrowHeadEntity.setPosition(SIMD3<Float>(0, 0, length/2 - 0.005), relativeTo: arrowEntity)
                
            }
        }
    }
    
    
    // MARK: - Placement Indicator Entity
    
    
    func load_PlacementIndicator(side: Float = 0.1, imageAssetPath: String = "Placement_Indicator_LightYellow") -> AnchorEntity {
        let piEntity: AnchorEntity = AnchorEntity()
        piEntity.name = "PlacementIndicator"
        piEntity.isEnabled = false
        
        let model = load_PlacementIndicator_ModelComponent(side: side, imageAssetPath: imageAssetPath)
        piEntity.components.set(model)
        
        return piEntity
    }
    
    func toggle_PlacementIndicator(anchor: AnchorEntity, show: Bool) {
        anchor.isEnabled = show
    }
    
    private func load_PlacementIndicator_ModelComponent(side: Float, imageAssetPath: String) -> ModelComponent {
        var material: UnlitMaterial = UnlitMaterial()
        material.baseColor = try! MaterialColorParameter.texture(TextureResource.load(named: imageAssetPath))
        material.tintColor = UIColor.white.withAlphaComponent(0.9)
        
        let simpleMaterial: SimpleMaterial = SimpleMaterial()
        
        /// Plane for placement indicator
        let mesh: MeshResource = .generatePlane(width: side, depth: side)
        
        let model: ModelComponent = .init(mesh: mesh, materials: [material, simpleMaterial])
        
        return model
    }
    
    func update_PlacementIndicator_ModelComponent(on piAnchor: AnchorEntity, side: Float, imageAssetPath: String) {
        let model = load_PlacementIndicator_ModelComponent(side: side, imageAssetPath: imageAssetPath)
        piAnchor.components.set(model)
    }
    
    func update_PlacementIndicator_Transform(on piAnchor: AnchorEntity, transform: Transform) {
        piAnchor.transform = transform
        piAnchor.position.y += 0.02
    }
    
    
    
    
    
}
