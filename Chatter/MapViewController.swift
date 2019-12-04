//
//  MapViewController.swift
//  Chatter
//
//  Created by Mark Bernhardt on 12/1/19.
//  Copyright © 2019 Michael Ruck. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

var messageCoords: [[Double]] = []

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 17.0
    var path = GMSMutablePath()
    var polygon = GMSPolygon()
    var pathCoords: [CLLocationCoordinate2D] = []

    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: 30.2297, longitude: -97.7539)
    
    @IBOutlet weak var mapHolder: UIView!
    override func viewDidLoad() {
      super.viewDidLoad()
        

      // Initialize the location manager.
      locationManager = CLLocationManager()
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestAlwaysAuthorization()
      locationManager.distanceFilter = 0
      locationManager.startUpdatingLocation()
      locationManager.delegate = self

      placesClient = GMSPlacesClient.shared()

      // Create a map.
      let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                            longitude: defaultLocation.coordinate.longitude,
                                            zoom: zoomLevel)
      mapView = GMSMapView.map(withFrame: mapHolder.bounds, camera: camera)
      mapView.settings.myLocationButton = true
      mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      mapView.isMyLocationEnabled = true
        mapView.delegate = self


      // Add the map to the view, hide it until we've got a location update.
        mapHolder.addSubview(mapView)
        mapView.isHidden = true
    }
    
    
    @IBAction func clear(_ sender: UIButton) {
        path.removeAllCoordinates()
        mapView.clear()
        pathCoords.removeAll()
        polygon.map = nil
    }
    @IBAction func previewPolyline(_ sender: UIButton) {
        polygon.map = nil
        polygon = GMSPolygon(path: path)
        polygon.strokeWidth = 3
        polygon.strokeColor = UIColor.red
        polygon.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
      print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        pathCoords.append(coordinate)
        path.add(coordinate)
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
    }
    
    @IBAction func submitLocation(_ sender: UIButton) {
        messageCoords.removeAll()
        for coord in pathCoords {
            var inner: [Double] = []
            inner.append(coord.longitude)
            inner.append(coord.latitude)
            messageCoords.append(inner)
        }
        // Polygons must close on themselves.. weird.
        if (!pathCoords.isEmpty) {
            let closingCoord = [pathCoords[0].longitude, pathCoords[0].latitude]
            messageCoords.append(closingCoord)
            performSegue(withIdentifier: "mapToPostSegue", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Specify a location!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        print(messageCoords)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {

  // Handle incoming location events.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location: CLLocation = locations.last!
    print("Location: \(location)")

    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude,
                                          zoom: zoomLevel)

    if mapView.isHidden {
      mapView.isHidden = false
      mapView.camera = camera
    } else {
      mapView.animate(to: camera)
    }
  }

  // Handle authorization for the location manager.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .restricted:
      print("Location access was restricted.")
    case .denied:
      print("User denied access to location.")
      // Display the map using the default location.
      mapView.isHidden = false
    case .notDetermined:
      print("Location status not determined.")
    case .authorizedAlways: fallthrough
    case .authorizedWhenInUse:
      print("Location status is OK.")
    @unknown default:
      fatalError()
    }
  }

  // Handle location manager errors.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    print("Error: \(error)")
  }
}
