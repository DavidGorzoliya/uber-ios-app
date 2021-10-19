//
//  PickupVC.swift
//  Uber-clone
//
//  Created by David on 1/9/21.
//

import UIKit
import MapKit

protocol PickupVCDelegate: AnyObject {
    func didAcceptTrip(_ trip: Trip)
}

final class PickupVC: UIViewController {

    weak var delegate: PickupVCDelegate?
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius = 268 / 2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        
        return cp
    }()

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270/2
        
        return mapView
    }()
    
    let trip: Trip
    
    private let cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(named: "baseline_clear_white_36pt_2x")?.withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        
        return cancelButton
    }()
    
    private let pickupLabel: UILabel = {
        let pickupLabel = UILabel()
        pickupLabel.text = "Would you like to pickup this passenger?"
        pickupLabel.font = UIFont.systemFont(ofSize: 16)
        pickupLabel.textColor = .white
        
        return pickupLabel
    }()
    
    private let acceptTripButton: UIButton = {
        let acceptTripButton = UIButton(type: .system)
        acceptTripButton.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        acceptTripButton.backgroundColor = .white
        acceptTripButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        acceptTripButton.setTitleColor(.black, for: .normal)
        acceptTripButton.setTitle("ACCEPT TRIP", for: .normal)
        
        return acceptTripButton
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
        configureUI()
        configureMapView()
    }
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 10, value: 0) {
            
        }
    }
    
    @objc private func handleAcceptTrip() {
        Service.shared.acceptTrip(trip: trip) { (error, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }

   private func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
   private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        configureSubviews()
    }
    
    private func configureSubviews() {
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16)
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.centerX(inView: view)
        circularProgressView.centerY(inView: view, constant: -182)
        
        view.addSubview(mapView)
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -150)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 60)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
}
