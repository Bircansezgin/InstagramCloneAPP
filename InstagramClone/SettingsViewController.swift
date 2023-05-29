//
//  SettingsViewController.swift
//  
//
//  Created by Bircan Sezgin on 26.05.2023.
//

import UIKit
import Firebase
class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func logoutClick(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLoginScreen", sender: nil)
        }catch{
            print("Hata")
        }
    }
    
    
}
