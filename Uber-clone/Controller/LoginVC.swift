//
//  LoginVC.swift
//  Uber-clone
//
//  Created by David on 1/5/21.
//

import UIKit
import Firebase

 final class LoginVC: UIViewController {

    private let logoLabel: UILabel = {
        let logoLabel = UILabel()
        logoLabel.text = "UBER"
        logoLabel.font = UIFont(name: "Avenir-Light", size: 36)
        logoLabel.textColor = UIColor(white: 1, alpha: 0.8)
        
        return logoLabel
    }()
    
    private lazy var emailContainerView: UIView = {
        let emailContainerView = UIView().inputContainerView(image: UIImage(named: "ic_mail_outline_white_2x")!, textField: emailTextField)
        emailContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return emailContainerView
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private lazy var passwordContainerView: UIView = {
        let passwordContainerView = UIView().inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x")!, textField: passwordTextField)
        passwordContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return passwordContainerView
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let loginButton: AuthButton = {
        let loginButton = AuthButton(type: .system)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return loginButton
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let dontHaveAccountButton = UIButton(type: .system)
        
        let dontHaveAccountAttributedText = NSMutableAttributedString(string: "Don't have an account?  ",
                                                                      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                                         NSAttributedString.Key.foregroundColor: UIColor.lightGray
                                                                ])
        dontHaveAccountAttributedText.append(NSAttributedString(string: "Sign Up",
                                                                attributes: [NSAttributedString.Key.font:         UIFont.boldSystemFont(ofSize: 16),
                                                                         NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint
                                                                ]))
        dontHaveAccountButton.setAttributedTitle(dontHaveAccountAttributedText, for: .normal)
        dontHaveAccountButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return dontHaveAccountButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        configureUI()
    }

    @objc private func handleShowSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to log user in with error \(error.localizedDescription)")
                return
            }
            
            guard let homeVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? HomeVC else { return }
            homeVC.configure()
            self.dismiss(animated: true, completion: nil)
        }
    }

   private func configureSubviews() {
        view.addSubview(logoLabel)
        logoLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        logoLabel.centerX(inView: view)
        
        let vStack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 24
        
        view.addSubview(vStack)
        vStack.anchor(top: logoLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        configureNavBar()
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}
