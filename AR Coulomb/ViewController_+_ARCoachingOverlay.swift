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
            print("coaching Overlay View will activate")
            
            /// Disable the Placement Indicator
            EntityStore.shared.toggle_PlacementIndicator(anchor: placementIndicator, show: false)
        }
        
        /// - Tag: PresentUI
        func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
            /// Enable the Tap Recognizer to place the Topology after finding a surface
            self.arView.gestureRecognizers?.first(where: {$0.name == "First Point Recognizer"})?.isEnabled = true
            
            /// Helping Message in MessagePanel when surface is detected
            self.status?.cancelScheduledMessage(for: .planeEstimation)
            self.status?.showMessage("SURFACE DETECTED")
            
            if self.topology != nil {
                if self.topology.pointCharges.count == 0 {
                    /// Activate the Placement Indicator
                    EntityStore.shared.toggle_PlacementIndicator(anchor: placementIndicator, show: true)
                    /// Schedule message
                    self.status?.scheduleMessage("TAP TO PLACE TOPOLOGY", inSeconds: 2, messageType: .contentPlacement)
                }
            }
        }
    
        

        /// - Tag: StartOver
        func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
            print("coaching Overlay View did REQUEST SESSION RESET")
            restartExperience()
        }

        func setupCoachingOverlay() {
            /// Set up coaching view
            coachingOverlay.session = self.arView.session
            coachingOverlay.delegate = self
            
            coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
            self.arView.addSubview(coachingOverlay)
            
            NSLayoutConstraint.activate([
                coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
                coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
                ])
            
            /// Force Coach Overlay for 2 seconds, then leave it to autopilot
            self.setAutoActivation(auto: false)
            self.coachingOverlay.setActive(true, animated: true)
            
            /// After 2 seconds, leave it to autopilot
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.setAutoActivation(auto: true)
            }
            
            /// Most of the virtual objects in this sample require a horizontal/vertical surface,
            /// therefore coach the user to find a horizontal/vertical plane.
            setGoal()
        }
        
        /// - Tag: Coaching Activates Automatically
        func setAutoActivation(auto: Bool) {
            coachingOverlay.activatesAutomatically = auto
        }
    

        /// - Tag: CoachingGoal
        func setGoal() {
            coachingOverlay.goal = .anyPlane
    }
    
}

