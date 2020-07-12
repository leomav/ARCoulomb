//
//  BottomPopUpTopologies.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

class BottomTopo_ViewController: UIViewController {
    
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
        
        bottomTopoMenuView.backgroundColor = UIColor(white: 0, alpha: 0.7)

        // Do any additional setup after loading the view.
        bottomTopoMenuView.addSubview(scrollView)
        
        self.configureScrollView()
        self.configureStackView()
    }
    
    
    // MARK: - ScrollView & StackView configuration
    func configureScrollView() {
        // You simply cannot constrain a view to another view if the view isn’t even on the screen yet.
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
    func configureStackView() {
        scrollView.addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        //stack.alignment = .fill
        
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        // Create the buttons in the scroll-stack view, one for each topology
        for i in 0...5 {
            let btn = UIButton()
            btn.setBackgroundImage(UIImage(named: "kobe"), for: .normal)
            btn.addTarget(self, action: #selector(self.buttonAction(sender:)), for: .touchUpInside)
            btn.isEnabled = true
            btn.tag = i + 1
            btn.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            // Add the button to the view
            stackView.addArrangedSubview(btn)
        }
        
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let btnsend: UIButton = sender
        if btnsend.tag > 0 && btnsend.tag < 7 {
            
            // Set the new topology (new positions)
            let pos = defaultPositions[btnsend.tag]!
            
            // Notify for new positions
            let notifName = Notification.Name(rawValue: topoNotificationKey)
            let valueDict: [String: [SIMD3<Float>]] = ["updatedValue": pos]
            NotificationCenter.default.post(name: notifName, object: nil, userInfo: valueDict)
            
            //Dismiss the menu view
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    

}
