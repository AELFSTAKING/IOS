//
//  URLs.swift
//  AELF
//
//  Created by tng on 2018/9/9.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation

enum AELFUrlSuffix: String {
    
    /// The suffix of rest service path.
    
}

class URLs {
    
    fileprivate static let ___donotUseThisVariableOfURLs = URLs()
    
    static func shared() -> URLs {
        return ___donotUseThisVariableOfURLs
    }
    
    func apiDomain(withoutApis: Bool = false) -> String {
        var domain = domainTest
        switch Config.shared().environment {
        case .prod: domain = domainProd
        case .stage: domain = domainStage
        default:break
        }
        if withoutApis {
            return domain.replacingOccurrences(of: "/apis", with: "")
        }
        return domain
    }
    
    func genUrl(with suffix: AELFUrlSuffix, withoutDexSuffix: Bool = false) -> String {
        var url = "\(self.apiDomain())\(suffix.rawValue)"
        if withoutDexSuffix {
            url = url.replacingOccurrences(of: "/staking-dex", with: "")
        }
        return url
    }
    
    func genGatewayUrl(with suffix: AELFUrlSuffix) -> String {
        var domain = gatewayTest
        switch Config.shared().environment {
        case .prod: domain = gatewayProd
        case .stage: domain = gatewayStage
        default:break
        }
        return "\(domain)\(suffix.rawValue)"
    }
    
    func genEthBlockExplorerUrl(with txid: String) -> String {
        var domain = ethBlockchainUrlTest
        switch Config.shared().environment {
        case .prod: domain = ethBlockchainUrlProd
        case .stage: domain = ethBlockchainUrlStage
        default:break
        }
        return "\(domain)/tx/\(txid)"
    }
    
    func kofoMqttHost() -> String {
        switch Config.shared().environment {
        case .stage: return kofoMqttHostStage
        case .prod: return kofoMqttHostProd
        default: return kofoMqttHostTest
        }
    }
    
    func kofoMqttPort() -> UInt16 {
        switch Config.shared().environment {
        case .stage: return kofoMqttPortStage
        case .prod: return kofoMqttPortProd
        default: return kofoMqttPortTest
        }
    }
    
    func kofoSDKHost() -> String {
        switch Config.shared().environment {
        case .stage: return kofoSDKRestHostStage
        case .prod: return kofoSDKRestHostProd
        default: return kofoSDKRestHostTest
        }
    }
    
    // prod.
    let domainProd = ""//fixme:the rest server domain.
    let gatewayProd = ""//fixme:the gateway rest server domain.
    let kofoMqttHostProd = ""//fixme:mqtt host.
    let kofoMqttPortProd: UInt16 = 1883//fixme:mqtt port.
    let kofoSDKRestHostProd = ""//fixme:KOFO SDK rest server host.
    let ethBlockchainUrlProd = "https://etherscan.io/"
    
    // stage.
    let domainStage = ""
    let gatewayStage = ""
    let kofoMqttHostStage = ""
    let kofoMqttPortStage: UInt16 = 1883
    let kofoSDKRestHostStage = ""
    let ethBlockchainUrlStage = "https://etherscan.io/"
    
    // test.
    let domainTest = ""
    let gatewayTest = ""
    let kofoMqttHostTest = ""
    let kofoMqttPortTest: UInt16 = 1883
    let kofoSDKRestHostTest = ""
    let ethBlockchainUrlTest = "https://rinkeby.etherscan.io/"
    
    // MARK: - Config.
    public let ignoreLogUrls: [AELFUrlSuffix] = [
        .klineHistory
    ]
    public let ignoreSSLURLHosts = [""]
    
}
