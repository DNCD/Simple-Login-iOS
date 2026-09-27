//
//  AppDelegate.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 10/01/2022.
//

import SwiftyStoreKit
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     // swiftlint:disable:next line_length
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UIView.appearance(whenContainedInInstancesOf:
            [UIAlertController.self]).tintColor = .brand
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                default: break
                }
            }
        }
        return true
    }

    func application(_: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Custom scene delegate to receive home screen quick actions
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
