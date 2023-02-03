//
//  ViewController.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 1/30/23.
//

import UIKit
import Vision
import VisionKit
import Firebase
import FirebaseFirestore
import QCropper
import KKRateApp
import RevenueCat
import GoogleMobileAds
//import Alamofire


class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropperViewControllerDelegate {
    
    struct Constant{
        static let homeAdId = "ca-app-pub-7343484395424686/2838569682"
    }
    private var interstitialAd: GADInterstitialAd?

    @IBOutlet weak var topbut: UIButton!
    
    @IBOutlet weak var but2: UIButton!
    @IBOutlet weak var but1: UIButton!
    var db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        but1.titleLabel?.font=UIFont.boldSystemFont(ofSize: 18)
        but2.titleLabel?.font=UIFont.boldSystemFont(ofSize: 18)
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: Constant.homeAdId, request: request, completionHandler: { [self] ad, error in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            interstitialAd = ad
        })
        

        db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).getDocument {(document, error) in
            if let document = document, document.exists {
                let field = document.data()?["premium"] as? String
                // use the field as desired
                if (field == "no"){
                    self.topbut.backgroundColor = UIColor.systemBlue
                    self.topbut.setTitleColor(.white, for: .normal)
                    self.topbut.layer.cornerRadius = 3
                    self.topbut.setTitle( "Get Premium" , for: .normal )
                }else{
                    //self.topbut.isEnabled = false
                    self.topbut.setTitleColor(.black, for: .normal)
                    self.topbut.setTitle( "Premium Version" , for: .normal )
                }
              } else {
                // handle the error
                  print("error")
              }
            }
    


        
    }
    override func viewDidAppear(_ animated: Bool) {
        KKRateApp.rateAppAfter(appLaunches: 5)
        
        db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).getDocument {(document, error) in
            if let document = document, document.exists {
                let date1 = document.data()?["picsdate"]
                let date2 = Date()
                // use the field as desired
                if ((date2.timeIntervalSince( (date1 as! Timestamp).dateValue()) / (60 * 60 * 24)) > 30){
                    self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["pics" : 0])
                    self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["picsdate" : Date()])
                }
            }
        }
        
