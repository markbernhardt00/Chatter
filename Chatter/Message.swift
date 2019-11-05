import Foundation
import Alamofire

enum BackendError: Error {
  case urlError(reason: String)
  case objectSerialization(reason: String)
}

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
  
  required init(json: [String: Any]) {
    self.username = json[MessageFields.Username.rawValue] as? String
    self.content = json[MessageFields.Content.rawValue] as? String
  }
  
  // MARK: Endpoints
//  class func endpointForID(_ id: Int) -> String {
//    return "https://swapi.co/api/species/\(id)"
//  }
  class func endpointForMessages() -> String {
    return "http://142.93.64.49/messages"
  }
  
  // MARK: CRUD
  // GET / Read single species
//  class func speciesByID(_ id: Int, completionHandler: @escaping (Result<StarWarsSpecies>) -> Void) {
//    let _ = Alamofire.request(StarWarsSpecies.endpointForID(id))
//      .responseJSON { response in
//        if let error = response.result.error {
//          completionHandler(.failure(error))
//          return
//        }
//        let speciesResult = StarWarsSpecies.speciesFromResponse(response)
//        completionHandler(speciesResult)
//    }
//  }
  
  // GET / Read all species
  fileprivate class func getMessageAtPath(_ path: String, completionHandler: @escaping (Result<MessageWrapper, AFError>) -> Void) {
    // make sure it's HTTPS because sometimes the API gives us HTTP URLs
    guard var urlComponents = URLComponents(string: path) else {
      let error = BackendError.urlError(reason: "Tried to load an invalid URL")
      //completionHandler(.failure(error))
      return
    }
    urlComponents.scheme = "https"
    guard let url = try? urlComponents.asURL() else {
      let error = BackendError.urlError(reason: "Tried to load an invalid URL")
      //completionHandler(.failure(error))
      return
    }
    let _ = AF.request(url)
      .responseJSON { response in
        if let error = response.error {
          completionHandler(.failure(error))
          return
        }
        let messageWrapperResult = Message.messageArrayFromResponse(response)
        completionHandler(messageWrapperResult)
    }
  }
  
  class func getMessage(_ completionHandler: @escaping (Result<MessageWrapper, AFError>) -> Void) {
    getMessageAtPath(Message.endpointForMessages(), completionHandler: completionHandler)
  }

//This function will not be used we are exclusively using one endpoint
//  class func getMoreMessages(_ wrapper: MessageWrapper?, completionHandler: @escaping (Result<MessageWrapper, AFError>) -> Void) {
//    guard let nextURL = wrapper?.next else {
//      let error = BackendError.objectSerialization(reason: "Did not get wrapper for more messages")
//      completionHandler(.failure(error))
//      return
//    }
//    getSpeciesAtPath(nextURL, completionHandler: completionHandler)
//  }
  
  private class func speciesFromResponse(_ response: DataResponse<Any, AFError>) -> Result<Message, AFError> {
    guard response.error == nil else {
      // got an error in getting the data, need to handle it
      print(response.error!)
      return .failure(response.error!)
    }
    
    // make sure we got JSON and it's a dictionary
    guard let json = response.value as? [String: Any] else {
      print("didn't get species object as JSON from API")
//      return .failure(BackendError.objectSerialization(reason:
//        "Did not get JSON dictionary in response"))
        return .failure(response.error!)
    }
    
    let message = Message(json: json)
    return .success(message)
  }
  
  private class func messageArrayFromResponse(_ response: DataResponse<Any, AFError>) -> Result<MessageWrapper, AFError> {
    guard response.error == nil else {
      // got an error in getting the data, need to handle it
      print(response.error!)
      return .failure(response.error!)
    }
    
    // make sure we got JSON and it's a dictionary
    guard let json = response.value as? [String: Any] else {
      print("didn't get message object as JSON from API")
//      return .failure(BackendError.objectSerialization(reason:
//        "Did not get JSON dictionary in response"))
        return .failure(response.error!)
    }
    
    let wrapper: MessageWrapper = MessageWrapper()
    
    var allMessages: [Message] = []
    if let results = json["results"] as? [[String: Any]] {
      for jsonMessage in results {
        let message = Message(json: jsonMessage)
        allMessages.append(message)
      }
    }
    wrapper.messages = allMessages
    return .success(wrapper)
  }
}
