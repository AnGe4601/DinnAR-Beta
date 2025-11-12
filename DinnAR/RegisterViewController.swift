//
//  RegisterViewController.swift
//  DinnAR
//
//  Created by Lakshmi on 10/21/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class RegisterViewController: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var confirmPwdTextField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        (pwdField.isSecureTextEntry, confirmPwdTextField.isSecureTextEntry) = (true,true)
        setup()
    }
    
    private func setup() {
        emailField.keyboardType = .emailAddress
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.textContentType = .username
        [pwdField, confirmPwdTextField].forEach { field in
            field?.isSecureTextEntry = true
            field?.autocorrectionType = .no
            field?.autocapitalizationType = .none
            field?.textContentType = .newPassword
        }
        
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
//            if let user = authResult?.user {
//                let changeRequest = user.createProfileChangeRequest()
//                changeRequest.displayName = fullName
//                changeRequest.commitChanges { error in
//                    if let error = error {
//                        print(" \(error.localizedDescription)")
//                    }
//                }
//            }

            let db = Firestore.firestore()
            if let uid = authResult?.user.uid {
                db.collection("users").document(uid).setData([
                    "fullName": fullName,
                    "email": email,
                    "phone": phone
                ]) { error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    } else {
                        return
                    }
                }
            }

//            UserDefaults.standard.set(fullName, forKey: "fullName")
            self.requestPermissions()
            self.performSegue(withIdentifier: "toPref", sender: self)

                //self.performSegue(withIdentifier: "ViewController", sender: self)
            }
        
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
    
        private func requestPermissions() {
            PermissionManager.shared.requestLocationPermission()
            PermissionManager.shared.requestContactsPermission() { granted in
            }
        }
    }


