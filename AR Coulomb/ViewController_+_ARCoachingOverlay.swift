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
    
        
        /// - Tag: HideUI
        func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
            // upperControlsView.isHidden = true
        }
        
        /// - Tag: PresentUI
        func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
            // upperControlsView.isHidden = false
        }

        /// - Tag: StartOver
        func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
            //restartExperience()
        }

        func setupCoachingOverlay() {
            /// Set up coaching view
            coachingOverlay.session = arView.session
            coachingOverlay.delegate = self
            
            coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
            arView.addSubview(coachingOverlay)
            
            NSLayoutConstraint.activate([
                coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
                coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
                ])
            
            setActivatesAutomatically()
            
            /// Most of the virtual objects in this sample require a horizontal surface,
            /// therefore coach the user to find a horizontal plane.
            setGoal()
        }
        
        /// - Tag: CoachingActivatesAutomatically
        func setActivatesAutomatically() {
            coachingOverlay.activatesAutomatically = true
        }

        /// - Tag: CoachingGoal
        func setGoal() {
        coachingOverlay.goal = .horizontalPlane
    }
    
}

