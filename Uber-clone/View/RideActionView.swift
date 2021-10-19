//
//  RideActionView.swift
//  Uber-clone
//
//  Created by David on 1/8/21.
//

import UIKit
import MapKit


protocol RideActionViewDelegate: AnyObject {
    func uploadTrip(_ view: RideActionView)
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case tripIntProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide:
            return "CONFIRM UBERX"
        case .cancel:
            return "CANCEL RIDE"
        case .getDirections:
            return "GET DIRECTIONS"
        case .pickup:
            return "PICKUP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

final class RideActionView: UIView {

    weak var delegate: RideActionViewDelegate?
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    var config = RideActionViewConfiguration()
    var buttonAction = ButtonAction()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Test Address Title"
        label.textAlignment = .center
        
        return label
    }()
    
    private let addressLabel: UILabel = {
        let addressLabel = UILabel()
        addressLabel.textColor = .lightGray
        addressLabel.font = UIFont.systemFont(ofSize: 16)
        addressLabel.text = "123 M St, NW Washington DC"
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 1
        addressLabel.lineBreakMode = .byTruncatingTail
        addressLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-30).isActive = true
        
        return addressLabel
    }()
    
    private lazy var infoView: UIView = {
        let infoView = UIView()
        infoView.backgroundColor = .black
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60/2
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        infoView.addSubview(label)
        label.centerX(inView: infoView)
        label.centerY(inView: infoView)
        
        return infoView
    }()
    
    private let uberXLabel: UILabel = {
        let uberXLabel = UILabel()
        uberXLabel.font = UIFont.systemFont(ofSize: 18)
        uberXLabel.text = "UberX"
        uberXLabel.textAlignment = .center
        
        return uberXLabel
    }()
    
    private lazy var actionButton: UIButton = {
        let actionButton = UIButton(type: .system)
        actionButton.backgroundColor = .black
        actionButton.setTitle("CONFIRM UBERX", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        actionButton.addTarget(self, action: #selector(rideButtonPressed), for: .touchUpInside)
        
        return actionButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func rideButtonPressed() {
        delegate?.uploadTrip(self)
    }

   private func configureUI() {
        backgroundColor = .white
        addShadow()
        configureSubviews()
    }
    
     func configureUI(withConfig: RideActionViewConfiguration) {
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            titleLabel.text = "On Route To Passsenger"
            buttonAction = .getDirections
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .pickupPassenger:
            fallthrough
        case .tripIntProgress:
            fallthrough
        case .endTrip:
            break
        }
    }

    private func configureSubviews() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 16)
        
        addSubview(uberXLabel)
        uberXLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
        uberXLabel.centerX(inView: self)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: uberXLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, height: 50)
    }
}
