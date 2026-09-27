//
//  FeatureFlags.swift
//  RelayEmail
//
//  Created by Nhon Proton on 18/10/2022.
//

import Foundation

struct FeatureFlags {
    let printNetworkDebugInformation: Bool
    /// "Log in with Proton" and "Connect with Proton" require Proton OAuth to be configured on the server.
    /// Disabled by default for RelayEmail; flip to `true` once the backend supports it.
    let protonLoginEnabled: Bool
}

let featureFlags = { // swiftlint:disable:this prefixed_toplevel_constant
    #if DEBUG
    FeatureFlags(printNetworkDebugInformation: true,
                 protonLoginEnabled: false)
    #else
    FeatureFlags(printNetworkDebugInformation: false,
                 protonLoginEnabled: false)
    #endif
}()
