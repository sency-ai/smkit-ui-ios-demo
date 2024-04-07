//
//  AppDelegate.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import UIKit
import SMKitUIDev

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SMKitUIModel.configure(authKey: "YOUR_KEY") {
            //The configurtion was seccessful
            DispatchQueue.main.async {
                AuthManager.shared.didFinishAuth = true
            }
        } onFailure: { error in
            //The configurtion failed with error
            DispatchQueue.main.async {
                AuthManager.shared.didFaildAuth = true
            }
        }

        return true
    }
}

