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

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropperViewControllerDelegate {
    

  var selectedImage: UIImage?
    var db = Firestore.firestore()

  override func viewDidLoad() {
    super.viewDidLoad()
      print("Loaded one")


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
                        if ((document.data()?["numad"] as! Int64) + 1 >= 3){
                            //show intersitial ad
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
