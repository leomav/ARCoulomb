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
    
    
    @IBOutlet var bottomTopoMenuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomTopoMenuView.backgroundColor = UIColor(white: 0, alpha: 0.7)

        // Do any additional setup after loading the view.
        
        self.configureScrollView()
        self.configureStackView()
    }
    
    
    // MARK: - ScrollView & StackView configuration
    func configureScrollView() {
        self.bottomTopoMenuView.addSubview(self.scrollView)
        
        // You simply cannot constrain a view to another view if the view isn’t even on the screen yet.
        self.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
    func configureStackView() {
        self.scrollView.addSubview(self.stackView)
        
        self.stackView.axis = .horizontal
        self.stackView.spacing = 8
        self.stackView.backgroundColor = .white
        self.stackView.distribution = .fillEqually
        //stack.alignment = .fill
        
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        
        self.stackView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        
        // Create the buttons in the scroll-stack view, one for each topology
        for i in 0...5 {
            let btn = UIButton()
            btn.setBackgroundImage(UIImage(named: "kobe"), for: .normal)
            btn.addTarget(self, action: #selector(self.buttonAction(sender:)), for: .touchUpInside)
            btn.isEnabled = true
            btn.tag = i + 1
            btn.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            // Add the button to the view
            self.stackView.addArrangedSubview(btn)
        }
    }
    
    @objc
    func buttonAction(sender: UIButton!) {
        let btnsend: UIButton = sender
        if btnsend.tag > 0 && btnsend.tag < 7 {
            
            /// Set the new topology (new positions)
            let pos = defaultPositions[btnsend.tag]!
            
            /// Notify for new positions
            let notifName = Notification.Name(rawValue: topoNotificationKey)
            let valueDict: [String: [SIMD3<Float>]] = ["updatedValue": pos]
            NotificationCenter.default.post(name: notifName, object: nil, userInfo: valueDict)
            
            ///Dismiss the menu view
            dismiss(animated: true, completion: nil)
            
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
