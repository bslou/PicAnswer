//
//  BuyViewController.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 2/1/23.
//

import UIKit
import StoreKit
import RevenueCat
import FirebaseFirestore
import Firebase

class BuyViewController: UIViewController{
    //@Published var premium = false
    @IBOutlet weak var vie: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        Purchases.shared.getCustomerInfo { (info, err) in
//            if info?.entitlements["premium"]?.isActive == true{
//                self.premium = true
//            }
//        }
        vie.layer.cornerRadius = 8
        vie.layer.masksToBounds = false
        vie.layer.shouldRasterize = true
        vie.layer.shadowRadius = 4
        vie.layer.shadowOffset = CGSize(width: 2, height: 4)
        vie.layer.shadowColor = UIColor.black.cgColor
        
    }
    @IBAction func IAP(_ sender: Any) {
        let db = Firestore.firestore()
        PurchaseService.purchase(productId: "picanswerprem") {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let now = df.string(from: Date())
            db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["premium" : "yes"])
            db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["premiumDate" : now])
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
        }
    }
    @IBAction func FreeContinuation(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
    }
}
