//
//  LocationCell.swift
//  Uber-clone
//
//  Created by David on 1/5/21.
//

import UIKit
import MapKit

final class LocationCell: UITableViewCell {

    var placemark: MKPlacemark? {
        didSet {
            placeTitleLabel.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    private let placeTitleLabel: UILabel = {
        let placeTitleLabel = UILabel()
        placeTitleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        return placeTitleLabel
    }()
    
    private let addressLabel: UILabel = {
        let addressLabel = UILabel()
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .lightGray
        addressLabel.numberOfLines = 1
        addressLabel.lineBreakMode = .byTruncatingTail
        addressLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width-30).isActive = true
        
        return addressLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        let vStack = UIStackView(arrangedSubviews: [placeTitleLabel, addressLabel])
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 4
        
        addSubview(vStack)
        vStack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        addSubview(vStack)
    }
}
