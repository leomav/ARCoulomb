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

extension ViewController: ARSessionDelegate, ARSCNViewDelegate {

    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "PointCharge" {

                /// Remove gesture recognizer needed for the First Tap -> Topology Anchor Placement
                self.disableRecognizers(withName: "First Point Recognizer")

                /// Create a Topology Instance with the added anchor as topoAnchor
                self.topology = Topology(viewController: self, topoAnchor: anchor)

                /// Open the bottom Coulomb Topology menu to choose topology
                performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
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
            self.topology?.toggleTopology(show: false)
        }
    }
}