//        self.navigationController?.pushViewController(CameraViewController(), animated: false)
        
    }
    @IBAction func onPress(_ sender: Any) {
        db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).getDocument {(document, error) in
            if let document = document, document.exists {
                let fieldo = document.data()?["premium"]
                let date1o = document.data()?["premiumDate"]
                let date2o = Date()
                // use the field as desired
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                if ((fieldo as! String != "no") && date1o as! String != ""){
                    let date = dateFormatter.date(from:date1o as! String)!
                    if (((date2o.timeIntervalSince(date) / (60 * 60 * 24)) <= 30)){
                        let imagePickerController = UIImagePickerController()
                        imagePickerController.delegate = self
                        imagePickerController.sourceType = .camera
                        imagePickerController.allowsEditing = false
                        self.present(imagePickerController, animated: true)
                        return
                    }else{
                        let field = document.data()?["pics"]
                        let date1 = document.data()?["picsdate"]
                        let date2 = Date()
                        // use the field as desired
                        if (field as! Int >= 10){
                            self.showToast(message: "Maximized AI calls for the month.", font: UIFont.systemFont(ofSize: 16.0))
                        }else{
                            let imagePickerController = UIImagePickerController()
                            imagePickerController.delegate = self
                            imagePickerController.sourceType = .camera
                            imagePickerController.allowsEditing = false
                            self.present(imagePickerController, animated: true)
                        }
                    }
                }else{
                    let field = document.data()?["pics"]
                    let date1 = document.data()?["picsdate"]
                    let date2 = Date()
                    // use the field as desired
                    if (field as! Int >= 10){
                        self.showToast(message: "Maximized AI calls for the month.", font: UIFont.systemFont(ofSize: 16.0))
                    }else{
                        let imagePickerController = UIImagePickerController()
                        imagePickerController.delegate = self
                        imagePickerController.sourceType = .camera
                        imagePickerController.allowsEditing = false
                        self.present(imagePickerController, animated: true)
                    }
                }
              } else {
                // handle the error
                  print("error")
              }
            }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).getDocument { document, err in
            if let document = document, document.exists {
                let field = document.data()?["premium"]
                let date1 = document.data()?["premiumDate"]
                let date2 = Date()
                // use the field as desired
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                if ((field as! String != "no") && date1 as! String != ""){
                    let date = dateFormatter.date(from:date1 as! String)!
                    if (((date2.timeIntervalSince(date) / (60 * 60 * 24)) <= 30)){
                        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                            // Use the picked image
                            
                            print("one...")
                            let cropper = CropperViewController(originalImage: pickedImage)
                            print("two...")
                            cropper.delegate = self
                            print("three...")
                            picker.dismiss(animated: true) {
                                self.present(cropper, animated: true, completion: nil)
                            }
                            print("four...")
                        }
                        return
                    }else{
                        if ((document.data()?["numad"] as! Int64) + 1 >= 3){
                            //show intersitial ad
                            if self.interstitialAd != nil{
                                self.interstitialAd?.present(fromRootViewController: self)
                            }else{
                                print("Ad was not ready")
                            }
                            self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["numad" : 0])
                            if let o = (document.data()?["pics"] as? Int64){
                                print("Num = " + String(o))
                                self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["pics" : (o+1)]) { (error) in
                                    if let error = error {
                                        print("Error updating document: \(error)")
                                    } else {
                                        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                                            // Use the picked image
                                            
                                            print("one...")
                                            let cropper = CropperViewController(originalImage: pickedImage)
                                            print("two...")
                                            cropper.delegate = self
                                            print("three...")
                                            picker.dismiss(animated: true) {
                                                self.present(cropper, animated: true, completion: nil)
                                            }
                                            print("four...")
                                        }
                                    }
                                }
                                
                            }
                        }else{
                            if let n = document.data()?["numad"] as? Int64{
                                self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["numad" : (n+1)])
                                if let o = document.data()?["pics"] as? Int64{
                                    print("Num = " + String(o))
                                    self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["pics" : (o+1)]) { (error) in
                                        if let error = error {
                                            print("Error updating document: \(error)")
                                        } else {
                                            
                                            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                                                // Use the picked image
                                                
                                                print("one...")
                                                let cropper = CropperViewController(originalImage: pickedImage)
                                                print("two...")
                                                cropper.delegate = self
                                                print("three...")
                                                picker.dismiss(animated: true) {
                                                    self.present(cropper, animated: true, completion: nil)
                                                }
                                                print("four...")
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }else{
                    if ((document.data()?["numad"] as! Int64) + 1 >= 3){
                        //show intersitial ad
                        if self.interstitialAd != nil{
                            self.interstitialAd?.present(fromRootViewController: self)
                        }else{
                            print("Ad was not ready")
                        }
                        self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["numad" : 0])
                        if let o = (document.data()?["pics"] as? Int64){
                            print("Num = " + String(o))
                            self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["pics" : (o+1)]) { (error) in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                                        // Use the picked image
                                        
                                        print("one...")
                                        let cropper = CropperViewController(originalImage: pickedImage)
                                        print("two...")
                                        cropper.delegate = self
                                        print("three...")
                                        picker.dismiss(animated: true) {
                                            self.present(cropper, animated: true, completion: nil)
                                        }
                                        print("four...")
                                    }
                                }
                            }
                            
                        }
                    }else{
                        if let n = document.data()?["numad"] as? Int64{
                            self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["numad" : (n+1)])
                            if let o = document.data()?["pics"] as? Int64{
                                print("Num = " + String(o))
                                self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["pics" : (o+1)]) { (error) in
                                    if let error = error {
                                        print("Error updating document: \(error)")
                                    } else {
                                        
                                        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                                            // Use the picked image
                                            
                                            print("one...")
                                            let cropper = CropperViewController(originalImage: pickedImage)
                                            print("two...")
                                            cropper.delegate = self
                                            print("three...")
                                            picker.dismiss(animated: true) {
                                                self.present(cropper, animated: true, completion: nil)
                                            }
                                            print("four...")
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
            
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)

        if let state = state,
            let image = cropper.originalImage.cropped(withCropperState: state) {
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "OCRViewController") as! OCRViewController
            nextVC.selectedImage = image
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
            self.showToast(message: "Something went wrong", font: UIFont.systemFont(ofSize: 16.0))
        }
        self.dismiss(animated: true, completion: nil)
    }


    
    @IBAction func onPhoto(_ sender: Any) {
        print("Press1")
        db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).getDocument {(document, error) in
            if let document = document, document.exists {
                let fieldo = document.data()?["premium"]
                let date1o = document.data()?["premiumDate"]
                let date2o = Date()
                // use the field as desired
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                if ((fieldo as! String != "no") && date1o as! String != ""){
                    let date = dateFormatter.date(from:date1o as! String)!
                    if (((date2o.timeIntervalSince(date) / (60 * 60 * 24)) <= 30)){
                        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextVC = sb.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
                        self.navigationController?.pushViewController(nextVC, animated: true)
                        return
                    }
                }else{
                    let field = document.data()?["pics"]
                    let date1 = document.data()?["picsdate"]
                    let date2 = Date()
                    // use the field as desired
                    if (field as! Int >= 10){
                        self.showToast(message: "Maximized pics for the month...", font: UIFont.systemFont(ofSize: 16.0))
                    }else{
                        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextVC = sb.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                }
            }else {
                // handle the error
                print("error")
            }
            
        }
    }
    @IBAction func TopButPressed(_ sender: Any) {
        db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).getDocument {(document, error) in
            if let document = document, document.exists {
                let field = document.data()?["premium"] as? String
                // use the field as desired
                if (field == "no"){
                    let story = UIStoryboard(name: "Main", bundle:nil)
                    let vc = story.instantiateViewController(withIdentifier: "BuyViewController") as! BuyViewController
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
                }else{
                    //self.topbut.isEnabled = false
                    Purchases.shared.restorePurchases {(customerInfo, error) in
                        self.showToast2(message: "Purchase successfully restored...", font: UIFont.systemFont(ofSize: 16.0))
                    }
                }
              } else {
                // handle the error
                  print("error")
              }
            }
    }
    
}


