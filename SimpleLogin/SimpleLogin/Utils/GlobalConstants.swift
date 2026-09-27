//
//  GlobalConstants.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 03/02/2022.
//

import Foundation

let kDefaultApiUrlString = "https://app.relayemails.com/"
let kBiometricAuthEnabled = "ActiveBiometricAuthKey"
let kHapticFeedbackEnabled = "HapticFeedbackEnabled"
let kUltraProtectionEnabled = "UltraProtectionEnabled"
let kAliasDisplayMode = "AliasDisplayMode"
let kForceDarkMode = "ForceDarkMode"
let kAppearance = "Appearance"
let kDidShowTips = "DidShowTips"
let kKeyboardExtensionMode = "KeyboardExtensionMode"
let kLaunchCount = "LaunchCount"
let kAliasCreationCount = "AliasCreationCount"
let kSpotlightIndexingEnabled = "SpotlightIndexingEnabled"
let kPendingQuickAction = "PendingQuickAction"

let kDefaultPageSize = 20

extension Notification.Name {
    /// Posted when a widget or control asks the running app to perform a quick action
    static let pendingQuickAction = Notification.Name("PendingQuickAction")
}

/// Brand information shared by the app and its extensions
enum Brand {
    static let name = "RelayEmail"
    static let websiteUrlString = "https://relayemails.com/"
    static let dashboardUrlString = "https://app.relayemails.com/dashboard/"
    static let apiKeyUrlString = "https://app.relayemails.com/dashboard/api_key"
    static let termsUrlString = "https://relayemails.com/terms/"
    static let privacyUrlString = "https://relayemails.com/privacy/"
    static let securityUrlString = "https://relayemails.com/security/"
    static let faqUrlString = "https://relayemails.com/faq/"
    static let docsUrlString = "https://relayemails.com/docs/"
    static let addMailboxDocsUrlString = "https://relayemails.com/docs/mailbox/add-mailbox/"
    static let addDomainDocsUrlString = "https://relayemails.com/docs/custom-domain/add-domain/"
    static let sendEmailDocsUrlString = "https://relayemails.com/docs/getting-started/send-email/"
    static let supportEmail = "support@relayemails.com"
    static let urlScheme = "relayemail"
}
