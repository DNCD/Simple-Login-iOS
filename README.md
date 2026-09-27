## RelayEmail for iOS
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![iOS 26.0+](https://img.shields.io/badge/iOS-26.0%2B-blue.svg)
![Xcode 26](https://img.shields.io/badge/Xcode-26%2B-orange.svg)

Protect your inbox with email aliases. RelayEmail is based on the open source
[SimpleLogin iOS app](https://github.com/simple-login/Simple-Login-iOS).

- Website: [https://relayemails.com/](https://relayemails.com/)
- Web app & API: [https://app.relayemails.com/](https://app.relayemails.com/)

### Features
- Create custom or random aliases, manage mailboxes, custom domains & contacts
- Built for iOS 26: Liquid Glass buttons, a tab bar that minimizes while scrolling, a bottom accessory for
  one-tap "Random alias" / "New alias", and a sidebar on iPad
- **Apple Intelligence**: on-device alias prefix suggestions when creating an alias (Foundation Models, nothing
  leaves the device)
- Swipe actions, context menus, pull to refresh
- **Siri & Shortcuts**: "Create a random alias with RelayEmail" works out of the box, and can be assigned to the Action button
- **Widgets & Controls**: Home Screen widget (small/medium), Lock Screen widgets and a Control Center /
  Action button control to create a random alias in one tap (`RelayEmailWidgets` extension)
- **Home Screen quick actions**: long press the app icon to create a random alias, a custom alias, or search
- **Spotlight**: search your aliases from the Home Screen and tap a result to copy it
- **Deep links**: `relayemail://create`, `relayemail://random`, `relayemail://search`, `relayemail://aliases`
- In-context tips (TipKit), Face ID / Touch ID / Optic ID lock, light/dark/system appearance
- Keyboard extension and share extension to create aliases from any app

### Configuration
- Default API URL: `https://app.relayemails.com/` (see `kDefaultApiUrlString` in `Utils/GlobalConstants.swift`)
- Brand links & support email: `Brand` in `Utils/GlobalConstants.swift`
- "Log in with Proton" is disabled by default: see `protonLoginEnabled` in `Utils/FeatureFlags.swift`
- Identifiers: bundle IDs `com.relayemails.ios-app` (+ `.share-extension`, `.keyboard-extension`, `.widgets`),
  App Group `group.com.relayemails.ios`, Keychain group `com.relayemails.ios-app.shared`, in-app purchases
  `com.relayemails.ios_app.subscription.premium.monthly|yearly`. Register them in your Apple Developer account and
  set your own team ID (`DEVELOPMENT_TEAM` and the Keychain group prefixes) before shipping.
- The API client is the open source `SimpleLoginPackage` Swift package, which RelayEmail's API is compatible with.

## License
Copyright (c) 2019-2022 SimpleLogin
Copyright (c) 2026 RelayEmail

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
