//
//  ViewController_+_UI.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 28/8/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

extension ViewController {
    
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
        
        self.restartExperienceButton.addTarget(self, action: #selector(restartExperience(sender:)), for: .touchUpInside)
        
        self.restartExperienceButton.tintColor = UIColor.white
        
        self.restartExperienceButton.centerYAnchor.constraint(equalTo: self.messagePanel.centerYAnchor).isActive = true
        self.restartExperienceButton.trailingAnchor.constraint(equalTo: self.messagePanel.trailingAnchor, constant: -15).isActive = true
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
        
        /// Set up the ADD Button (adds pointcharge to scene)
        self.configureAddButton(height: 50)
        
        /// Set up the New Topo Button (opens the topology bottom menu)
        self.configureNewTopoButton(height: 50)
        
        self.stackView.addArrangedSubview(newTopoButton)
        self.stackView.addArrangedSubview(addButton)
        
        /// At first, it's hidden and disabled until a topology is placed
        self.hideAndDisableButtons()
    }
    
    func configureAddButton(height: Float) {
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        
        let image = UIImage(systemName: "plus", withConfiguration: config)
        
        self.addButton.setImage(image, for: .normal)
        
        let padding: CGFloat = 8.0
        self.addButton.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        self.addButton.addTarget(self, action: #selector(performAddition(sender:)), for: .touchUpInside)
        
        self.addButton.layer.cornerRadius = 10
        //        self.addButton.imageView?.clipsToBounds = true
        
        self.addButton.tintColor = UIColor.white
        self.addButton.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        self.addButton.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
    }
    
    func configureNewTopoButton(height: Float) {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        
        let image = UIImage(systemName: "rectangle.stack.badge.plus", withConfiguration: config)
        
        self.newTopoButton.setImage(image, for: .normal)
        
        let padding: CGFloat = 8.0
        self.newTopoButton.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        self.newTopoButton.addTarget(self, action: #selector(performTopoMenuSeague(sender:)), for: .touchUpInside)
        
        self.newTopoButton.layer.cornerRadius = 10
        //        self.addButton.imageView?.clipsToBounds = true
        
        self.newTopoButton.tintColor = UIColor.white
        self.newTopoButton.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        self.newTopoButton.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
    }
    
    func configureGuideTextView() {
        /// Add the guideText TextView to the arView before setting the textView's contsraints (relatively to arView)
        self.arView.addSubview(self.guideText)
        
        self.guideText.text = "Tap the surface to place a topology."
        self.guideText.textColor = UIColor.white
        
        self.guideText.textAlignment = .center
        self.guideText.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        self.guideText.numberOfLines = 0
        
        self.guideText.topAnchor.constraint(equalTo: self.arView.topAnchor, constant: 80).isActive = true
        self.guideText.centerXAnchor.constraint(equalTo: self.arView.centerXAnchor).isActive = true
        
        self.guideText.isHidden = true
    }
    
    // MARK: - StackView Existance
    
    func showAndEnableButtons() {
        self.addButton.isEnabled = true
        self.newTopoButton.isEnabled = true
        self.stackView.isHidden = false
    }

    func hideAndDisableButtons() {
        self.addButton.isEnabled = false
        self.newTopoButton.isEnabled = false
        self.stackView.isHidden = true
    }
}
