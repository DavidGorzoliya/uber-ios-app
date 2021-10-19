//
//  AuthButton.swift
//  Uber-clone
//
//  Created by David on 1/5/21.
//

import UIKit

final class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureProperties() {
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .mainBlueTint
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
