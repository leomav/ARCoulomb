//
//  BottomPopUpTopologies.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit
import CoreData

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
    
    let selectTopoButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(buttonLoadTopoAction(sender:)), for: .touchUpInside)
        btn.isEnabled = true
        btn.setTitle("Select".uppercased(), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 3
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        return btn
    }()
    
    let deleteTopoButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(buttonDeleteTopoAction(sender:)), for: .touchUpInside)
        btn.setTitle("Delete", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 3
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        btn.isEnabled = true
        btn.isHidden = false
        
        return btn
    }()
    
    let dismissMenuButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(dismissMenu(sender:)), for: .touchUpInside)
        btn.setTitle("Close", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 3
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        btn.isEnabled = true
        btn.isHidden = false
        
        return btn
    }()
    
    
    
    @IBOutlet var bottomTopoMenuView: UIView!
    var selectedTopo: TopologyModel?
    
    override func viewDidLoad() {
        
//        print("Bottom Topo Menu did load")
        
        /// Reload savedTopologies, cause Object Identifiers for custom saved topos
        /// change for some reason. Also, do the same before deleting!
        TopologyStore.sharedInstance.reloadSavedTopologies()
        
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
        self.configureSelectTopoButton()
        self.configureDeleteTopoButton()
        self.configureDissmissMenuButton()
    }
    
    private func reloadTopoView() {
//        print("Reload Topo View")
        
        self.stackView.removeFromSuperview()
        self.configureStackView()
        self.updatePreview()
    }
    
    
    // MARK: - ScrollView & StackView configuration
    func configureScrollView() {
        // You simply cannot constrain a view to another view if the view isn’t even on the screen yet.
        self.bottomTopoMenuView.addSubview(self.scrollView)
        
        self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
    }
    func configureStackView() {
        
//        print("Configure Stack View")
        
        self.scrollView.addSubview(self.stackView)
        
        self.stackView.axis = .horizontal
        self.stackView.spacing = 2
        self.stackView.backgroundColor = .none
        self.stackView.distribution = .fillEqually
        //stack.alignment = .fill
        
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        
        self.stackView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        
        
        /// Delete any stack view items, if there are some
        let tempSubViews = self.stackView.arrangedSubviews
        tempSubViews.forEach{ subView in
            self.stackView.removeArrangedSubview(subView)
        }
        
        /// Add items
        for i in  0...TopologyStore.sharedInstance.totalTopologies() - 1 {
            // Setup button
            let btn = UIButton()
            btn.setBackgroundImage(TopologyStore.sharedInstance.savedTopologies[i].image, for: .normal)
            btn.addTarget(self, action: #selector(self.buttonSelectTopoAction(sender:)), for: .touchUpInside)
            btn.isEnabled = true
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.white.withAlphaComponent(0).cgColor
            btn.tag = i
            btn.widthAnchor.constraint(equalToConstant: 80).isActive = true
            
            // Add the button to the view
            self.stackView.addArrangedSubview(btn)
            
            // If i=0, set selectedTopo
            if i == 0 {
                self.selectTopo(button: btn)
            }
        }
    }
    
    func configurePreviewView() {
        self.bottomTopoMenuView.addSubview(previewView)
        
        self.previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.previewView.topAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
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
    
    func configureSelectTopoButton() {
        self.previewView.addSubview(selectTopoButton)
        
//        self.selectTopoButton.topAnchor.constraint(equalTo: self.previewImageView.topAnchor, constant: 20).isActive = true
        self.selectTopoButton.bottomAnchor.constraint(equalTo: self.previewImageView.bottomAnchor, constant: -7).isActive = true
        self.selectTopoButton.centerXAnchor.constraint(equalTo: self.previewImageView.centerXAnchor).isActive = true
        self.selectTopoButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        self.selectTopoButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func configureDeleteTopoButton() {
        self.previewView.addSubview(deleteTopoButton)
        
//        self.deleteTopoButton.topAnchor.constraint(equalTo: self.previewImageView.topAnchor, constant: 20).isActive = true
        self.deleteTopoButton.bottomAnchor.constraint(equalTo: self.previewImageView.bottomAnchor, constant: -7).isActive = true
        self.deleteTopoButton.trailingAnchor.constraint(equalTo: self.previewImageView.trailingAnchor, constant: -10).isActive = true
        self.deleteTopoButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.deleteTopoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func configureDissmissMenuButton() {
        self.previewView.addSubview(dismissMenuButton)
        
        self.dismissMenuButton.topAnchor.constraint(equalTo: self.previewImageView.topAnchor, constant: 10).isActive = true
        self.dismissMenuButton.trailingAnchor.constraint(equalTo: self.previewImageView.trailingAnchor, constant: -10).isActive = true
        self.dismissMenuButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.dismissMenuButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func configurePreviewDetailsView() {
        self.previewImageView.addSubview(previewDetailsView)
        
        self.previewDetailsView.leadingAnchor.constraint(equalTo: self.previewImageView.leadingAnchor).isActive = true
        self.previewDetailsView.topAnchor.constraint(equalTo: self.previewImageView.bottomAnchor, constant: -210).isActive = true
        self.previewDetailsView.bottomAnchor.constraint(equalTo: self.previewImageView.bottomAnchor, constant: -80).isActive = true
        self.previewDetailsView.trailingAnchor.constraint(equalTo: self.previewImageView.trailingAnchor).isActive = true
        
        previewDetailsView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    func configurePreviewTitleTextView() {
        self.previewDetailsView.addSubview(previewTitleTextView)
        
        self.previewTitleTextView.topAnchor.constraint(equalTo: self.previewDetailsView.topAnchor).isActive = true
        self.previewTitleTextView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.previewTitleTextView.leadingAnchor.constraint(equalTo: self.previewDetailsView.leadingAnchor, constant: 10).isActive = true
        self.previewTitleTextView.trailingAnchor.constraint(equalTo: self.previewDetailsView.trailingAnchor, constant: -10).isActive = true
        
        self.previewTitleTextView.text = selectedTopo?.getName().uppercased()
        self.previewTitleTextView.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.previewTitleTextView.textColor = .white
        self.previewTitleTextView.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.previewTitleTextView.textAlignment = .left
    }
    
    func configurePreviewDetailsTextView() {
        self.previewDetailsView.addSubview(previewDetailsTextView)
        
        self.previewDetailsTextView.topAnchor.constraint(equalTo: self.previewTitleTextView.bottomAnchor).isActive = true
        self.previewDetailsTextView.bottomAnchor.constraint(equalTo: self.previewDetailsView.bottomAnchor).isActive = true
        self.previewDetailsTextView.leadingAnchor.constraint(equalTo: self.previewDetailsView.leadingAnchor, constant: 10).isActive = true
        self.previewDetailsTextView.trailingAnchor.constraint(equalTo: self.previewDetailsView.trailingAnchor, constant: -10).isActive = true
        
        self.previewDetailsTextView.text = selectedTopo?.getDescription()
        self.previewDetailsTextView.font = UIFont.systemFont(ofSize: 12)
        self.previewDetailsTextView.textColor = .white
        self.previewDetailsTextView.backgroundColor = UIColor.white.withAlphaComponent(0)
    }
    
    func updatePreview() {
        
//        print("Update Preview")
        
        self.previewImageView.image = selectedTopo?.getImage()
        self.previewTitleTextView.text = selectedTopo?.getName().uppercased()
        self.previewDetailsTextView.text = selectedTopo?.getDescription().uppercased()
        
        /// If selected Topo is a default one, don't show DELETE button
        if selectedTopo?.name.hasPrefix("Default:") == true {
            self.deleteTopoButton.isEnabled = false
            self.deleteTopoButton.isHidden = true
        } else {
            self.deleteTopoButton.isEnabled = true
            self.deleteTopoButton.isHidden = false
        }
    }
    
    
    
    @objc
    func buttonLoadTopoAction(sender: UIButton!) {
//        print("Load Topo \(selectedTopo!.name)")
        
        /// Notify for new positions
        let notifName = Notification.Name(rawValue: topoNotificationKey)
        let valueDict: [String: TopologyModel] = ["updatedValue": selectedTopo!]
        NotificationCenter.default.post(name: notifName, object: nil, userInfo: valueDict)
            
        ///Dismiss the menu view
        dismiss(animated: true, completion: nil)
            
    }
    
    @objc
    func buttonDeleteTopoAction(sender: UIButton!) {
//        print("Delete Topo Action")
        
        let btnsend: UIButton = sender
            
        let totalTopologies = TopologyStore.sharedInstance.totalTopologies()
        if btnsend.tag > -1 && btnsend.tag < totalTopologies {
            
            /// Reload topologies, if not,  Object Identifiers break!  (DONT KNOW WHY)
            TopologyStore.sharedInstance.reloadSavedTopologies()
            
            /// Set the new topology
            let topoToDelete = TopologyStore.sharedInstance.savedTopologies[btnsend.tag]
    
            /// DeleteTheTopo
            TopologyStore.sharedInstance.deleteSavedTopologyFromCoreData(topology: topoToDelete)
            
            /// Reload topologies
            TopologyStore.sharedInstance.reloadSavedTopologies()
            
            /// Reload the view
            self.reloadTopoView()
        }
            
    }
    
    @objc
    func buttonSelectTopoAction(sender: UIButton!) {
        self.selectTopo(button: sender)
    }
    
    @objc
    func dismissMenu(sender:  UIButton){
        dismiss(animated: true) {
            self.notifyObserver(withKey: dismissalNotificationKey)
        }
    }
    
    private func selectTopo(button: UIButton) {
        
//        print("Select Topo")
        
        let totalTopologies = TopologyStore.sharedInstance.totalTopologies()
        if button.tag > -1 && button.tag < (totalTopologies) {
            /// Set the new topology
            self.selectedTopo = TopologyStore.sharedInstance.savedTopologies[button.tag]
            
            /// De-highlight all StackView buttons
            self.stackView.arrangedSubviews.forEach{ btn in
                btn.layer.borderColor = UIColor.white.withAlphaComponent(0).cgColor
            }
            
            /// Highlight the selected one
            button.layer.borderColor = UIColor.white.cgColor
            
            /// Update Preview Backgound Image
            self.updatePreview()
        }
    }
    
    
    // MARK: - TouchesBegan: check if touch happened outside the menu subviews
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touchView = touches.first?.view
//        var exit = true
//
//        /// If no subView is touched, dismiss
//        self.bottomTopoMenuView.subviews.forEach{ subView in
//            if touchView == subView {
//                exit = false
//            }
//        }
//        if exit == true {
//            dismiss(animated: true) {
//                self.notifyObserver(withKey: dismissalNotificationKey)
//            }
//        }
//    }
    
    private func notifyObserver(withKey key: String){
        let notifName = Notification.Name(rawValue: key)
        NotificationCenter.default.post(name: notifName, object: nil, userInfo: nil)
    }
    

}
