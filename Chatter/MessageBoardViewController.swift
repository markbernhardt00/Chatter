//  MessageBoardControllerViewController.swift
//  Chatter

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import GoogleMaps
import GooglePlaces

class MessageBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate, UISearchBarDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var messages: [Message] = []
    var messageWrapper: MessageWrapper? // holds the last wrapper that we've loaded
    var isLoadingMessages = false
    @IBOutlet weak var messageTableOutlet: UITableView!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    var filteredData: [Message]! // array containing matching substrings to search string
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        print("tap")
        fetchMessages()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCell.CellStyle.default, reuseIdentifier:"Cell")
        cell.textLabel?.text = filteredData[indexPath.row].username! + " says: " + filteredData[indexPath.row].content!
        cell.textLabel?.numberOfLines = 10
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messages = []
        searchBarOutlet.delegate = self
        messageTableOutlet.delegate = self
        messageTableOutlet.dataSource = self
        messageTableOutlet.isUserInteractionEnabled = true
        messageTableOutlet.rowHeight = UITableView.automaticDimension
        messageTableOutlet.estimatedRowHeight = UITableView.automaticDimension
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
        filteredData = messages
    }
    
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Hide") { (contextualAction, view, boolValue) in
            print(self.messages[indexPath.row].content!)
            self.hideMessage(message: self.filteredData[indexPath.row].content!)
        }
        let replyAction = UIContextualAction(style: .normal, title: "Reply") { (contextualAction, view, boolValue) in
            print(self.messages[indexPath.row].content!)
            self.hideMessage(message: self.filteredData[indexPath.row].content!)
        }
        replyAction.backgroundColor = .black
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, replyAction])
        return swipeActions
    }
//
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let contextItem = UIContextualAction(style: .destructive, title: "Hide") { (contextualAction, view, boolValue) in
//            print(self.messages[indexPath.row].content!)
//            self.hideMessage(message: self.messages[indexPath.row].content!)
//        }
//        contextItem.backgroundColor = .black
//        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
//        return swipeActions
//    }
    
    
    
    func hideMessage(message: String) {
        let parameters: [String: String] = [
            "username" : loggedInUser,
            "message_content": message
        ]
        print(parameters)
        AF.request(Message.endpointForHideMessage(), method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
        .responseString { response in
            switch response.result {
            case .success:
                print("Successfully hid " + message)
                self.fetchMessages()
            case let .failure(error):
                let alert = UIAlertController(title: "Error", message: "Failed to hide message", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
                self.present(alert, animated: true)
                print(error)
            }
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? messages : messages.filter { (item: Message) -> Bool in
            // If dataItem matches the searchText, return true to include it
            print("Filtering")
            print(item.content!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil)
            return item.content!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil || item.username!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        messageTableOutlet.reloadData()
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
    
        AF.request(Message.endpointForMessages() + "?location=\(longitude),\(latitude)&username=\(loggedInUser)")
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
        searchBarOutlet.text = ""
        filteredData = messages
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





