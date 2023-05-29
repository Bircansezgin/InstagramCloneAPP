//
//  ViewController.swift
//  InstagramClone
//
//  Created by Bircan Sezgin on 26.05.2023.
//

import UIKit
import Firebase
import FirebaseAuth

//7db40d56-d379-403b-a88f-a3e414d54716

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func signInclick(_ sender: Any) {
        
        
        if emailTextField.text != "" && passwordTextField.text != ""{
            Auth.auth().signIn(withEmail: emailTextField.text! , password: passwordTextField.text!) { authdata, error in
                if error != nil{
                    self.alerts(title: "Error", message: error?.localizedDescription ?? "Error")
                }else{
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }else{
            alerts(title: "Error", message: "username/Password?")
        }
        
        
        
    }
    
    
    @IBAction func signUpClick(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != ""{
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authdata, error in
                
                if error != nil{
                    self.alerts(title: "Error", message: error?.localizedDescription ?? "Error")
                    
                }else{
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
                
            }
            
        }else{
            alerts(title: "Error", message: "u")
        }
        
        
    }
    
    
    
    
    func alerts(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okbutton = UIAlertAction(title: "OKEY", style: .default)
        alert.addAction(okbutton)
        self.present(alert, animated: true)
    }
}

