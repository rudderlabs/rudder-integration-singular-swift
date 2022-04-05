//
//  RSFirebaseDestination.swift
//  RudderFirebase
//
//  Created by Pallab Maiti on 04/03/22.
//

import Foundation
import RudderStack
import Singular

var isSKANEnabled: Bool = false
var isManualMode: Bool = false
var conversionValueUpdatedCallback = { (_:Int) -> () in return}

var waitForTrackingAuthorizationWithTimeoutInterval: Int = 0
var isInitialized: Bool = false

class RSSingularDestination: RSDestinationPlugin {
    let type = PluginType.destination
    let key = "Singular"
    var client: RSClient?
    var controller = RSController()
        
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard type == .initial else { return }
        if let destination = serverConfig.getDestination(by: key) {
            if let apiKey = destination.config?.dictionaryValue?["apiKey"] as? String, let apiSecret = destination.config?.dictionaryValue?["apiSecret"] as? String {
                
                let config: SingularConfig = SingularConfig.init(apiKey: apiKey, andSecret: apiSecret)
                
                config.skAdNetworkEnabled = isSKANEnabled;
                config.manualSkanConversionManagement = isManualMode;
                config.conversionValueUpdatedCallback = conversionValueUpdatedCallback;
                config.waitForTrackingAuthorizationWithTimeoutInterval = waitForTrackingAuthorizationWithTimeoutInterval;
                
                Singular.start(config)
                client?.log(message: "Initializing Singular SDK", logLevel: .debug)
            } else {
                client?.log(message: "Failed to Initialize Singular Factory", logLevel: .warning)
            }
        }
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        if let userId = message.userId, !userId.isEmpty {
            Singular.setCustomUserId(userId)
        }
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        if !message.event.isEmpty {
            if let properties = message.properties, properties.count > 0 {
                // If it is a revenue event
                if let revenue: Double = properties["revenue"] as? Double, revenue != 0 {
                    let currency: String = properties["currency"] as? String ?? "USD"
                    Singular.customRevenue(message.event, currency: currency, amount: revenue)
                    return message
                }
                Singular.event(message.event, withArgs: properties)
                return message
            }
            Singular.event(message.event)
        }
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        if !message.name.isEmpty {
            if let properties = message.properties {
                Singular.event("screen view \(message.name)", withArgs: properties)
            }
        } else {
            client?.log(message: "Event name is not present.", logLevel: .debug)
        }
        return message
    }
    
    func reset() {
        Singular.unsetCustomUserId()
        client?.log(message: "Reset API is called.", logLevel: .debug)
    }
}

@objc
public class RudderSingularDestination: RudderDestination {
    
    public override init() {
        super.init()
        plugin = RSSingularDestination()
    }
    
    public func setSKANOptions(skAdNetworkEnabled: Bool, isManualSkanConversionManagementMode manualMode: Bool,
                               withWaitForTrackingAuthorizationWithTimeoutInterval waitTrackingAuthorizationWithTimeoutInterval: NSNumber?,
    withConversionValueUpdatedHandler conversionValueUpdatedHandler: @escaping (NSInteger) -> Void) {
        isSKANEnabled = skAdNetworkEnabled
        isManualMode = manualMode;
        conversionValueUpdatedCallback = conversionValueUpdatedHandler
        waitForTrackingAuthorizationWithTimeoutInterval = waitTrackingAuthorizationWithTimeoutInterval?.intValue ?? 0
    }
    
}
