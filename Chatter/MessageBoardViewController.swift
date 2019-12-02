//
//  MessageBoardControllerViewController.swift
//  Chatter
//
//  Created by Michael Ruck on 11/5/19.
//  Copyright © 2019 Michael Ruck. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import GoogleMaps
import GooglePlaces

class MessageBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var messages: [Message] = []
    var messageWrapper: MessageWrapper? // holds the last wrapper that we've loaded
    var isLoadingMessages = false
    @IBOutlet weak var messageTableOutlet: UITableView!
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        print("tap")
        fetchMessages()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCell.CellStyle.default, reuseIdentifier:"Cell")
        cell.textLabel?.text = messages[indexPath.row].content! + " via " + messages[indexPath.row].username!
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messages = []
        messageTableOutlet.isUserInteractionEnabled = true
        fetchMessages()
        // Do any additional setup after loading the view.
        navigationItem.title = loggedInUser + "'s Board"
        self.messageTableOutlet.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 0
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func fetchMessages() {
        guard let latitude = locationManager.location?.coordinate.latitude else {
            print("failed to retrieve location")
            return
        }
        guard let longitude = locationManager.location?.coordinate.longitude else {
            print("failed to retrieve location")
            return
        }
        let currentLocation = [longitude, latitude]
        print("CURRENT LAT/LONG")
        print(currentLocation)
    
        AF.request(Message.endpointForMessages() + "?location=\(longitude),\(latitude)")
            .validate(statusCode: 200..<400)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                 print("Data: \(utf8Text)") // original server data as UTF8 string
                 do{
                    self.messages = []
                      // Get json data
                     let json = try JSON(data: data)
                     // Loop sub-json countries array
                     for (_, subJson) in json {
                         // Display country name
                        if let name = subJson["username"].string, let content = subJson["content"].string {
                             print("username: \(name)");
                            print("content: \(content)");
                            let message = Message(username: name, content: content)
                            self.messages.append(message)
                            print(self.messages)
                         }
                     }
                    self.messages.reverse()
                    self.messageTableOutlet.reloadData()
                }catch{
                     print("Unexpected error: \(error).")
                 }
        }
    }
}
}

// Delegates to handle events for the location manager.
extension MessageBoardViewController: CLLocationManagerDelegate {

  // Handle incoming location events.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location: CLLocation = locations.last!
    print("Location: \(location)")
  }

  // Handle authorization for the location manager.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .restricted:
      print("Location access was restricted.")
    case .denied:
      print("User denied access to location.")
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





