//
//  SignUpVC.swift
//  Uber-clone
//
//  Created by David on 1/5/21.
//

import UIKit
import Firebase
import GeoFire

final class SignUpVC: UIViewController {
    
    // MARK: - Properties
    
    private var location  = LocationHandler.shared.locationManager.location
    
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
    
    private lazy var fullnameContainerView: UIView = {
        let fullnameContainerView = UIView().inputContainerView(image: UIImage(named: "ic_person_outline_white_2x")!, textField: fullnameTextField)
        fullnameContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return fullnameContainerView
    }()
    
    private let fullnameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Fullname", isSecureTextEntry: false)
    }()
    
    private lazy var passwordContainerView: UIView = {
        let passwordContainerView = UIView().inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x")!, textField: passwordTextField)
        passwordContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return passwordContainerView
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let accountTypeContainerView = UIView().inputContainerView(image: UIImage(named: "ic_account_box_white_2x")!, segmentedControl: accountTypeSegmentedControl)
        accountTypeContainerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        return accountTypeContainerView
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let accountTypeSegmentedControl = UISegmentedControl(items: ["Rider", "Driver"])
        accountTypeSegmentedControl.backgroundColor = .backgroundColor
        accountTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.87)], for: .normal)
        accountTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        accountTypeSegmentedControl.selectedSegmentIndex = 0
        
        return accountTypeSegmentedControl
    }()
    
    private let signUpButton: AuthButton = {
        let signUpButton = AuthButton(type: .system)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        return signUpButton
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let alreadyHaveAccountButton = UIButton(type: .system)
        
        let alreadyHaveAccountAttributedText = NSMutableAttributedString(string: "Already have an account? ",
                                                                      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                                         NSAttributedString.Key.foregroundColor: UIColor.lightGray
                                                                ])
        alreadyHaveAccountAttributedText.append(NSAttributedString(string: "Sign In",
                                                                     attributes: [NSAttributedString.Key.font:       UIFont.boldSystemFont(ofSize: 16),
                                                                         NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint
                                                                ]))
        alreadyHaveAccountButton.setAttributedTitle(alreadyHaveAccountAttributedText, for: .normal)
        alreadyHaveAccountButton.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        return alreadyHaveAccountButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        configureUI()
    }

    @objc private func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (result , error) in
            if let error = error {
                print("DEBUG: Failed to register user with error \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email": email,
                          "fullname": fullname,
                          "accountType": accountTypeIndex] as [String : Any]
            
            if accountTypeIndex == 1 {
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self.location else { return }
                
                geofire.setLocation(location, forKey: uid) { (error) in
                    self.uploadUserDataAndShowHomeVC(uid: uid, values: values)
                }
            }

            self.uploadUserDataAndShowHomeVC(uid: uid, values: values)
        }
    }

    func uploadUserDataAndShowHomeVC(uid: String, values: [String: Any]) {
        REF_USERS.child(uid).updateChildValues(values) { (error, ref) in
            guard let homeVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? HomeVC else { return }
            homeVC.configure()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
   private func configureSubviews() {
        view.addSubview(logoLabel)
        logoLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        logoLabel.centerX(inView: view)
        
        let vStack = UIStackView(arrangedSubviews: [emailContainerView, fullnameContainerView, passwordContainerView, accountTypeContainerView, signUpButton])
        vStack.axis = .vertical
        vStack.distribution = .equalCentering
        vStack.spacing = 12
        
        view.addSubview(vStack)
        vStack.anchor(top: logoLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
    }
}
