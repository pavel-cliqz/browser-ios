//
//  VPNCredentialsService.swift
//  Client
//
//  Created by Sahakyan on 1/23/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Shared

struct VPNData {
    let country: String
	let countryCode: String
	let username: String
	let password: String
	let remoteID: String
	let serverIP: String
	let port: Int
}

class VPNCredentialsService {
	
    private static let DeviceIDKey = "Lumen.DeviceID"

	#if BETA
	private static let vpnAPIURL = "https://auth-staging.lumenbrowser.com/get_credentials"
	#else
	private static let vpnAPIURL = "https://auth.lumenbrowser.com/get_credentials"
	#endif
	class func getVPNCredentials(completion: @escaping ([VPNData]) -> Void) {
		guard let apiKey = APIKeys.lumenAPI, !apiKey.isEmpty,
				let subscriptionUserId = SubscriptionController.shared.getSubscriptionUserId() else {
			print("API Key is not available in Info.plist")
			return
		}
		if let deviceId = getDeviceId() {
			let params: Parameters = ["device_id": deviceId,
					  	"revenue_cat_token": subscriptionUserId]
			let header = ["x-api-key": apiKey]
			var result = [VPNData]()
			Alamofire.request(vpnAPIURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
				if response.result.isSuccess {
					let json = JSON(response.result.value ?? "")
                    if response.response?.statusCode == 480 {
                        updateTrialRemainingDays(-1)
                    } else if let fullResponse = json.dictionary,
						let body = fullResponse["body"]?.dictionary {
                        if let remainingDays = body["trial_days_left"]?.int {
                            updateTrialRemainingDays(remainingDays)
                        }
                        
                        if let nodes = body["nodes"]?.array,
                            let credentials = body["credentials"]?.dictionary,
                            let username = credentials["username"]?.string,
                            let password = credentials["password"]?.string {
                            for node in nodes {
                                if let data = node.dictionary,
                                    let ip = data["ipAddress"]?.string,
                                    let countryCode = data["countryCode"]?.string,
                                    let country = data["country"]?.string,
                                    let name = data["name"]?.string {
                                    result.append(VPNData(country: country, countryCode: countryCode, username: username, password: password, remoteID: name, serverIP: ip, port: 0))
                                }
                            }
                        }
                    }
                } else {
					print(response.error ?? "No Error from response") // TODO proper Error
				}
				completion(result)
			}
		} else {
			completion([VPNData]())
		}
	}
    
    private class func updateTrialRemainingDays(_ remainingDays: Int?) {
        guard let remainingDays = remainingDays else {
            return
        }
        
        let currentSubscription = SubscriptionController.shared.getCurrentSubscription()
        switch currentSubscription {
        case .trial(let currentRemainingDays):
            if remainingDays != currentRemainingDays {
                SubscriptionController.shared.saveTrialRemainingDays(remainingDays)
            }
        default:
            return
        }
    }
    
    class func getDeviceId() -> String? {
        let keychain = DAKeychain.shared
        if let deviceId = keychain[DeviceIDKey] {
            return deviceId
        }
        // use identifierForVendor as deviceID
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            keychain[DeviceIDKey] = deviceId
            return deviceId
        }
        // could not gerenate deviceId
        return nil
    }
}
