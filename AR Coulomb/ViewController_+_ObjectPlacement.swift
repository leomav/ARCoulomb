//
//  ViewController_+_ObjectPlacement.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 1/7/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import ARKit
import RealityKit

extension ViewController: ARSessionDelegate{
    
    
    /// - Tag: Updated version uses Anchor Entities instead of ARAnchors
    /// Topology is instanciated in ViewController_+_Gestures, no need for the delegate
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        for anchor in anchors {
//            if let anchorName = anchor.name, anchorName == "Topology" {
//
//                /// Remove gesture recognizer needed for the First Tap -> Topology Anchor Placement
//                self.disableRecognizers(withName: "First Point Recognizer")
//
//                /// Create a Topology Instance with the added anchor as topoAnchor
//                self.topology = Topology()
//                self.topology.pinToScene(viewController: self, topoAnchor: anchor)
//
//                /// Open the bottom Coulomb Topology menu to choose topology
//                performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
//            }
//        }
//        print(self.arView.scene.anchors)
//        print()
        anchors.forEach{ anchor in
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            if planeAnchor.alignment == .horizontal {
                print("horizontal")
            } else {
                print("vertical")
            }
            
        }
    }
    
    
    
    /// Changes to the quality of ARKit's device position tracking
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        self.status?.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        switch camera.trackingState {
        case .notAvailable, .limited:
            self.status?.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            self.status?.cancelScheduledMessage(for: .trackingStateEscalation)
            self.topology.toggleTopology(show: false)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
                
        // Update cameraTransform variable
        cameraTransform = arView.cameraTransform
        
        EntityStore.shared.update_AllTextOrientation(in: self.topology)
        
//        if let topoAnchor = self.arView.scene.anchors.first(where: {$0.name == "Topology"}) {
//            print(true)
//            EntityStore.shared.update_AllTextOrientation(anchor: topoAnchor as! AnchorEntity)
//        }
        

        // Raycast only if placement Indicator is enabled
        if (placementIndicator.isEnabled) {
            guard let query = arView.makeRaycastQuery(from: self.arView.center, allowing: .existingPlaneGeometry, alignment: .any) else { return }
            guard let raycastResult = arView.session.raycast(query).first else { return }

            // set a transform to an existing entity
            let transform = Transform(matrix: raycastResult.worldTransform)
            EntityStore.shared.update_PlacementIndicator_Transform(on: placementIndicator, transform: transform)
        }
        
    }
    
    // TESTING
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        arView.scene.anchors.forEach{ anchor in
//            anchor.children.forEach{ child in
//                child.children.forEach{ item in
//                    if item.name == "Coulomb Text" {
//                        item.look(at: cameraAnchor.position, from: item.position, relativeTo: item.parent)
//                    }
//                }
//            }
//        }
//    }
    
}
