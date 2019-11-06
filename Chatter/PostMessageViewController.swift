//
//  PostMessageViewController.swift
//  Chatter
//
//  Created by Michael Ruck on 11/5/19.
//  Copyright © 2019 Michael Ruck. All rights reserved.
//

import UIKit

class PostMessageViewController: UIViewController {

    @IBOutlet weak var usernameText: UITextField!
    
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
    
    func roundButton() {
        
        messageBox.layer.cornerRadius = 5
        postMessageButton.layer.cornerRadius = 5
        
        messageBox.layer.borderWidth = 1
        postMessageButton.layer.borderWidth = 1
    }
    
    
    @IBAction func postMessageAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
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
