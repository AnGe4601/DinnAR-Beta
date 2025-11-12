//  LoginViewController.swift
//  DinnAR
//  Created by Lakshmi on 10/21/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var pwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        pwdField.delegate = self
        setupTextFields()
    }
            
    private func setupTextFields() {
        emailField.keyboardType = .emailAddress
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.textContentType = .username
        pwdField.isSecureTextEntry = true
        pwdField.autocorrectionType = .no
        pwdField.autocapitalizationType = .none
        pwdField.textContentType = .password

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

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
                    }

            self.performSegue(withIdentifier: "toHome", sender: self)                }
            }

        func showAlert(message: String) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }

        func textFieldShouldReturn(_ textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    @IBAction func forgotpwd(_ sender: Any) {
            let alert = UIAlertController(title: "Reset Password", message: "Enter your email", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Email"
                textField.keyboardType = .emailAddress
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { send in
                guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        self.showAlert(message: " \(error.localizedDescription)")
                    } else {
                        self.showAlert(message: "Password reset email sent! Check your inbox and follow the instructions.")
                    }
                }
            }))
            present(alert, animated: true)
        }

    }
    



