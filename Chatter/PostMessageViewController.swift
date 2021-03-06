//  PostMessageViewController.swift
//  Chatter

import UIKit
import Alamofire
import SwiftyJSON

class PostMessageViewController: UIViewController {
    @IBOutlet weak var messageBox: UITextView!
    
    @IBOutlet weak var expirationDate: UIDatePicker!
    
    @IBOutlet weak var postMessageButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        roundButton()
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func post() {
        
        if(messageCoords == []) {
            let alert = UIAlertController(title: "Error", message: "You need to specify a location before posting!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        
        let exp = expirationDate.date
        print("BEFORE")
        print(exp)
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone

        let dateString = formatter.string(from: exp) // string purpose I add here
//        // convert your string to date
//        let yourDate = formatter.date(from: dateString)
//        //then again set the date format whhich type of output you need
//        formatter.dateFormat = "dd-MMM-yyyy"
//        // again convert your date to string
//        let myStringafd = formatter.string(from: yourDate!)

        print("AFTER")
        print(dateString)
        
        
        let parameters: [String: String] = [
            "username" : loggedInUser,
            "content" : messageBox.text,
            "expiration": dateString,
            "geofence": "{\"coords\": \(messageCoords)}"
        ]
        AF.request("http://142.93.64.49/messages/new", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success:
                print("New post Successful!")
            case let .failure(error):
                let alert = UIAlertController(title: "Error", message: "Please verify your account before posting!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
                self.present(alert, animated: true)
                print("FAILED")
                print(error)
            }
        }
    }
    
    func roundButton() {
        
        messageBox.layer.cornerRadius = 5
        postMessageButton.layer.cornerRadius = 5
        
        messageBox.layer.borderWidth = 1
        postMessageButton.layer.borderWidth = 1
    }
    
    
    @IBAction func postMessageAction(_ sender: Any) {
        post()
        let vc: UIViewController = storyboard?.instantiateViewController(withIdentifier: "tabbar") as! UIViewController
        self.show(vc, sender: self)
        
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
