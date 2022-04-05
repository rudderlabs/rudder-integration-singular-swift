//
//  AppDelegate.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import RudderStack
import RudderSingular


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var client: RSClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        RudderSingularDestination().setSKANOptions(skAdNetworkEnabled: true, isManualSkanConversionManagementMode: true, withWaitForTrackingAuthorizationWithTimeoutInterval: 0, withConversionValueUpdatedHandler: { (num:Int) -> () in
            print (num)
        })
        
        let config: RSConfig = RSConfig(writeKey: "27COeQCO3BS2WMw8CJUqYRC5hL7")
            .dataPlaneURL("https://rudderstacbumvdrexzj.dataplane.rudderstack.com")
            .loglevel(.none)
            .trackLifecycleEvents(false)
            .recordScreenViews(false)
        
        client = RSClient(config: config)
        
        client?.add(destination: RudderSingularDestination())
        client?.track("Order Completed1", properties: [
            "Key" : "value",
            "value" : 56.7
        ])
        
        client?.identify("user 12", traits: [
            "Key" : "Value"
        ], option: nil)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension UIApplicationDelegate {
    var client: RSClient? {
        if let appDelegate = self as? AppDelegate {
            return appDelegate.client
        }
        return nil
    }
}
