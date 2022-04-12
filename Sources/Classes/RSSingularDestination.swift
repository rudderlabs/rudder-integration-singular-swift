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
var conversionValueUpdatedCallback = { (_:Int) -> Void in return}
var waitForTrackingAuthorizationWithTimeoutInterval: Int = 0
var isInitialized: Bool = false

class RSSingularDestination: RSDestinationPlugin {
    let type = PluginType.destination
    let key = "Singular"
    var client: RSClient?
    var controller = RSController()

    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard type == .initial else { return }
        guard let singularConfig: SingularConfigs = serverConfig.getConfig(forPlugin: self) else {
            client?.log(message: "Failed to Initialize Singular Factory", logLevel: .warning)
            return
        }
        let config: SingularConfig = SingularConfig.init(apiKey: singularConfig.apiKey, andSecret: singularConfig.apiSecret)

        config.skAdNetworkEnabled = isSKANEnabled
        config.manualSkanConversionManagement = isManualMode
        config.conversionValueUpdatedCallback = conversionValueUpdatedCallback
        config.waitForTrackingAuthorizationWithTimeoutInterval = waitForTrackingAuthorizationWithTimeoutInterval

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

struct SingularConfigs: Codable {
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
public class RudderSingularDestination: RudderDestination {

    public override init() {
        super.init()
        plugin = RSSingularDestination()
    }

    public func setSKANOptions(skAdNetworkEnabled: Bool, isManualSkanConversionManagementMode manualMode: Bool,
                               withWaitForTrackingAuthorizationWithTimeoutInterval waitTrackingAuthorizationWithTimeoutInterval: NSNumber?,
                               withConversionValueUpdatedHandler conversionValueUpdatedHandler: @escaping (NSInteger) -> Void) {
        isSKANEnabled = skAdNetworkEnabled
        isManualMode = manualMode
        conversionValueUpdatedCallback = conversionValueUpdatedHandler
        waitForTrackingAuthorizationWithTimeoutInterval = waitTrackingAuthorizationWithTimeoutInterval?.intValue ?? 0
    }
}
