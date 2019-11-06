//
//  RegistrationController.swift
//  Chatter
//
//  Created by Michael Ruck on 11/5/19.
//  Copyright © 2019 Michael Ruck. All rights reserved.
//

import UIKit

class RegistrationController: UIViewController {

    @IBOutlet weak var createAccountOutlet: UIButton!
    @IBOutlet weak var fNameOutlet: UITextField!
    @IBOutlet weak var lNameOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        roundButton()
    }
    
    func passwordHash(from username: String, password: String) -> String {
      let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
      return "\(password).\(username).\(salt)".sha256()
    }
    
    @IBAction func createAccountBtn(_ sender: Any) {
        guard let fName = fNameOutlet.text, fName.count > 0 else {
            return
        }
        guard let lName = lNameOutlet.text, lName.count > 0 else {
            return
        }
        guard let email = emailOutlet.text, email.count > 0 else {
            return
        }
        guard let username = usernameOutlet.text, username.count > 0 else {
            return
        }
        guard let password = passwordOutlet.text, password.count > 0 else {
            return
        }
        
        let hash = passwordHash(from: username, password: password)
        print(hash)
        showMessageBoardViewController(self)
    }
    
    @IBAction func showMessageBoardViewController(_ sender: Any) {
      performSegue(withIdentifier: "regToHomeSegue", sender: self)
    }
    
    func roundButton() {
        createAccountOutlet.layer.cornerRadius = 5
        createAccountOutlet.layer.borderWidth = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
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
