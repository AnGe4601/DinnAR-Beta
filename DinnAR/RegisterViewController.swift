//
//  RegisterViewController.swift
//  DinnAR
//
//  Created by Lakshmi on 10/21/25.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var confirmPwdTextField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func registerPressed(_ sender: Any) {
        guard let fullName = fullNameTextField.text, !fullName.isEmpty else {
            showAlert(message: "Please enter your full name.")
            return
              }
        guard let email = emailField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
             }
        guard let phone = phoneField.text, !phone.isEmpty else {
            showAlert(message: "Please enter your phone number.")
            return
              }
        if !phone.allSatisfy({ $0.isNumber }) {
            showAlert(message: "Invalid Phone Number.")
            return
          }
        guard let password = pwdField.text, !password.isEmpty else {
            showAlert(message: "Please enter your password.")
            return
              }
              
        guard let confirmPassword = confirmPwdTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please confirm your password.")
            return
              }
              
        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match.")
            return
              }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Registration failed: \(error.localizedDescription)")
                return
                  }
                  
        self.showAlert(message: "Registration successful!")
        self.performSegue(withIdentifier: "ViewController", sender: self )
            }
          }
        func showAlert(message: String) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
          }
      }
