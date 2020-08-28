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

                /// Create a Topology Instance with the added anchor as topoAnchor
                self.topology = Topology(viewController: self, topoAnchor: anchor)
                
                /// Open the bottom Coulomb Topology menu to choose topology
                performSegue(withIdentifier: "toTopoMenuSegue", sender: nil)
            }
        }
    }
}
