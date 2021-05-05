//
//  CoulombMenu.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 27/6/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import UIKit

class CoulombMenuVC: UIViewController {
    
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
    
    let text: UILabel = {
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
    
    let trashButton: UIButton = {
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    // MARK: - Properties
    
    let step: Float = 0.5
    
    @IBOutlet var coulombMenuView: UIView!
    
    var initialCoulombValue: Float = selectedPointChargeObj.value
    
    var viewController: ViewController?
    
    // MARK: - On Load Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coulombMenuView.addSubview(tabView)
        
        self.configureTabView()
        self.configureStackView_V()
        self.configureTextLabel(coulombValue: initialCoulombValue)
        self.configureSlider(coulombValue: initialCoulombValue)
        self.configureButtons()
        self.configureStackView_H()
        
        coulombMenuView.addSubview(trashButton)
        
        self.configureTrashButton()
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
    
    func configureTextLabel(coulombValue: Float) {
        text.heightAnchor.constraint(equalToConstant: 20).isActive = true
        text.text = "\(coulombValue) Cb"
        text.textColor = .white
        text.font = UIFont.systemFont(ofSize: 25)
        
        vStackView.addArrangedSubview(text)
    }
    
    func configureStackView_H() {
        vStackView.addArrangedSubview(hStackView)
        
        hStackView.axis = .horizontal
        hStackView.spacing = 5
        // hStackView.distribution = .fillEqually
        hStackView.alignment = .center
        
        hStackView.addArrangedSubview(btns[0])
        hStackView.addArrangedSubview(self.slider)
        hStackView.addArrangedSubview(btns[1])
    }
    
    func configureSlider(coulombValue: Float) {
        self.slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
        self.slider.minimumValue = -100
        self.slider.maximumValue = 100
        self.slider.isContinuous = true
        self.slider.tintColor = .white
        self.slider.thumbTintColor = .white
        self.slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        self.slider.setValue(coulombValue, animated: true)
    }
    
    func configureButtons() {
        for i in 0...1 {
            let btn = UIButton()
            if i == 0 {
                btn.setTitle("-", for: .normal)
            } else {
                btn.setTitle("+", for: .normal)
            }
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            btn.addTarget(self, action: #selector(self.sliderButtonAction(sender:)), for: .touchUpInside)
            btn.isEnabled = true
            btn.tag = i
            btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
            btns.append(btn)
        }
    }
    
    func configureTrashButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        
        let image = UIImage(systemName: "trash", withConfiguration: config)
        
        trashButton.setImage(image, for: .normal)
        
        let padding: CGFloat = 8.0
        
        self.trashButton.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        self.trashButton.addTarget(self, action: #selector(performDeletion(sender:)), for: .touchUpInside)
        self.trashButton.layer.cornerRadius = 10
        self.trashButton.backgroundColor = UIColor(white: 0, alpha: 0.7)
        self.trashButton.tintColor = UIColor.white
        self.trashButton.isEnabled = true
        
        self.trashButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        self.trashButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
    }
    
    // MARK: - OBJC Action Functions
    
    @objc
    func sliderButtonAction(sender: UIButton) {
        if sender.tag == 0 {
            if (slider.value > slider.minimumValue) {
                updateSlider(constant: -step)
            }
        } else if sender.tag == 1 {
            if (slider.value < slider.maximumValue) {
                updateSlider(constant: step)
            }
        }
    }
    
    @objc
    func sliderValueDidChange(_ sender: UISlider!) {
        let roundedStepValue = round(sender.value / step) * step
        slider.value = roundedStepValue
        
        updateSlider(constant: 0)
    }
    
    @objc
    func performDeletion(sender: UIButton) {
        dismiss(animated: true) {
            self.notifyObserver(withKey: removalNotificationKey)
        }
    }
    
    // MARK: - TouchesBegan: check if touch happened outside the menu subviews
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchView = touches.first?.view
        var exit = true
        
        /// If no subView is touched, dismiss
        coulombMenuView.subviews.forEach{ subView in
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
    
    // MARK: - Used-over code in one function (when slider changes value)
    
    private func updateSlider(constant: Float) {
        slider.setValue(slider.value + constant, animated: true)
        textUpdate(sliderValue: slider.value)
        
        /// Notify Coulomb Value Change Observer
        notifyObserver(withKey: cbNotificationKey, value: slider.value)
    }
    
    private func textUpdate(sliderValue: Float) {
        let newText = "\(sliderValue) Cb"
        text.text = newText
    }
    
    private func notifyObserver(withKey key: String, value: Float){
        let notifName = Notification.Name(rawValue: key)
        let valueDict: [String: Float] = ["updatedValue": value]
        NotificationCenter.default.post(name: notifName, object: nil, userInfo: valueDict)
    }
    
    private func notifyObserver(withKey key: String){
        let notifName = Notification.Name(rawValue: key)
        NotificationCenter.default.post(name: notifName, object: nil, userInfo: nil)
    }
}
