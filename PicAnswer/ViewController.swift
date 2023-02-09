//
//  ViewController.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 1/30/23.
//

import UIKit
import Vision
import VisionKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.pushViewController(CameraViewController(), animated: false)
        //UserDefaults.standard.removeObject(forKey: "id")
        //if (UserDefaults.standard.object(forKey: "id") != nil){
        if UserDefaults.standard.object(forKey: "ads") == nil
        {
            UserDefaults.standard.set(0, forKey: "ads")
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
        }else{
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
        }
//        }else{
//            let story = UIStoryboard(name: "Main", bundle:nil)
//            let vc = story.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
//            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
//            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
//        }
    }
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 40))
    toastLabel.backgroundColor = UIColor.red
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1
    toastLabel.layer.cornerRadius = 4
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

extension UIViewController {

func showToast2(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 40))
    toastLabel.backgroundColor = UIColor.systemBlue
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1
    toastLabel.layer.cornerRadius = 4
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}


