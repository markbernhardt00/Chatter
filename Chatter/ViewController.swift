//
//  ViewController.swift
//  Chatter

import UIKit
import CryptoSwift
import Alamofire
var loggedInUser = ""

class ViewController: UIViewController {
    
    
    @IBOutlet weak var signInOutlet: UIButton!
    
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        roundButton()
    
    }
    
    func roundButton() {
        signInOutlet.layer.cornerRadius = 5
        signInOutlet.layer.borderWidth = 1
    }
    
    func processField() {
        
    }
    
    func passwordHash(from username: String, password: String) -> String {
      let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
      return "\(password).\(username).\(salt)".sha256()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    @IBAction func signInAction(_ sender: Any) {
        guard let username = usernameOutlet.text, username.count > 0 else {
            return
        }
        guard let password = passwordOutlet.text, password.count > 0 else {
            return
        }
        
        let hash = passwordHash(from: username, password: password)
        
        let parameters: [String: String] = [
            "username" : username,
            "password": hash
        ]
        AF.request("http://142.93.64.49/users/login", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success:
                print("Login Successful")
               loggedInUser = username
            self.showMessageBoardController(self)
            case let .failure(error):
                let alert = UIAlertController(title: "Error", message: "Login failed try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
                self.present(alert, animated: true)
                print("FAILED")
                print(error)
            }
        }
        
        
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        showHomeFromReg(self)
    }
    
    @IBAction func showMessageBoardController(_ sender: Any) {
      performSegue(withIdentifier: "messageBoardSegue", sender: self)

        }
    
    @IBAction func showHomeFromReg(_ sender: Any) {
          performSegue(withIdentifier: "registrationSegue", sender: self)
    }
    
}

