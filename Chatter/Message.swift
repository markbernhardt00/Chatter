//
//  Message.swift
//  Chatter
//
//  Created by Mark Bernhardt on 11/5/19.
//

import Foundation

enum MessageFields: String {
  case Username = "username"
  case Content = "content"
}

class MessageWrapper {
  var messages: [Message]?
  var count: Int?
}

class Message {
  var username: String?
  var content: String?
  
    required init(username: String, content: String) {
        self.username = username
    self.content = content
  }

    class func endpointForMessages() -> String {
        return "http://142.93.64.49/messages"
    }
    class func endpointForHideMessage() -> String {
        return "http://142.93.64.49/messages/hide_message"
    }

}
