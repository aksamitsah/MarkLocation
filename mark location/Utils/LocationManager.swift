//
//  LocationManager.swift
//  mark location
//
//  Created by Amit Shah on 17/03/24.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private var locationManager = CLLocationManager()
    private var targetLocation: CLLocation?
    private var monitoredRegion: CLCircularRegion?
    private var isMonitoring = false
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startMonitoring(latitude: Double, longitude: Double) {
        targetLocation = CLLocation(latitude: latitude, longitude: longitude)
        guard let targetLocation = targetLocation else { return }
        let region = CLCircularRegion(center: targetLocation.coordinate, radius: 100, identifier: "targetRegion")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        locationManager.startMonitoring(for: region)
        monitoredRegion = region
        isMonitoring = true
    }
    
    func stopMonitoring() {
        if let region = monitoredRegion {
            locationManager.stopMonitoring(for: region)
            monitoredRegion = nil
            isMonitoring = false
        }
    }
    
    func getCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.delegate = LocationDelegateWrapper(completion: completion)
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // Authorization status will be checked again when authorization status changes
        case .restricted, .denied:
            // Handle restricted or denied authorization
            completion(nil)
        @unknown default:
            completion(nil)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == "targetRegion" {
            // Send location or trigger your action here
            print("Entered target location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Optionally handle exit event if needed
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            // Authorization granted, request location
            locationManager.requestLocation()
        case .notDetermined:
            // Authorization not yet determined, wait for further action
            break
        case .restricted, .denied:
            // Handle restricted or denied authorization
            break
        @unknown default:
            break
        }
    }
}

class LocationDelegateWrapper: NSObject, CLLocationManagerDelegate {
    let completion: (CLLocation?) -> Void
    
    init(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completion(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        completion(nil)
    }
}

// Usage:

// To stop monitoring
// LocationManager.shared.stopMonitoring()


// Usage:

// Start monitoring for a specific location
//LocationManager.shared.startMonitoring(latitude: 37.7749, longitude: -122.4194)

// Get current location
//LocationManager.shared.getCurrentLocation { location in
//    if let location = location {
//        print("Current location: \(location)")
//    } else {
//        print("Failed to get current location")
//    }
//}

// To stop monitoring
// LocationManager.shared.stopMonitoring()
