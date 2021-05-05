//
//  Status.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 29/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import ARKit

class Status {
    
    // MARK: - Types
    
    enum MessageType {
        case trackingStateEscalation
        case planeEstimation
        case contentPlacement
        
        static var all: [MessageType] = [
            .trackingStateEscalation,
            .planeEstimation,
            .contentPlacement,
        ]
    }
    
    // MARK: - Properties
    
    /// Trigerred when the "Restart Experience" button is tapped.
    var restartExperienceHandler: () -> Void = {}
    
    /// Seconds before the timer message should fade out. Adjust if the app needs longer transient messages.
    private let displayDuration: TimeInterval = 6
    
    // Timer for hiding messages.
    private var messageHideTimer: Timer?
    
    private var timers: [MessageType: Timer] = [:]
    
    let viewController: ViewController
    
    // MARK: - Initialization
    
    init(for vc: ViewController) {
        self.viewController = vc
    }
    
    // MARK: - Message Handling
    
    func showMessage(_ text: String, autoHide: Bool = true) {
        // Cancel any previous hide timer.
        messageHideTimer?.invalidate()
        
        self.viewController.messageLabel.text = text
        
        // Make sure status is showing.
        setMessageHidden(false, animated: true)
        
        if autoHide {
            messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false, block: { [weak self] _ in
                self?.setMessageHidden(true, animated: true)
            })
        }
    }
    
    func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
        cancelScheduledMessage(for: messageType)
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] timer in
            self?.showMessage(text)
            timer.invalidate()
        })
        
        timers[messageType] = timer
    }
    
    func cancelScheduledMessage(for messageType: MessageType) {
        timers[messageType]?.invalidate()
        timers[messageType] = nil
    }
    
    func cancelAllScheduledMessages() {
        for messageType in MessageType.all {
            cancelScheduledMessage(for: messageType)
        }
    }
    
    // MARK: - ARKit
    
    func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
        showMessage(trackingState.presentationString, autoHide: autoHide)
    }
    
    func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
        cancelScheduledMessage(for: .trackingStateEscalation)
        
        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [unowned self] _ in
            self.cancelScheduledMessage(for: .trackingStateEscalation)
            
            var message = trackingState.presentationString
            if let recommendation = trackingState.recommendation {
                message.append(": \(recommendation)")
            }
            
            self.showMessage(message, autoHide: false)
        })
        
        timers[.trackingStateEscalation] = timer
    }
    
    //        // MARK: - IBActions
    //
    //        @IBAction private func restartExperience(_ sender: UIButton) {
    //            restartExperienceHandler()
    //        }
    
    // MARK: - Panel Visibility
    
    private func setMessageHidden(_ hide: Bool, animated: Bool) {
        // The panel starts out hidden, so show it before animating opacity.
        self.viewController.messageLabel.isHidden = false
        
        guard animated else {
            self.viewController.messageLabel.alpha = hide ? 0 : 1
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.viewController.messageLabel.alpha = hide ? 0 : 1
        }, completion: nil)
    }
}

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(.excessiveMotion):
            return "TRACKING LIMITED\nExcessive motion"
        case .limited(.insufficientFeatures):
            return "TRACKING LIMITED\nLow detail"
        case .limited(.initializing):
            return "Initializing"
        case .limited(.relocalizing):
            return "Recovering from interruption"
        @unknown default:
            return "Unknown tracking state."
        }
    }

    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "Try slowing down your movement, or reset the session."
        case .limited(.insufficientFeatures):
            return "Try pointing at a flat surface, or reset the session."
        case .limited(.relocalizing):
            return "Return to the location where you left off or try resetting the session."
        default:
            return nil
        }
    }

}
