//  LoginViewController.swift
//  DinnAR
//  Created by Lakshmi on 10/21/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signupPressed(_ sender: Any) {
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty else {
        showAlert(message: "Please enter your email.")
        return
                }
        guard let password = pwdField.text, !password.isEmpty else {
        showAlert(message: "Please enter your password.")
        return
                }

                // Attempt login
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
                    }

        self.showAlert(message: "Login Successful!")
                }
            }

        func showAlert(message: String) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
    }


