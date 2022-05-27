//
//  RSFirebaseDestination.swift
//  RudderFirebase
//
//  Created by Abhishek Pandey on 04/03/22.
//

import Foundation
import Rudder
import Singular

class RSSingularDestination: RSDestinationPlugin {
    let type = PluginType.destination
    let key = "Singular"
    var client: RSClient?
    var controller = RSController()
    let rudderSingularConfig: RudderSingularConfig
    
    init(rudderSingularConfig: RudderSingularConfig) {
        self.rudderSingularConfig = rudderSingularConfig
    }

    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard type == .initial else { return }
        guard let singularConfig: RudderSingularServerConfig = serverConfig.getConfig(forPlugin: self) else {
            client?.log(message: "Failed to Initialize Singular Factory", logLevel: .warning)
            return
        }
        let config: SingularConfig = SingularConfig(apiKey: singularConfig.apiKey, andSecret: singularConfig.apiSecret)

        config.skAdNetworkEnabled = rudderSingularConfig.skAdNetworkEnabled
        config.manualSkanConversionManagement = rudderSingularConfig.manualSkanConversionManagement
        config.conversionValueUpdatedCallback = rudderSingularConfig.conversionValueUpdatedCallback
        config.waitForTrackingAuthorizationWithTimeoutInterval = rudderSingularConfig.waitForTrackingAuthorizationWithTimeoutInterval

        Singular.start(config)
        client?.log(message: "Initializing Singular SDK", logLevel: .debug)
    }

    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        if let userId = message.userId, !userId.isEmpty {
            Singular.setCustomUserId(userId)
        }
        return message
    }

    func track(message: TrackMessage) -> TrackMessage? {
        if !message.event.isEmpty {
            if let properties = message.properties, !properties.isEmpty {
                for (key, value) in properties {
                    // If it is a revenue event
                    if key == RSKeys.Ecommerce.revenue {
                        if let amount = Double("\(value)") {
                            Singular.customRevenue(message.event, currency: properties[RSKeys.Ecommerce.currency] as? String ?? "USD", amount: amount)
                        }
                        break
                    } else {
                        Singular.event(message.event, withArgs: properties)
                    }
                }
            } else {
                Singular.event(message.event)
            }
        }
        return message
    }

    func screen(message: ScreenMessage) -> ScreenMessage? {
        if !message.name.isEmpty {
            // Screen event with properties
            if let properties = message.properties {
                Singular.event("screen view \(message.name)", withArgs: properties)
            }
            // Screen events without properties
            else {
                Singular.event("screen view \(message.name)")
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

struct RudderSingularServerConfig: Codable {
    private let _apiKey: String?
    var apiKey: String {
        return _apiKey ?? ""
    }
    
    private let _apiSecret: String?
    var apiSecret: String {
        return _apiSecret ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case _apiKey = "apiKey"
        case _apiSecret = "apiSecret"
    }
}

@objc
open class RudderSingularConfig: NSObject {
    var skAdNetworkEnabled: Bool = false
    var manualSkanConversionManagement: Bool = false
    var conversionValueUpdatedCallback: ((Int) -> Void) = { _ in }
    var waitForTrackingAuthorizationWithTimeoutInterval: Int = 0
    
    @discardableResult @objc
    public func skAdNetworkEnabled(_ skAdNetworkEnabled: Bool) -> RudderSingularConfig {
        self.skAdNetworkEnabled = skAdNetworkEnabled
        return self
    }
    
    @discardableResult @objc
    public func manualSkanConversionManagement(_ manualSkanConversionManagement: Bool) -> RudderSingularConfig {
        self.manualSkanConversionManagement = manualSkanConversionManagement
        return self
    }
    
    @discardableResult @objc
    public func conversionValueUpdatedCallback(_ conversionValueUpdatedCallback: @escaping ((Int) -> Void)) -> RudderSingularConfig {
        self.conversionValueUpdatedCallback = conversionValueUpdatedCallback
        return self
    }
    
    @discardableResult @objc
    public func waitForTrackingAuthorizationWithTimeoutInterval(_ waitForTrackingAuthorizationWithTimeoutInterval: Int) -> RudderSingularConfig {
        self.waitForTrackingAuthorizationWithTimeoutInterval = waitForTrackingAuthorizationWithTimeoutInterval
        return self
    }
}

@objc
open class RudderSingularDestination: RudderDestination {

    @objc
    public init(rudderSingularConfig: RudderSingularConfig?) {
        super.init()
        plugin = RSSingularDestination(rudderSingularConfig: rudderSingularConfig ?? RudderSingularConfig())
    }
}
