//
//  ViewController_+_Observers.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//


import UIKit

extension ViewController {

    //  (1)
    //  MARK: - CoulombMenu ViewController dismissed
    
    /// CoulombMenu Dismissal Observer: When CoulombMenu VC is dismissed without any action (like pointCharge deletion)
    func setupObserverCoulombMenuDismissal() {
        let notifName = Notification.Name(rawValue: dismissalNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(recoverAddButton(notification:)), name: notifName, object: nil)
    }
    
    @objc
    func recoverAddButton(notification: Notification) {
        /// Enable the ADD Button
        self.showAndEnableButton(btn: self.addButton)
    }
    
    //  (2)
    //  MARK: - Topology Observer
    
    /// Topology Observer: When new topology is selected
    func setupObserverNewTopo() {
        let notifName = Notification.Name(rawValue: topoNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(createTopology(notification:)), name: notifName, object: nil)
    }
    /// update the selected Positions
    @objc
    func createTopology(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? [SIMD3<Float>] {

            /// Empty current selectedPositionsArray and fill it again with the new positions
            topology!.selectedPositions.removeAll()
            topology!.selectedPositions.append(contentsOf: newValue)
            
            /// Place the selected Topology on the AnchorEntity placed in scene
            if topology!.topoAnchor != nil {
                topology!.placeTopology()
            } else {
                print("Error: No anchor is selected for topology placement!")
            }
            
            /// Enable the ADD Button
            self.showAndEnableButton(btn: self.addButton)

        } else {
            print("Error: Not updated topology!")
        }
    }
    
    //  (3)
    //  MARK: - Coulomb Removal Observer
    
    /// When a coulomb is deleted in the CoulombMenu ViewController
    func setupObserverPointChargeDeletion() {
        let notifName = Notification.Name(rawValue: removalNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(removePointCharge(notification: )), name: notifName, object: nil)
    }
    /// Remove the selected pointCharge
    @objc
    func removePointCharge(notification: Notification) {
        
        Alert.showDeletionConfirmation(on: self)
    }
    
    //  (4)
    //  MARK: - Coulomb Value Observer
    
    /// When new value occurs for the selected PointChargeObj
    func createCbObserver() {
        let notifName = Notification.Name(rawValue: cbNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCoulombValue(notification:)), name: notifName, object: nil)
    }
    /// Set the new selected Point Charge obj's value, update its text, update its text, update all forces
    @objc
    func updateCoulombValue(notification: Notification) {
        if let newValue = (notification.userInfo?["updatedValue"]) as? Float {
            
            selectedPointChargeObj.value = newValue
            
            PointChargeClass.loadText(textEntity: longPressedEntity.children[1], material: coulombTextMaterial, coulombStringValue: "\(newValue) Cb")
            
            self.topology?.updateForces()
            
        } else {
            print("Error: Not updated coulomb value!")
        }
    }
    
}
