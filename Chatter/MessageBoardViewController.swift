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

enum BackendError: Error {
  case urlError(reason: String)
  case objectSerialization(reason: String)
}

class MessageBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var message: [Message]?
    var messageWrapper: MessageWrapper? // holds the last wrapper that we've loaded
    var isLoadingSpecies = false
    @IBOutlet weak var messageTableOutlet: UITableView!
    
    var items = ["item1","item2","item3"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.messageTableOutlet.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        navigationItem.title = "Message Board"
        self.tableview?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
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

class MessageWrapper {
    var messages: [Message] = []
}

class Message {
  var content: String
    var username: String
    
  required init(json: [String: Any]) {
    self.content = json["content"] as! String
    self.username = json["username"] as! String
  }
    
    class func endpointForSpecies() -> String {
        return "http://142.93.64.49/messages"
    }
    
    private class func messageArrayFromResponse(_ response: DataResponse<Any, AFError>) -> AFResult<MessageWrapper> {
        guard response.error == nil else {
        // got an error in getting the data, need to handle it
            print(response.error!)
            return .failure(response.error!)
      }
      
      // make sure we got JSON and it's a dictionary
      guard let json = response.result.value as? [String: Any] else {
        print("didn't get species object as JSON from API")
        return .failure(BackendError.objectSerialization(reason:
          "Did not get JSON dictionary in response"))
      }
      
      let wrapper: MessageWrapper = MessageWrapper()
      
      var allMessages: [Message] = []
      if let results = json["messages"] as? [[String: Any]] {
        for message in results {
          let message = Message(json: message)
          allMessages.append(message)
        }
      }
      wrapper.messages = allMessages
      return .success(wrapper)
    }
    
    fileprivate class func getSpeciesAtPath(_ path: String, completionHandler: @escaping (Result<SpeciesWrapper>) -> Void) {
      // make sure it's HTTPS because sometimes the API gives us HTTP URLs
      guard var urlComponents = URLComponents(string: path) else {
        let error = BackendError.urlError(reason: "Tried to load an invalid URL")
        completionHandler(.failure(error))
        return
      }
      urlComponents.scheme = "https"
      guard let url = try? urlComponents.asURL() else {
        let error = BackendError.urlError(reason: "Tried to load an invalid URL")
        completionHandler(.failure(error))
        return
      }
        let _ = (Alamofire.request(url) as AnyObject)
        .responseJSON { response in
          if let error = response.result.error {
            completionHandler(.failure(error))
            return
          }
          let speciesWrapperResult = StarWarsSpecies.speciesArrayFromResponse(response)
          completionHandler(speciesWrapperResult)
      }
    }
    
    class func getSpecies(_ completionHandler: @escaping (Result<SpeciesWrapper>) -> Void) {
      getSpeciesAtPath(StarWarsSpecies.endpointForSpecies(), completionHandler: completionHandler)
    }
    
    class func getMoreSpecies(_ wrapper: SpeciesWrapper?, completionHandler: @escaping (Result<SpeciesWrapper>) -> Void) {
      guard let nextURL = wrapper?.next else {
        let error = BackendError.objectSerialization(reason: "Did not get wrapper for more species")
        completionHandler(.failure(error))
        return
      }
      getSpeciesAtPath(nextURL, completionHandler: completionHandler)
    }
    
    func loadFirstSpecies() {
      isLoadingSpecies = true
      StarWarsSpecies.getSpecies { result in
        if let error = result.error {
          // TODO: improved error handling
          self.isLoadingSpecies = false
          let alert = UIAlertController(title: "Error", message: "Could not load first species :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
          alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        }
        let speciesWrapper = result.value
        self.addSpeciesFromWrapper(speciesWrapper)
        self.isLoadingSpecies = false
        self.tableview?.reloadData()
      }
    }

    func loadMoreSpecies() {
      self.isLoadingSpecies = true
      if let species = self.species,
        let wrapper = self.speciesWrapper,
        let totalSpeciesCount = wrapper.count,
        species.count < totalSpeciesCount {
        // there are more species out there!
        StarWarsSpecies.getMoreSpecies(speciesWrapper) { result in
          if let error = result.error {
            self.isLoadingSpecies = false
            let alert = UIAlertController(title: "Error", message: "Could not load more species :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
          }
          let moreWrapper = result.value
          self.addSpeciesFromWrapper(moreWrapper)
          self.isLoadingSpecies = false
          self.tableview?.reloadData()
        }
      }
    }

    func addSpeciesFromWrapper(_ wrapper: SpeciesWrapper?) {
      self.speciesWrapper = wrapper
      if self.species == nil {
        self.species = self.speciesWrapper?.species
      } else if self.speciesWrapper != nil && self.speciesWrapper!.species != nil {
        self.species = self.species! + self.speciesWrapper!.species!
      }
    }
    
}
