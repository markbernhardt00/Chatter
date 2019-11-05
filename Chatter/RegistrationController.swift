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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        roundButton()
    }
    
    @IBAction func createAccountBtn(_ sender: Any) {
        showMessageBoardViewController(self)
    }
    
    @IBAction func showMessageBoardViewController(_ sender: Any) {
      performSegue(withIdentifier: "regToHomeSegue", sender: self)
    }
    
    func roundButton() {
        createAccountOutlet.layer.cornerRadius = 5
        createAccountOutlet.layer.borderWidth = 1
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
