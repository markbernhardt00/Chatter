//
//  ViewController.swift
//  Chatter
//
//  Created by Michael Ruck on 11/4/19.
//  Copyright © 2019 Michael Ruck. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signInOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        roundButton()
    
    }
    
    func roundButton() {
        signInOutlet.layer.cornerRadius = 5
        signInOutlet.layer.borderWidth = 1
    }

    @IBAction func signInAction(_ sender: Any) {
        showMessageBoardController(self)
    }
    
    @IBAction func showMessageBoardController(_ sender: Any) {
      performSegue(withIdentifier: "messageBoardSegue", sender: self)
        
    }
    
}

