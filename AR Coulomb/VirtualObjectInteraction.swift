//
//  VirtualObjectInteraction.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 23/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class VirtualObjectInteraction {
    
    /// The pointCharge Entity that is being longpressed (selected)
    var longPressedEntity: Entity = Entity()
    
    /// The pointCharge Entity that is being tracked (moved, tapped)
    var trackedEntity: Entity = Entity()
    
    /// The pointChargeObj which is being longpressed (selected)
    var selectedPointChargeObj: PointChargeClass?
    
    /// The scene view to hit test against when moving virtual content.
    let arView: ARView
    
    /// A reference to the view controller.
    let viewController: ViewController
    
    init(view: ARView, controller: ViewController) {
        self.arView = view
        self.viewController = controller
        
        /// First tap gesture recognizer, will be deleted after first pointCharge is added
        let firstPointTapRecognizer = UITapGestureRecognizer(target: self.viewController, action: #selector(viewController.handleTap(recognizer:)))
        firstPointTapRecognizer.name = "First Point Recognizer"
        arView.addGestureRecognizer(firstPointTapRecognizer)
        
        /// Long Press Recognizer to interact with PointCharge (min press 1 sec)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self.viewController, action: #selector(viewController.handleLongPress(recognizer:)))
        longPressRecognizer.name = "Long Press Recognizer"
        longPressRecognizer.minimumPressDuration = 1
        arView.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.isEnabled =  false
    }
    
    // MARK: - (De)emphasize Visualization
    func interact(zoom: Float, showLabel: Bool) {
        // (De)emphasize the Point Charge by scaling it down/up 50%
        self.trackedEntity.setScale(SIMD3<Float>(zoom, zoom, zoom), relativeTo: self.trackedEntity)
        // Show/Hide the value label
        self.trackedEntity.children.forEach{ child in
            if child.name == "text" {
                child.isEnabled = showLabel
            }
        }
    }

}

extension ViewController {
    
    // MARK: - Initial Tap
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .vertical)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "PointCharge", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("No horizontal surface found.")
        }
    }
    
    // MARK: - PointCharge LongPress
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        var voiLongPressedEntity = virtualObjectInteraction.longPressedEntity
        var voiTrackedEntity = virtualObjectInteraction.trackedEntity
        guard var voiSelectedPointChargeObj = virtualObjectInteraction.selectedPointChargeObj else {return}
        
        guard let hitEntity = arView.entity(at: location) else {return}
        
        if recognizer.state == .began {
            if hitEntity == voiTrackedEntity {
                setEntity(te: &voiLongPressedEntity, e: hitEntity)
                
                virtualObjectInteraction.interact(zoom: ZOOM_OUT_4_5, showLabel: true)
                
                clearEntity(te: &voiTrackedEntity)
                
                /// Find and set the new Selected PointChargeObj
                pointCharges.forEach{ pointChargeObj in
                    if pointChargeObj.entity == voiLongPressedEntity {
                        print("Point Charge selected")
                        setSelectedObject(so: &voiSelectedPointChargeObj, o: pointChargeObj)
                    }
                }
                
                performSegue(withIdentifier: "toCoulombMenuSegue", sender: nil)
            }
        }
        
        if recognizer.state == .ended {
            if hitEntity.name == "pointCharge" {
            }
        }
    }
    
    // MARK: - Drag & Drop PointChargeEntities
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: arView) else {return}
        guard let hitEntity = arView.entity(at: location) else {return}
        
        if hitEntity.name == "pointCharge" {
            setEntity(te: &virtualObjectInteraction.trackedEntity, e: hitEntity)
            
            virtualObjectInteraction.interact(zoom: ZOOM_IN_5_4, showLabel: false)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if virtualObjectInteraction.trackedEntity.name == "pointCharge" {
            updateForces()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var voiTrackedEntity = virtualObjectInteraction.trackedEntity
        
        /*  If tracked entity is a pointCharge, check if its alignment differ less than 0.02m from the other particles.
            If so, align it to them
        */
        if voiTrackedEntity.name == "pointCharge" {
            virtualObjectInteraction.interact(zoom: ZOOM_OUT_4_5, showLabel: true)
            
            let x = voiTrackedEntity.position.x
            let z = voiTrackedEntity.position.z
            
            /// Loop through the scene anchors to find our "Point Charge Scene Anchor"
            arView.scene.anchors.forEach{ anchor in
                if anchor.name == "Point Charge Scene AnchorEntity" {
                    /// Loop through its children (pointChargeEntities) and check their (x, z) differences
                    anchor.children.forEach{ child in
                        if child.position.x != x && child.position.z != z{
                            if abs(child.position.x - x) < 0.02 {
                                voiTrackedEntity.position.x = child.position.x
                            }
                            if abs(child.position.z - z) < 0.02 {
                                voiTrackedEntity.position.z = child.position.z
                            }
                        }
                    }
                }
            }
            
            /// Update all forces magnetudes and directions
            updateForces()
           
            /// When touches end, no entity is tracked by the gesture
            clearEntity(te: &voiTrackedEntity)
        }
    }
    
    // MARK: - Set & Clear functions: entity, pointChargeObj
    
    private func setEntity(te: inout Entity, e: Entity) {
        te = e
    }
    private func clearEntity(te: inout Entity) {
        te = Entity()
    }
    private func setSelectedObject(so: inout PointChargeClass, o: PointChargeClass) {
        so = o
    }
    private func clearSelectedObject(so: inout PointChargeClass) {
        so = PointChargeClass(entity: Entity(), value: 0)
    }
}
