//
//  RegisterViewController.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 1/31/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pwd: UITextField!
    
    @IBOutlet weak var eml: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        eml.delegate = self
        pwd.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        eml.resignFirstResponder()
        pwd.resignFirstResponder()
        return true
    }
    @IBAction func Register(_ sender: Any) {
        let email = eml.text
        let password = pwd.text
        let db = Firestore.firestore()
        
        print("Email " + email!)
        print("Password " + password!)
        
        if (email == ""){
            showToast(message: "Invalid email", font: .systemFont(ofSize: 14.0))
            return
        }
        
        if (password!.count < 8){
            showToast(message: "Password has to be at least 8 characters.", font: .systemFont(ofSize: 14.0))
            return
        }
        
        Auth.auth().createUser(withEmail: email!, password: password!) { (authResult, error) in
            if let error = error {
                self.showToast(message: error.localizedDescription, font: .systemFont(ofSize: 14.0))
            } else {
                let user = Auth.auth().currentUser
                if let user = user {
                    let userData = ["email": email!, "premium": "no", "premiumDate": "", "pics": String(0), "picsdate": Date(), "numad": String(1)]
                    db.collection("users").document(user.uid).setData(userData as [String : Any]) { (error) in
                        if let error = error {
                            self.showToast(message: error.localizedDescription, font: .systemFont(ofSize: 14.0))
                        } else {
                            UserDefaults.standard.set(user.uid, forKey: "id")
                            if UserDefaults.standard.object(forKey: "id") != nil{
                                let story = UIStoryboard(name: "Main", bundle:nil)
                                let vc = story.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                                UIApplication.shared.windows.first?.rootViewController = vc
                                UIApplication.shared.windows.first?.makeKeyAndVisible()
                            }
                        }
                    }
                }else{
                    self.showToast(message: "Email registration error", font: .systemFont(ofSize: 14.0))
                }
            }
        }


    }
    @IBAction func Login(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
