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

//        identifierForVendor()

        let config: RSConfig = RSConfig(writeKey: "27COeQCO3BS2WMw8CJUqYRC5hL7")
            .dataPlaneURL("https://rudderstacbumvdrexzj.dataplane.rudderstack.com")
            .loglevel(.none)
            .trackLifecycleEvents(false)
            .recordScreenViews(false)

        client = RSClient(config: config)

        let rudderSingularConfig = RudderSingularConfig()
            .skAdNetworkEnabled(true)
            .manualSkanConversionManagement(true)
            .conversionValueUpdatedCallback({ value in
                print("Your SKAN handler \(value)")
            })
            .waitForTrackingAuthorizationWithTimeoutInterval(0)
        
        client?.addDestination(RudderSingularDestination(rudderSingularConfig: rudderSingularConfig))

        sendEvents()

        return true
    }

    func sendEvents() {
        sendIdentifyEvents()
        sendTrackEvents()
        sendScreenEvents()
    }

    func sendScreenEvents() {
        client?.screen("Custom screen event with properties", properties: [
            "Key-1": "value-1",
            "Key-2": "value-2"
        ])
    }

    func sendTrackEvents() {
        client?.track("Empty track events")
        // Revenue Event
        client?.track("Order Completed", properties: [
            "revenue": 1000.0,
            "currency": "INR",
            "Key-1": "value-1",
            "Key-2": "value-2"
        ])
        client?.track("Checkout Started", properties: [
            "Key": "Value",
            "order_id": "12345",
            "Key-1": "value-1",
            "Key-2": "value-2",
            "products": [[
                "productId": 123,
                "name": "Random Name",
                "sku": "123",
                "price": 123.45,
                "quantity": "20",
                "category": "Shopping",
                "url": "www.example.com",
                "image_url": "www.example.com"
            ]]
        ])
    }

    func sendIdentifyEvents() {
        client?.identify("iOS User")
    }

    // Needed only for testing: This IDFV key needs to be registered at Singular for testing
    func identifierForVendor() {
        print(UIDevice.current.identifierForVendor?.uuidString ?? "IDFV value is not generated")
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
