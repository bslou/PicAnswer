//
//  LoginViewController.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 1/31/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {
    
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
    @IBAction func LogIn(_ sender: Any) {
        let email = eml.text
        let password = pwd.text
        let db = Firestore.firestore()
        
        if (email == ""){
            showToast(message: "Invalid email", font: .systemFont(ofSize: 14.0))
            return
        }
        
        if (password == ""){
            showToast(message: "Invalid password", font: .systemFont(ofSize: 14.0))
            return
        }

        
        Auth.auth().signIn(withEmail: email ?? "", password: password ?? "") { [weak self] authResult, error in
            if let err = error{
                self?.showToast(message: err.localizedDescription, font: UIFont.systemFont(ofSize: 16.0))
            }else{
                guard let strongSelf = self else { return }
                db.collection("users").document((authResult?.user.uid)!).getDocument {(document, error) in
                    UserDefaults.standard.set(authResult?.user.uid, forKey: "id")
                    if let document = document, document.exists {
                        let field = document.data()?["premium"] as? String
                        if (field == "no"){
                            //redirect to iap screen
                            let story = UIStoryboard(name: "Main", bundle:nil)
                            let vc = story.instantiateViewController(withIdentifier: "BuyViewController") as! BuyViewController
                            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
                            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
                        }else{
                            let story = UIStoryboard(name: "Main", bundle:nil)
                            let vc = story.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
                            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
                        }
                    }else{
                        self?.showToast(message: "Error logging in", font: .systemFont(ofSize: 14.0))
                    }
                
                }

            }
       }

    }
    @IBAction func Reg(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
    }
    @IBAction func sampleVid(_ sender: Any) {
        guard let url = URL(string: "https://picanswerapp.vercel.app/") else { return }
        UIApplication.shared.open(url)
    }
}
