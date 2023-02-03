//
//  PurchaseService.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 2/2/23.
//

import Foundation
import RevenueCat

class PurchaseService {
    
    
    static func purchase(productId:String?, successfulPurchase:@escaping () -> Void) {
    
        guard productId != nil else {
            return
        }
        
        var skProduct:StoreProduct?
        
        // Find product based on Id
        Purchases.shared.getProducts([productId!]) { products in
            
            if !products.isEmpty {
                skProduct = products[0]
                
                // Purchase it
                Purchases.shared.purchase(product: skProduct!) { (transaction, purchaseInfo, error, userCancelled) in
                    
                    // If successful purchase...
                    if error == nil && !userCancelled {
                        successfulPurchase()
                    }
                    
                }
            }
        }
    }
    
}
