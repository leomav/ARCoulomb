//
//  CoulombMenu.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

class CoulombMenu: UIViewController {
    
    // MARK: - Views
    
    let vStackView: UIStackView = {
        let stack = UIStackView()
        
        return stack
    }()
    
    let hStackView: UIStackView = {
        let stack = UIStackView()
        
        return stack
    }()
    
    let tabView: UIView = {
        let tab = UIView()
        tab.translatesAutoresizingMaskIntoConstraints = false
        
        return tab
    }()
    
    var text: UILabel = {
        let text = UILabel()
        
        return text
    }()
    
    let sliderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        
        return slider
    }()
    
    var btns: [UIButton] = {
        let btns: [UIButton] = []
        
        return btns
    }()
    
    // MARK: - Properties
    
    let step: Float = 0.5
    
    var coulombValue: Float = 0
    
    @IBOutlet public var coulombMenuView: UIView!
    
    // MARK: - On Load Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coulombMenuView.addSubview(tabView)
        
        self.configureTabView()
        self.configureStackView_V()
        self.configureTextLabel()
        self.configureSlider()
        self.configureButtons()
        self.configureStackView_H()
        
    }
    
    // MARK: - ViewsSetup Functions
    
    func configureTabView() {
        tabView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tabView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -150).isActive = true
        tabView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tabView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        tabView.backgroundColor = UIColor(white: 0, alpha: 0.7)
    }
    
    func configureStackView_V() {
        tabView.addSubview(vStackView)
        
        vStackView.axis = .vertical
        vStackView.spacing = 20
        vStackView.distribution = .fillEqually
        vStackView.alignment = .center
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        
        vStackView.leadingAnchor.constraint(equalTo: tabView.leadingAnchor).isActive = true
        vStackView.trailingAnchor.constraint(equalTo: tabView.trailingAnchor).isActive = true
        vStackView.centerYAnchor.constraint(equalTo: tabView.centerYAnchor).isActive = true
    }
    
    func configureTextLabel() {
        text.heightAnchor.constraint(equalToConstant: 20).isActive = true
        text.text = "0 Cb"
        text.textColor = .white
        text.font = UIFont.systemFont(ofSize: 25)
        
        vStackView.addArrangedSubview(text)
    }
    
    func configureStackView_H() {
        vStackView.addArrangedSubview(hStackView)
        
        hStackView.axis = .horizontal
        hStackView.spacing = 5
//        hStackView.distribution = .fillEqually
        hStackView.alignment = .center
        
        hStackView.addArrangedSubview(btns[0])
        hStackView.addArrangedSubview(slider)
        hStackView.addArrangedSubview(btns[1])
    }
    
    func configureSlider() {
        slider.heightAnchor.constraint(equalToConstant: 20).isActive = true
        slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
        slider.setValue(0, animated: true)
        slider.minimumValue = -100
        slider.maximumValue = 100
        slider.isContinuous = true
        slider.tintColor = .white
        slider.thumbTintColor = .white
        slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
    }
    
    func configureButtons() {
        for i in 0...1 {
            let btn = UIButton()
            if i == 0 {
                btn.setTitle("-", for: .normal)
            } else {
                btn.setTitle("+", for: .normal)
            }
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            btn.addTarget(self, action: #selector(self.buttonAction(sender:)), for: .touchUpInside)
            btn.isEnabled = true
            btn.tag = i
            btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
//            btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
            btns.append(btn)
        }
    }
    
    
    // MARK: - OBJC Action Functions
    
    @objc func buttonAction(sender: UIButton) {
        if sender.tag == 0 {
            print("-")
            if (slider.value > slider.minimumValue) {
                slider.setValue(slider.value - 0.5, animated: true)
                textUpdate(sliderValue: slider.value)
            }
        } else if sender.tag == 1 {
            print("+")
            if (slider.value < slider.maximumValue) {
                slider.setValue(slider.value + 0.5, animated: true)
                textUpdate(sliderValue: slider.value)

            }
        }
    }
    
    @objc func sliderValueDidChange(_ sender: UISlider!) {
        let roundedStepValue = round(sender.value / step) * step
        sender.value = roundedStepValue
        textUpdate(sliderValue: slider.value)
    }
    
    // Check if touch occured outside the tabView, if so, dismiss the view
    // and go back to the mainView (arView)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchView = touches.first?.view
        var exit = false
        
        coulombMenuView.subviews.forEach{ subView in
            if touchView == subView {
                exit = true
            }
        }
        if exit == false {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Used over code in one function (when slider changes value)
    func textUpdate(sliderValue: Float) {
        let newText = "\(sliderValue) Cb"
        text.text = newText
        
        let notifName = Notification.Name(rawValue: cbNotificationKey)
        let valueDict: [String: Float] = ["updatedValue": sliderValue]
        NotificationCenter.default.post(name: notifName, object: nil, userInfo: valueDict)
    }
    
    
}
