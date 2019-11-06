//
//  ViewController.swift
//  Chatter
//
//  Created by Michael Ruck on 11/4/19.
//  Copyright © 2019 Michael Ruck. All rights reserved.
//

import UIKit
import CryptoSwift

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
        print(hash)
        
        showMessageBoardController(self)
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

