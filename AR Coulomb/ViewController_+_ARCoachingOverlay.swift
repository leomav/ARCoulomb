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
            self.guideText.isHidden = true
        }
        
        /// - Tag: PresentUI
        func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
            self.guideText.isHidden = false
            
            /// Helping Message in MessagePanel when surface is detected
            self.status?.cancelScheduledMessage(for: .planeEstimation)
            self.status?.showMessage("SURFACE DETECTED")
            if self.topology != nil {
                if self.topology?.pointCharges.count == 0 {
                    self.status?.scheduleMessage("TAP TO PLACE A TOPOLOGY", inSeconds: 7.5, messageType: .contentPlacement)
                }
            }
        }

        /// - Tag: StartOver
        func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
            //restartExperience()
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
            
            setActivatesAutomatically()
            
            /// Most of the virtual objects in this sample require a horizontal/vertical surface,
            /// therefore coach the user to find a horizontal/vertical plane.
            setGoal()
        }
        
        /// - Tag: CoachingActivatesAutomatically
        func setActivatesAutomatically() {
            coachingOverlay.activatesAutomatically = true
        }

        /// - Tag: CoachingGoal
        func setGoal() {
            coachingOverlay.goal = .anyPlane
    }
    
}

