//
//  ViewController.swift
//  mark location
//
//  Created by Amit Shah on 17/03/24.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController {

    
    @IBOutlet weak var differenceInMetersLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var markedLocationLabel: UILabel!
    
    var locationManager: CLLocationManager?
    var markedLocation: CLLocation?
    var onceReachedMin20M = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        requestLocationUpdate()
        requestNotificationAuthorization()
    }
    
    // MARK: - Actions
    @IBAction func markLocation(_ sender: UIButton) {
        guard let currentLocation = locationManager?.location else { return }
        markedLocation = currentLocation
        updateMarkedLocationLabel()
    }
    
    // MARK: - Private Methods
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.showsBackgroundLocationIndicator = true
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func requestLocationUpdate() {
        locationManager?.startUpdatingLocation()
    }
    
    private func stopLocationUpdate() {
        locationManager?.stopUpdatingLocation()
    }
    
    private func requestNotificationAuthorization() {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    private func updateMarkedLocationLabel() {
        if let location = markedLocation {
            markedLocationLabel.text = "Latitude: \(location.coordinate.latitude),\n Longitude: \(location.coordinate.longitude)"
        }
    }
    
    private func calculateDistance(_ location1: CLLocation, _ location2: CLLocation) -> CLLocationDistance {
        return location1.distance(from: location2)
    }
    
    private func notifyUser() {
        guard let markedLocation = markedLocation, let currentLocation = locationManager?.location else { return }
        let distance = calculateDistance(markedLocation, currentLocation)
        
        if distance <= 10, onceReachedMin20M{
            sendNotification()
            onceReachedMin20M = false
        }
        
        if distance >= 20 {
            onceReachedMin20M = true
        }
        
        differenceInMetersLabel.text = String(format: "Distance: %.2f meters", distance)
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "📍 Reached your destination"
        content.body = "🍔 Check out nearby food options."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "instant_notification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error displaying notification: \(error.localizedDescription)")
            } else {
                print("Notification displayed successfully")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            self.currentLocationLabel.text = "Latitude: \(currentLocation.coordinate.latitude),\n Longitude: \(currentLocation.coordinate.longitude)"
            notifyUser()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location request failed with error: \(error.localizedDescription)")
        stopLocationUpdate()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}


struct Location {
    let latitude: Double
    let longitude: Double
}

extension Location {
    func distance(to destination: Location) -> Double {
        let earthRadius = 6371000.0 // Earth's radius in meters
        
        let lat1 = latitude * .pi / 180.0
        let lon1 = longitude * .pi / 180.0
        let lat2 = destination.latitude * .pi / 180.0
        let lon2 = destination.longitude * .pi / 180.0
        
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let distance = earthRadius * c // Distance in meters
//        let distanceInCentimeters = distance * 100 // Convert to centimeters
        
        return distance
    }
}
