//
//  LocationInputActivationView.swift
//  Uber-clone
//
//  Created by David on 1/5/21.
//

import UIKit

protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

final class LocationInputActivationView: UIView {

    weak var delegate: LocationInputActivationViewDelegate?
    
    private let indicatorView: UIView = {
        let indicatorView = UIView()
        indicatorView.backgroundColor = .black
        indicatorView.setDimensions(height: 6, width: 6)
        
        return indicatorView
    }()
    
    private let placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Where to?"
        placeholderLabel.font = UIFont.systemFont(ofSize: 18)
        placeholderLabel.textColor = .darkGray
        
        return placeholderLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let inputLocationTap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(inputLocationTap
        )
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func presentLocationInputView() {
        delegate?.presentLocationInputView()
    }

  private func configureUI() {
        backgroundColor = .white
        addShadow()
        
        configureSubviews()
    }
    
    private func configureSubviews() {
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
    }
}
