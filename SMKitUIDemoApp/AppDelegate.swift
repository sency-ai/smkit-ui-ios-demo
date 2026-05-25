//
//  AppDelegate.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import UIKit
import SMKitUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var smKitUIAuthKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "SMKitUIAuthKey") as? String ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DemoSettingsStore.shared.applyToSDK()

        SMKitUIModel.configure(
            authKey: smKitUIAuthKey,
            includesHighlights: false
        ) {
            // The configuration was successful.
            DispatchQueue.main.async {
                AuthManager.shared.didFinishAuth = true
            }
        } onFailure: { error in
            // The configuration failed with error.
            DispatchQueue.main.async {
                AuthManager.shared.didFaildAuth = true
            }
        }

        return true
    }
}
