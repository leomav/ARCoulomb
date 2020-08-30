//
//  ViewController_+_UI.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 28/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit


extension ViewController {
    
    //    enum MenuType {
    //        case main = "main"
    //        case camera = "camera"
    //
    //        static var all = [MenuType] {
    //            .main,
    //            .camera
    //        }
    //    }
    
    // MARK: - Configurations
    
    func configureMessagePanel() {
        /// Add the Stack View to the arView
        self.arView.addSubview(self.messagePanel)
        
        // Set Background Color to Transparent
        self.messagePanel.backgroundColor = UIColor(white: 0, alpha: 0)
        
        self.messagePanel.leadingAnchor.constraint(equalTo: self.arView.leadingAnchor).isActive = true
        self.messagePanel.topAnchor.constraint(equalTo: self.arView.topAnchor).isActive = true
        self.messagePanel.trailingAnchor.constraint(equalTo: self.arView.trailingAnchor).isActive = true
        self.messagePanel.heightAnchor.constraint(equalToConstant: CGFloat(80)).isActive = true
        
        self.configureMessageLabel()
        self.configureRestartExperienceButton()
    }
    
    private func configureMessageLabel() {
        self.messagePanel.addSubview(self.messageLabel)
        
        self.messageLabel.textColor = UIColor.black
        self.messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        self.messageLabel.backgroundColor = UIColor(white: 1, alpha: 1)
        self.messageLabel.layer.cornerRadius = 10
        
        //        self.messageLabel.textAlignment = .center
        //        self.messageLabel.numberOfLines = 0
        
        self.messageLabel.centerYAnchor.constraint(equalTo: self.messagePanel.centerYAnchor).isActive = true
        self.messageLabel.leadingAnchor.constraint(equalTo: self.messagePanel.leadingAnchor, constant: 30).isActive = true
        
        //        self.messageLabel.isHidden = true
    }
    
    private func configureRestartExperienceButton() {
        self.messagePanel.addSubview(self.restartExperienceButton)
        
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .light, scale: .large)
        
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: config)
        
        self.restartExperienceButton.setImage(image, for: .normal)
        
        let padding: CGFloat = 8.0
        self.restartExperienceButton.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        //        self.restartExperienceButton.addTarget(self, action: #selector(restartExperience(sender:)), for: .touchUpInside)
        
        self.restartExperienceButton.tintColor = UIColor.white
        
        self.restartExperienceButton.centerYAnchor.constraint(equalTo: self.messagePanel.centerYAnchor).isActive = true
        self.restartExperienceButton.trailingAnchor.constraint(equalTo: self.messagePanel.trailingAnchor, constant: -15).isActive = true
    }
    
    func configureShutterView() {
        self.arView.addSubview(shutterView)
        
        /// At first, shutter view is total trasparent ...
        self.shutterView.backgroundColor = UIColor(white: 1, alpha: 0)
        
        self.shutterView.leadingAnchor.constraint(equalTo: self.arView.leadingAnchor).isActive = true
        self.shutterView.topAnchor.constraint(equalTo: self.arView.topAnchor).isActive = true
        self.shutterView.trailingAnchor.constraint(equalTo: self.arView.leadingAnchor).isActive = true
        self.shutterView.bottomAnchor.constraint(equalTo: self.arView.bottomAnchor).isActive = true
        
        /// ... and also Hidden
        self.shutterView.isHidden = true
    }
    
    func configureStackView() {
        /// Add the Stack View to the arView
        self.arView.addSubview(self.stackView)
        
        self.stackView.axis = .vertical
        self.stackView.spacing = 20
        self.stackView.backgroundColor = UIColor(white: 0, alpha: 0)
        self.stackView.distribution = .fillEqually
        
        self.stackView.bottomAnchor.constraint(equalTo: self.arView.bottomAnchor, constant: -30).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.arView.trailingAnchor, constant: -15).isActive = true
        
        /// Configure the StackView Menu Buttons
        self.configureButton(btn: self.saveButton, imageName: "square.and.arrow.down", height: 50)
        self.configureButton(btn: self.newTopoButton, imageName: "rectangle.stack.badge.plus", height: 50)
        self.configureButton(btn: self.addButton, imageName: "plus", height: 50)
        self.configureButton(btn: self.captureButton, imageName: "camera.viewfinder", height: 50)
        self.configureButton(btn: self.cancelCaptureButton, imageName: "arrow.turn.up.left", height: 50)
        
        /// At first, stackView contains the Main Menu Buttons
        self.stackView.addArrangedSubview(saveButton)
        self.stackView.addArrangedSubview(newTopoButton)
        self.stackView.addArrangedSubview(addButton)
        
        /// At first, it's hidden and disabled until a topology is placed
        self.toggleStackView(hide: true, animated: false)
    }
    
    func configureButton(btn: UIButton, imageName: String, height: Float){
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        
        let image = UIImage(systemName: imageName, withConfiguration: config)
        
        btn.setImage(image, for: .normal)
        
        let padding: CGFloat = 8.0
        btn.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        //        self.addButton.addTarget(self, action: #selector(performAddition(sender:)), for: .touchUpInside)
        
        btn.layer.cornerRadius = 10
        //        self.addButton.imageView?.clipsToBounds = true
        btn.tintColor = UIColor.white
        btn.backgroundColor = UIColor(white: 0, alpha: 0.7)
        btn.isHidden = true
        
        btn.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
    }
    
    // MARK: - StackView Existance
    
    func toggleStackView(hide: Bool, animated: Bool = true) {
        
        /// animated will be false when we want to hide the stackView
        if !animated {
            self.stackView.subviews.forEach{ btn in
                btn.isHidden = hide
            }
            self.stackView.isHidden = hide
            
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.stackView.spacing = hide ? 0 : 20
            self.stackView.arrangedSubviews.forEach{ btn in
                btn.isHidden = hide
            }
            self.stackView.isHidden = hide
        }, completion: nil)
    }
    
    func transitionStackViewMenu(to menu: String) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.stackView.spacing = 0
            self.stackView.arrangedSubviews.forEach{ btn in
                btn.isHidden = true
            }
        }, completion: {(finished) in
            
            /// Replace the current menu's buttons with the next menu's
            self.stackView.arrangedSubviews.forEach{ btn in
                self.stackView.removeArrangedSubview(btn)
            }
            self.menuDict?[menu]?.forEach{ btn in
                self.stackView.addArrangedSubview(btn)
            }
            
            /// Present them
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
                self.stackView.spacing = 20
                self.stackView.arrangedSubviews.forEach{ btn in
                    btn.isHidden = false
                }
            }, completion: nil)
        })
    }
    
    // MARK: - SubViews existance
    func toggleAllSubviews(of view: UIView, hide: Bool) {
        view.subviews.forEach { sub in
            sub.isHidden = hide
        }
    }
    
}
