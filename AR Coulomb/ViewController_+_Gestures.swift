//
//  ViewController_+_Gestures.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 1/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import RealityKit
import ARKit

extension ViewController {

    // MARK: - Initial Tap
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
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
    @objc
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: arView)

        guard let hitEntity = arView.entity(at: location) else {return}

        if recognizer.state == .began {
            if hitEntity == trackedEntity {
                longPressedEntity = hitEntity
                pointChargeInteract(zoom: ZOOM_OUT_4_5, showLabel: true)

                trackedEntity = Entity()

                // Find and set the new Selected PointChargeObj
                topology!.pointCharges.forEach{ pointChargeObj in
                    if pointChargeObj.entity == longPressedEntity {
                        selectedPointChargeObj = pointChargeObj
                    }
                }

                /// Disable and hide the addButton
                self.addButton.isHidden = true
                self.addButton.isEnabled = false
                
                /// Perform seague to CoulombMenu ViewController
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
            trackedEntity = hitEntity

            pointChargeInteract(zoom: ZOOM_IN_5_4, showLabel: false)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if trackedEntity.name == "pointCharge" {
            self.topology?.updateForces()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// If tracked entity is a pointCharge, check if its alignment differ less than 0.02m from the other particles.
        /// If so, align it to them
        if trackedEntity.name == "pointCharge" {
            pointChargeInteract(zoom: ZOOM_OUT_4_5, showLabel: true)

            let x = trackedEntity.position.x
            let z = trackedEntity.position.z

            // Loop through the scene anchors to find our "Point Charge Scene Anchor"
            arView.scene.anchors.forEach{ anchor in
                if anchor.name == "Point Charge Scene AnchorEntity" {
                    // Loop through its children (pointChargeEntities) and check their (x, z) differences
                    anchor.children.forEach{ child in
                        if child.position.x != x && child.position.z != z{
                            if abs(child.position.x - x) < 0.02 {
                                trackedEntity.position.x = child.position.x
                            }
                            if abs(child.position.z - z) < 0.02 {
                                trackedEntity.position.z = child.position.z
                            }
                        }
                    }
                }
            }

            /// Update all forces magnetudes and directions
            self.topology?.updateForces()

            /// When touches end, no entity is tracked by the gesture
            trackedEntity = Entity()
        }
    }
}

