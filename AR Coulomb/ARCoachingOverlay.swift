//
//  ARCoachingOverlay.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 23/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import ARKit

extension ViewController: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        
        // Create a ARCoachingOverlayView object
        let coachingOverlay = ARCoachingOverlayView()
        
        // Make sure it rescales if the device orientation changes
        coachingOverlay.autoresizingMask = [
          .flexibleWidth, .flexibleHeight
        ]
        arView.addSubview(coachingOverlay)
        
        // Set the Augmented Reality goal
        coachingOverlay.goal = .verticalPlane
        
        // Set the ARSession
        coachingOverlay.session = arView.session
        
        // Set the delegate for any callbacks
        coachingOverlay.delegate = self
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
      coachingOverlayView.activatesAutomatically = false
    }
        //      // Example callback for the delegate object
        //      func coachingOverlayViewDidDeactivate(
        //        _ coachingOverlayView: ARCoachingOverlayView
        //      ) {
        //        self.addObjectsToScene()
        //      }
}
