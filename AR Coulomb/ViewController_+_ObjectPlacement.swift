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

extension ViewController: ARSessionDelegate {

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "PointCharge" {
                
                /// Hide the top Helper Text since the user has just touched and placed the Anchor
                self.guideText.isHidden = true
                
                /// Remove gesture recognizer needed for the First Tap -> Topology Anchor Placement
                self.disableRecognizers(withName: "First Point Recognizer")
                
                /// Enable the pointCharge LongPress Recognizer
                self.enableRecognizers(withName: "Long Press Recognizer")

                /// Create a Topology Instance with the added anchor as topoAnchor
                self.topology = Topology(viewController: self, topoAnchor: anchor)
                
                /// Open the bottom Coulomb Topology menu to choose topology
                performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
            }
        }
    }
}
