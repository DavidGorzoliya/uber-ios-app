//
//  HomeVC.swift
//  Uber-clone
//
//  Created by David on 1/5/21.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

 final class HomeVC: UIViewController {

    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private let locationInputViewHeight: CGFloat = 200
    private let rideActionViewHeight: CGFloat = 300
    private var actionButtonConfiguration = ActionButtonConfiguration()
    private var route: MKRoute?
    
    private var user: User? {
        didSet {
            locationInputView.fullnameTitleLabel.text = user?.fullname
            if user?.accountType == .passenger {
                fetchDrivers()
                configureInputActivationView()
                observeCurrentTrip()
            } else {
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else { return }
                let pickupController = PickupVC(trip: trip)
                pickupController.delegate = self
                pickupController.modalPresentationStyle = .fullScreen
                self.present(pickupController, animated: true, completion: nil)
            } else {
                print("DEBUG: Show ride action view for accepted trip")
            }
        }
    }
    
    private let actionButton: UIButton = {
        let actionButton = UIButton(type: .system)
        actionButton.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        
        return actionButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserLoggedIn()
        enableLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.userTrackingMode = .follow
    }

    @objc private func actionButtonPressed() {
        switch actionButtonConfiguration {
        case .showMenu:
            print("DEBUG: Handle show menu..")
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.presentRideActionView(shouldShow: false)
            }
            
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }

    private func observeCurrentTrip() {
        Service.shared.observeCurrentTrip { trip in
            self.trip = trip
            
            if trip.state == .accepted {
                self.shouldPresentLoadingView(false)
                
                self.presentRideActionView(shouldShow: true, config: .tripAccepted)
            }
        }
    }
    
   private func fetchUserData() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUID) { user in
            self.user = user
        }
    }
    
   private func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { annotation -> Bool in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == driver.uid {
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func observeTrips() {
        Service.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    private func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let navLogin = UINavigationController(rootViewController: LoginVC())
                navLogin.modalPresentationStyle = .fullScreen
                self.present(navLogin, animated: false, completion: nil)
            }
        } else {
            configure()
        }
    }
    
   private func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let navLogin = UINavigationController(rootViewController: LoginVC())
                navLogin.modalPresentationStyle = .fullScreen
                self.present(navLogin, animated: true, completion: nil)
            }
        } catch {
            print("DEBUG: Error signing out")
        }
    }

     func configure() {
        rideActionView.delegate = self
        
        configureUI()
        fetchUserData()
    }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfiguration = .showMenu
        case .dismissActionView:
            actionButton.setImage(UIImage(named: "baseline_arrow_back_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfiguration = .dismissActionView
        }
    }
    
    private func configureUI() {
        configureMapView()
        
        view.backgroundColor = .red
        
        locationInputView.alpha = 0
        locationInputView.delegate = self
        
        configureSubviews()
        configureTableView()
    }
    
    private func configureSubviews() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        view.addSubview(tableView)
        
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
   private func configureMapView() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
    }
    
    private func configureInputActivationView() {
        inputActivationView.delegate = self
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width-64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.inputActivationView.alpha = 1
        }
    }
    
   private func showLocationInputView() {
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            })
        }
    }
    
    private func hideLocationInputView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }, completion: completion)
    }
    
    private func presentRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { return }
            rideActionView.configureUI(withConfig: config)
            
            guard let destination = destination else { return }
            rideActionView.destination = destination
        }

    }
    
}

private extension HomeVC {
    func searchBy(naturalLanguageQuery: String, completion: @escaping ([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach { item in
                results.append(item.placemark)
            }
            
            completion(results)
        }
    }
    
    private func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    private func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { annotation in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}

extension HomeVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

extension HomeVC {
    func enableLocationServices() {
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .none:
            break
        @unknown default:
            break
        }
    }
    
}

extension HomeVC: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        showLocationInputView()
    }
}

extension HomeVC: LocationInputViewDelegate {
     func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { results in
            self.searchResults = results
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
     func dismisslocationInputView() {
        hideLocationInputView { _ in
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Recent" : "Found"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideLocationInputView()
        let selectedPlacemark = searchResults[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedPlacemark.coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: true)
        
        let annotations = self.mapView.annotations.filter{ !$0.isKind(of: DriverAnnotation.self) }
        self.mapView.zoomToFit(annotations: annotations)
        
        view.endEditing(true)
        
        self.presentRideActionView(shouldShow: true, destination: selectedPlacemark, config: .requestRide)
    }
}

extension HomeVC: RideActionViewDelegate {
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a ride..")
        
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (err, ref) in
            if let error = err {
                print("DEBUG: Failed to upload trip with error \(error)")
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
}

extension HomeVC: PickupVCDelegate {
    func didAcceptTrip(_ trip: Trip) {
        
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
        self.dismiss(animated: true) {
            self.presentRideActionView(shouldShow: true, config: .tripAccepted)
        }
    }
}
