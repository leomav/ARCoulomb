//
//  Force.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 29/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit
import UIKit

/// forceId:    Id of the netforce entity
/// magnitude:  Force Magnitude (Newtons)
/// angle:      Angle (rads) of the force (arrowEntity) relativily to the pointChargeEntity (target)
/// length:     Length of the arrow entity
/// arrowEntity:    The Arrow Entity of the force
/// sourcePointCharge:      The source PointChargeClass object  which the force is coming from
/// targetPointCharge:     This PointChargeClass host object

class Force {
    static var total: Int = 0
    let forceId: Int
    var topology: Topology
    var magnitude: Float
    var previousMagnitude: Float
    var angle: Float
    
    /// Force X, Y Components
    var X_Force_Component: Float {
        let x = self.calculateForceComponent(x_component_flag: true)
        return x
    }
    var Y_Force_Component: Float {
        let y = self.calculateForceComponent(x_component_flag: false)
        return y
    }
    
    /// Length of the arrow body in meters
    var length: Float {
        let l = self.magnitude * Force.metersPerNewton
        return l
    }
    
    /// Meters per Newton for the Arrow Body
    static var metersPerNewton: Float = 0.01
    
    var pivotEntity: Entity
    var arrowEntity: Entity
    var label: Entity
    
    /// Drawing
    var color: UIColor {
        var color = self.type == ForceType.net ? UIColor.yellow : UIColor.white
        color = self.selected ? UIColor.green : color
        return color
    }
    var selected: Bool = false
    var type: ForceType
    
    init(type: ForceType, magnitude: Float, angle: Float, arrowEntity: Entity, inside topology: Topology) {
        Force.total += 1
        self.forceId = Force.total
        self.type = type
        
        // Set Topology, Magnitude, Angle
        self.topology = topology
        self.magnitude = magnitude
        self.previousMagnitude = magnitude
        self.angle = angle
        
        // Set the arrowEntity and its parent the pivotEntity
        /// Pivot entity is used to rotate the arrowEntity
        self.arrowEntity = arrowEntity
        if let parent = arrowEntity.parent {
            self.pivotEntity = parent
        } else {
            self.pivotEntity = Entity()
        }
        
        /// Set up the Force's Label
        let labelPos = SIMD3<Float>(0, 0, 0)
        self.label = EntityStore.shared.load_TextEntity(on: arrowEntity, inside: topology, name: "Force Label", position: labelPos)
    }
    
    deinit {
        /// Delete the label entity when pointCharge gets deleted
        self.topology.labels.removeAll { (label) -> Bool in
            return label.id == self.label.id
        }
    }
    
    // MARK: - STATIC FUNCTIONS
    
    static func createArrowModel(on pointChargeObj: PointChargeClass, magnitude: Float, name: String) -> Entity {
        // Create an EMPTY Pivot Entity
        let pivotEntity: Entity = Entity()
        pivotEntity.name = "Pivot Arrow"
        
        // Pivot Entity is a direct child of PointCharge Entity
        pointChargeObj.entity.addChild(pivotEntity)
        pivotEntity.setPosition(SIMD3<Float>(0, 0, 0), relativeTo: pointChargeObj.entity)
        
        // Load Arrow Body Entity
        let arrow = EntityStore.shared.load_ArrowBody(pointEntity: pointChargeObj.entity, magnitude: magnitude)
        arrow.name = name
        
        // Add it as a Pivot Child
        pivotEntity.addChild(arrow)
        
        /// - Tag: Pivot is crucial (Why?)
        /// Now, each time we want to rotate the arrow, we just have to rotate
        /// its parent pivot point entity, EASIER
        
        // Update Arrow Body's Length and Position
        EntityStore.shared.update_ArrowBody(arrowBodyEntity: arrow, magnitude: magnitude)

        // Add an Arrow Head on Arrow Body Entity
        EntityStore.shared.load_ArrowHead(on: arrow, magnitude: magnitude)
        
        /// Disable the arrow Entity.
        /// Later, the arrows relative to the selectedPointChargeObj will be enabled
        arrow.isEnabled = false
        
        return arrow
    }
    
    static func createSingleForce(from otherPointChargeObj: PointChargeClass, to pointChargeObj: PointChargeClass) -> SingleForce{
        let singleForce: SingleForce = SingleForce.createForce(from: otherPointChargeObj, to: pointChargeObj)
        
        // DONT FORGET: AFTER RETURN: topology -> netForce.forces.append(force)
        return singleForce
    }
    
    static func createNetForce(for pointChargeObj: PointChargeClass) -> NetForce{
        // TODO NetForce.createForce()
        let netForce: NetForce = NetForce.createForce(for: pointChargeObj)
        
        return netForce
    }
    
    
    // MARK: - Methods that need to be overriden in child classes
    
    private func calculateForceComponent(x_component_flag: Bool) -> Float {
        let quarter = self.angle.radiansToDegrees / 90
        let f_angleMod = (self.angle.radiansToDegrees.truncatingRemainder(dividingBy: 90)).degreesToRadians
        
        let f: Float = self.magnitude
        let f_component: Float
        
        /// To calculate correctly the Fx, Fy components, the Force Magnitude
        /// has to have its ABSOLUTE VALUE
        /// Thankfully, it is saved that way in the SingleForce Object
        
        switch x_component_flag {
        case true:
            if quarter < 1 {
                // 4th quarter
                f_component = f * sin(f_angleMod)
            } else if quarter < 2 {
                // 1st quarter
                f_component = f * cos(f_angleMod)
            } else if quarter < 3 {
                // 2nd quarter
                f_component = -f * sin(f_angleMod)
            } else {
                // 3rd quarter
                f_component = -f * cos(f_angleMod)
            }
        default:
            if quarter < 1 {
                // 4th quarter
                f_component = -f * cos(f_angleMod)
            } else if quarter < 2 {
                // 1st quarter
                f_component = f * sin(f_angleMod)
            } else if quarter < 3 {
                // 2nd quarter
                f_component = f * cos(f_angleMod)
            } else {
                // 3rd quarter
                f_component = -f * sin(f_angleMod)
            }
        }
        
        return f_component
    }
    
    func updateArrowModel() {
        /// Update Body Model Length
        EntityStore.shared.update_ArrowBody(arrowBodyEntity: self.arrowEntity, magnitude: self.magnitude)
        
        /// Update Head Model
        EntityStore.shared.update_ArrowHead(on: self.arrowEntity, magnitude: self.magnitude)
        
        /// Update Label
        /// Update labels only if difference is >= 0.01 m
        if abs(self.magnitude - self.previousMagnitude) >= 0.01 {
            self.updateLabel()
            
            /// Update new previous distance as the current one
            self.previousMagnitude = self.magnitude
        }
    }
    
    func updateForceMagnitude() {
        preconditionFailure("This method must be overridden")
    }
    
    func updateForceAngle() {
        preconditionFailure("This method must be overridden")
    }
    
    func updateForceArrowOrientation() {
        preconditionFailure("This method must be overridden")
    }
    
    private func updateLabel() {
        EntityStore.shared.update_TextEntity(textEntity: self.label, stringValue: String(format: "%.2fN", self.magnitude), fontSize: 0.008)
    }
    
}
