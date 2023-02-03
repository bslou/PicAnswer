//
//  PhotoViewController.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 1/30/23.
//

import UIKit
import Vision
import QCropper
import Firebase
import FirebaseFirestore
import GoogleMobileAds

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropperViewControllerDelegate {
    
    struct Constant{
        static let homeAdId = "ca-app-pub-7343484395424686/2838569682"
    }
    private var interstitialAd: GADInterstitialAd?

  var selectedImage: UIImage?
    var db = Firestore.firestore()

  override func viewDidLoad() {
    super.viewDidLoad()
      print("Loaded one")
      
      let request = GADRequest()
      GADInterstitialAd.load(withAdUnitID: Constant.homeAdId, request: request, completionHandler: { [self] ad, error in
          if let err = error{
              print(err.localizedDescription)
              return
          }
          interstitialAd = ad
      })


  }
    override func viewDidAppear(_ animated: Bool) {
        print("Loaded two")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Selected")
        if ((info[.originalImage] as? UIImage) != nil) {
            selectedImage = info[.originalImage] as? UIImage
            picker.dismiss(animated: true) {
                self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).getDocument { document, err in
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
                            if (((date2.timeIntervalSince(date) / (60 * 60 * 24)) < 30)){
                                let cropper = CropperViewController(originalImage: self.selectedImage!)
                                cropper.delegate = self
                                picker.dismiss(animated: true) {
                                    self.present(cropper, animated: true, completion: nil)
                                }
                                return
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
                                            let cropper = CropperViewController(originalImage: self.selectedImage!)
                                            cropper.delegate = self
                                            picker.dismiss(animated: true) {
                                                self.present(cropper, animated: true, completion: nil)
                                            }
                                            
                                            
                                            //                                        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            //                                        let nvc = sb.instantiateViewController(withIdentifier: "OCRViewController") as! OCRViewController
                                            //                                        nvc.selectedImage = self.selectedImage
                                            //                                        self.navigationController?.pushViewController(nvc, animated: true)
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
                                                //                                            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                //                                            let nvc = sb.instantiateViewController(withIdentifier: "OCRViewController") as! OCRViewController
                                                //                                            nvc.selectedImage = self.selectedImage
                                                //                                            self.navigationController?.pushViewController(nvc, animated: true)
                                                let cropper = CropperViewController(originalImage: self.selectedImage!)
                                                cropper.delegate = self
                                                picker.dismiss(animated: true) {
                                                    self.present(cropper, animated: true, completion: nil)
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            }
                        }else{
                            print("Error in the matrix...")
                        }
                    
                }

            }
        }
    }
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)

        if let state = state,
            let image = cropper.originalImage.cropped(withCropperState: state) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nvc = sb.instantiateViewController(withIdentifier: "OCRViewController") as! OCRViewController
            nvc.selectedImage = image
            self.navigationController?.pushViewController(nvc, animated: true)
        } else {
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
            self.showToast(message: "Something went wrong", font: UIFont.systemFont(ofSize: 16.0))
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true){
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
