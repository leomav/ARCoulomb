//
//  BottomPopUpTopologies.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

class BottomTopoMenuVC: UIViewController {
    
    // translates autoresizing mask into constraints lets us
    // manually alter the constraints
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        
        return stack
    }()
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        // When the next line was not present, the ScrollView crashed
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
        return scroll
    }()
    
    let previewView: UIView = {
        let preview = UIView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        
        return preview
    }()
    
    let previewImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    let previewDetailsView: UIView = {
        let details = UIView()
        details.translatesAutoresizingMaskIntoConstraints = false
        
        return details
    }()
    
    let previewTitleTextView: UITextView = {
        let title = UITextView()
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
    
    let previewDetailsTextView: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        
        return text
    }()
    
    
    
    @IBOutlet var bottomTopoMenuView: UIView!
    var selectedTopo: TopologyModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomTopoMenuView.backgroundColor = UIColor(white: 0, alpha: 0.7)

        // Do any additional setup after loading the view.
        
        self.configureScrollView()
        self.configureStackView()
        self.configurePreviewView()
        self.configurePreviewImageView()
        self.configurePreviewDetailsView()
        self.configurePreviewTitleTextView()
        self.configurePreviewDetailsTextView()
    }
    
    
    // MARK: - ScrollView & StackView configuration
    func configureScrollView() {
        // You simply cannot constrain a view to another view if the view isn’t even on the screen yet.
        self.bottomTopoMenuView.addSubview(self.scrollView)
        
        self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
    func configureStackView() {
        self.scrollView.addSubview(self.stackView)
        
        self.stackView.axis = .horizontal
        self.stackView.spacing = 8
        self.stackView.backgroundColor = .none
        self.stackView.distribution = .fillEqually
        //stack.alignment = .fill
        
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        
        self.stackView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        
        for i in  0...TopologyStore.sharedInstance.totalTopologies() - 1 {
            // Setup button
            let btn = UIButton()
            btn.setBackgroundImage(TopologyStore.sharedInstance.savedTopologies[i].image, for: .normal)
            btn.addTarget(self, action: #selector(self.buttonSelectTopoAction(sender:)), for: .touchUpInside)
            btn.isEnabled = true
            btn.tag = i
            btn.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            // If i=0, set selectedTopo
            if i == 0 {
                selectedTopo = TopologyStore.sharedInstance.savedTopologies[i]
                btn.isSelected = true
            }

            // Add the button to the view
            self.stackView.addArrangedSubview(btn)
        }
    }
    
    func configurePreviewView() {
        self.bottomTopoMenuView.addSubview(previewView)
        
        self.previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.previewView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -210).isActive = true
        self.previewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
    }
    
    func configurePreviewImageView() {
        self.previewView.addSubview(previewImageView)
        
        self.previewImageView.leadingAnchor.constraint(equalTo: self.previewView.leadingAnchor).isActive = true
        self.previewImageView.topAnchor.constraint(equalTo: self.previewView.topAnchor).isActive = true
        self.previewImageView.bottomAnchor.constraint(equalTo: self.previewView.bottomAnchor).isActive = true
        self.previewImageView.trailingAnchor.constraint(equalTo: self.previewView.trailingAnchor).isActive = true
        
        self.previewImageView.image = selectedTopo?.getImage()
    }
    
    func configurePreviewDetailsView() {
        self.previewImageView.addSubview(previewDetailsView)
        
        self.previewDetailsView.leadingAnchor.constraint(equalTo: self.previewImageView.leadingAnchor).isActive = true
        self.previewDetailsView.topAnchor.constraint(equalTo: self.previewImageView.bottomAnchor, constant: -200).isActive = true
        self.previewDetailsView.bottomAnchor.constraint(equalTo: self.previewImageView.bottomAnchor).isActive = true
        self.previewDetailsView.trailingAnchor.constraint(equalTo: self.previewImageView.trailingAnchor).isActive = true
        
        previewDetailsView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    func configurePreviewTitleTextView() {
        self.previewDetailsView.addSubview(previewTitleTextView)
        
        self.previewTitleTextView.topAnchor.constraint(equalTo: self.previewDetailsView.topAnchor).isActive = true
        self.previewTitleTextView.bottomAnchor.constraint(equalTo: self.previewDetailsView.topAnchor, constant: 70).isActive = true
        self.previewTitleTextView.leadingAnchor.constraint(equalTo: self.previewDetailsView.leadingAnchor, constant: 10).isActive = true
        self.previewTitleTextView.trailingAnchor.constraint(equalTo: self.previewDetailsView.trailingAnchor, constant: -10).isActive = true
        
        self.previewTitleTextView.text = selectedTopo?.getName().uppercased()
        self.previewTitleTextView.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.previewTitleTextView.textColor = .white
        self.previewTitleTextView.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.previewTitleTextView.textAlignment = .center
    }
    
    func configurePreviewDetailsTextView() {
        self.previewDetailsView.addSubview(previewDetailsTextView)
        
        self.previewDetailsTextView.topAnchor.constraint(equalTo: self.previewDetailsView.topAnchor, constant: 70).isActive = true
        self.previewDetailsTextView.bottomAnchor.constraint(equalTo: self.previewDetailsView.bottomAnchor).isActive = true
        self.previewDetailsTextView.leadingAnchor.constraint(equalTo: self.previewDetailsView.leadingAnchor, constant: 10).isActive = true
        self.previewDetailsTextView.trailingAnchor.constraint(equalTo: self.previewDetailsView.trailingAnchor, constant: -10).isActive = true
        
        self.previewDetailsTextView.text = selectedTopo?.getDescription()
        self.previewDetailsTextView.font = UIFont.systemFont(ofSize: 12)
        self.previewDetailsTextView.textColor = .white
        self.previewDetailsTextView.backgroundColor = UIColor.white.withAlphaComponent(0)
    }
    
    func updatePreview() {
        self.previewImageView.image = selectedTopo?.getImage()
        self.previewTitleTextView.text = selectedTopo?.getName().uppercased()
        self.previewDetailsTextView.text = selectedTopo?.getDescription().uppercased()
    }
    
    @objc
    func buttonLoadTopoAction(sender: UIButton!) {
        let btnsend: UIButton = sender
        
        let totalTopologies = TopologyStore.sharedInstance.totalTopologies()
        if btnsend.tag > -1 && btnsend.tag < totalTopologies {
            /// Set the new topology (new positions)
//            let pos = defaultPositions[btnsend.tag]
            
            /// Set the new topology
            let newTopo = TopologyStore.sharedInstance.savedTopologies[btnsend.tag]
            
            /// Notify for new positions
            let notifName = Notification.Name(rawValue: topoNotificationKey)
            let valueDict: [String: TopologyModel] = ["updatedValue": newTopo]
//            let valueDict: [String: [SIMD3<Float>]] = ["updatedValue": pos]
            NotificationCenter.default.post(name: notifName, object: nil, userInfo: valueDict)
            
            ///Dismiss the menu view
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    @objc
    func buttonDeleteTopoAction(sender: UIButton!) {
        let btnsend: UIButton = sender
        
        let totalTopologies = TopologyStore.sharedInstance.totalTopologies()
        if btnsend.tag > -1 && btnsend.tag < totalTopologies {
            /// Set the new topology (new positions)
//            let pos = defaultPositions[btnsend.tag]
            
            /// Set the new topology
            let newTopo = TopologyStore.sharedInstance.savedTopologies[btnsend.tag]
            
            /// Notify for new positions
            let notifName = Notification.Name(rawValue: topoNotificationKey)
            let valueDict: [String: TopologyModel] = ["updatedValue": newTopo]
//            let valueDict: [String: [SIMD3<Float>]] = ["updatedValue": pos]
            NotificationCenter.default.post(name: notifName, object: nil, userInfo: valueDict)
            
            ///Dismiss the menu view
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    @objc
    func buttonSelectTopoAction(sender: UIButton!) {
        let btnsend: UIButton = sender
        
        let totalTopologies = TopologyStore.sharedInstance.totalTopologies()
        if btnsend.tag > -1 && btnsend.tag < totalTopologies {
            
            /// Set the new topology
            self.selectedTopo = TopologyStore.sharedInstance.savedTopologies[btnsend.tag]
            
            /// Update Preview Backgound Image
            self.updatePreview()
        }
    }
    
    
    // MARK: - TouchesBegan: check if touch happened outside the menu subviews
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchView = touches.first?.view
        var exit = true
        
        /// If no subView is touched, dismiss
        self.bottomTopoMenuView.subviews.forEach{ subView in
            if touchView == subView {
                exit = false
            }
        }
        if exit == true {
            dismiss(animated: true) {
                self.notifyObserver(withKey: dismissalNotificationKey)
            }
        }
    }
    
    private func notifyObserver(withKey key: String){
        let notifName = Notification.Name(rawValue: key)
        NotificationCenter.default.post(name: notifName, object: nil, userInfo: nil)
    }
    

}
