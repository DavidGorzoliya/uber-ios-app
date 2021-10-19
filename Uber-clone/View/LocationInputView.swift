//
//  LocationInputView.swift
//  Uber-clone
//
//  Created by David on 1/5/21.
//

import UIKit

protocol LocationInputViewDelegate: AnyObject {
    func dismisslocationInputView()
    func executeSearch(query: String)
}

final class LocationInputView: UIView {

    weak var delegate: LocationInputViewDelegate?
    
    private let backButton: UIButton = {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "baseline_arrow_back_black_36dp-1")!.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        
        return backButton
    }()
    
     let fullnameTitleLabel: UILabel = {
        let fullnameTitleLabel = UILabel()
        fullnameTitleLabel.text = "John Doe"
        fullnameTitleLabel.font = UIFont.systemFont(ofSize: 16)
        fullnameTitleLabel.textColor = .darkGray
        
        return fullnameTitleLabel
    }()
    
    private let startLocationIndicatorView: UIView = {
        let startLocationIndicatorView = UIView()
        startLocationIndicatorView.backgroundColor = .lightGray
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6/2
        
        return startLocationIndicatorView
    }()
    
    private let linkingView: UIView = {
        let linkingView = UIView()
        linkingView.backgroundColor = .darkGray
        
        return linkingView
    }()
    
    private let destinationIndicatorView: UIView = {
        let destinationIndicatorView = UIView()
        destinationIndicatorView.backgroundColor = .black
        destinationIndicatorView.setDimensions(height: 6, width: 6)
        
        return destinationIndicatorView
    }()
    
    private lazy var startingLocationTextField: UITextField = {
        let startingLocationTextField = UITextField()
        startingLocationTextField.placeholder = "Current Location"
        startingLocationTextField.backgroundColor = .systemGroupedBackground
        startingLocationTextField.isEnabled = false
        startingLocationTextField.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        
        startingLocationTextField.leftView = paddingView
        startingLocationTextField.leftViewMode = .always
        
        return startingLocationTextField
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let destinationLocationTextField = UITextField()
        destinationLocationTextField.placeholder = "Enter a destination.."
        destinationLocationTextField.backgroundColor = .lightGray
        destinationLocationTextField.returnKeyType = .search
        destinationLocationTextField.font = UIFont.systemFont(ofSize: 14)
        destinationLocationTextField.delegate = self
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        
        destinationLocationTextField.leftView = paddingView
        destinationLocationTextField.leftViewMode = .always
        
        return destinationLocationTextField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleBackTapped() {
        delegate?.dismisslocationInputView()
    }

   private func configureUI() {
        backgroundColor = .white
        addShadow()
        
        configureSubviews()
    }
    
   private func configureSubviews() {
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 14, width: 24, height: 25)
        
        addSubview(fullnameTitleLabel)
        fullnameTitleLabel.centerY(inView: backButton)
        fullnameTitleLabel.centerX(inView: self)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(destinationLocationTextField)
        destinationLocationTextField.anchor(top: startingLocationTextField.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startingLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerY(inView: destinationLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor, bottom: destinationIndicatorView.topAnchor, paddingTop: 4, paddingBottom: 4, width: 0.5)
    }
    
}

extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        delegate?.executeSearch(query: query)
        return true
    }
}
