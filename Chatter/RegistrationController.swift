//  RegistrationController.swift
//  Chatter

import UIKit
import Alamofire

class RegistrationController: UIViewController {

    @IBOutlet weak var createAccountOutlet: UIButton!
    @IBOutlet weak var fNameOutlet: UITextField!
    @IBOutlet weak var lNameOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBAction func backToLoginAction(_ sender: Any) {
    
        let vc: UIViewController = storyboard?.instantiateViewController(withIdentifier: "login") as! UIViewController
        self.show(vc, sender: self)
    }
    
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
        
        let parameters: [String: String] = [
            "username" : username,
            "name" : fName + " " + lName,
            "email" : email,
            "password": hash
        ]
        AF.request("http://142.93.64.49/users/register", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success:
                print("Registration Successful")
                loggedInUser = username
                self.showMessageBoardViewController(self)
            case let .failure(error):
                let alert = UIAlertController(title: "Error", message: "Registration failed try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
                self.present(alert, animated: true)
                print("FAILED")
                print(error)
            }
        }
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
