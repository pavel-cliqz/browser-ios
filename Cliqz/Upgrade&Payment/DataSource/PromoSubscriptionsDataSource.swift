//
//  PromoSubscriptionsDataSource.swift
//  Client
//
//  Created by Sahakyan on 5/16/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class PromoSubscriptionsDataSource {
	
    private var subscriptionInfo: SubscriptionCellInfo?
    private var promoType: LumenSubscriptionPromoPlanType
	
    init(promoType: LumenSubscriptionPromoPlanType, availablePromoSubscription: [LumenSubscriptionProduct]) {
        self.promoType = promoType
        if let promoProduct = availablePromoSubscription.filter({ $0.product.productIdentifier == promoType.promoID }).first {
            self.subscriptionInfo = SubscriptionCellInfo(priceDetails: nil, offerDetails: self.offerDetails(plan: promoType), isSubscribed: SubscriptionController.shared.hasSubscription(promoProduct.subscriptionPlan), height: 150, telemetryTarget: self.telemetryTarget(), lumenProduct: promoProduct)
        }
	}

	func subscriptionsCount() -> Int {
		return 1
	}

	func subscriptionHeight(indexPath: IndexPath) -> CGFloat {
        return self.subscriptionInfo?.height ?? 0
	}

	func subscriptionInfo(indexPath: IndexPath) -> SubscriptionCellInfo? {
		guard indexPath.row == 0 else {
			return nil
		}
		return self.subscriptionInfo
	}

    func promoText() -> String {
        return self.promoType.code
    }
    
	func getConditionText() -> String {
        switch self.promoType.type {
        case .half:
            return String(format: NSLocalizedString("Payment of %@ will be charged to your Apple ID account each month for 2 months. The subscription automatically renews for %@ per month after 2 months. Subscriptions will be applied to your iTunes account on confirmation. Your account will be charged for renewal within 24 hours prior to the end of the current period at the cost mentioned before. You can cancel anytime in your iTunes account settings until 24 hours before the end of the current period. Any unused portion of a free trial will be forfeited if you purchase a subscription.", tableName: "Lumen", comment: "Lumen conditions for 2 months 50% promo"), self.subscriptionInfo?.introductoryPrice ?? "", self.subscriptionInfo?.standardPrice ?? "")
        case .freeMonth:
            return String(format: NSLocalizedString("Your Apple ID account will not be charged in the first month. The subscription automatically renews for %@ per month after 1 month. Subscriptions will be applied to your iTunes account on confirmation. Your account will be charged for renewal within 24 hours prior to the end of the current period at the cost mentioned before. You can cancel anytime in your iTunes account settings until 24 hours before the end of the current period. Any unused portion of a free trial will be forfeited if you purchase a subscription.", tableName: "Lumen", comment: "Lumen conditions for 1 month for free"), self.subscriptionInfo?.standardPrice ?? "")
        }
	}
    
    // MARK: Private methods
    private func telemetryTarget() -> String {
        switch self.promoType.type {
        case .half:
            return "subscribe_basic_vpn_offer_half"
        case .freeMonth:
            return "subscribe_basic_vpn_offer_free"
        }
    }
    
    private func offerDetails(plan: LumenSubscriptionPromoPlanType) -> String? {
        switch plan.type {
        case .half:
            return NSLocalizedString("GET 2 MONTHS AT 50% OFF", tableName: "Lumen", value:"GET 2 MONTHS \nAT 50% OFF", comment: "GET 2 MONTHS AT 50% OFF")
        case .freeMonth:
            return NSLocalizedString("GET 1 MONTH FOR FREE", tableName: "Lumen", value:"GET 1 MONTH \nFOR FREE", comment: "GET 1 MONTH FOR FREE")
        }
    }
}

