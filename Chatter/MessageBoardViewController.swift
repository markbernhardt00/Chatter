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

class MessageBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
      
    var messages: [Message] = []
    var messageWrapper: MessageWrapper? // holds the last wrapper that we've loaded
    var isLoadingMessages = false
    @IBOutlet weak var messageTableOutlet: UITableView!
    
    var items = ["item1","item2","item3"]

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCell.CellStyle.default, reuseIdentifier:"Cell")
        cell.textLabel?.text = messages[indexPath.row].content! + " via " + messages[indexPath.row].username!
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMessages()
        // Do any additional setup after loading the view.
        navigationItem.title = "Message Board"
        self.messageTableOutlet.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    func fetchMessages() {
        items = []
        AF.request(Message.endpointForMessages())
            .validate(statusCode: 200..<400)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                 print("Data: \(utf8Text)") // original server data as UTF8 string
                 do{
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
