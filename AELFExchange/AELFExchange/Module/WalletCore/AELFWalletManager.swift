//
//  AELFWalletManager.swift
//  AELFExchange
//
//  Created by tng on 2019/7/29.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import WebKit

class AELFWalletManager {
    
    // KOFO JS SDK.
    lazy var kofoJsSDKWebView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        let w = WKWebView(frame: CGRect(origin: .zero, size: CGSize(width: 10.0, height: 10.0)), configuration: config)
        w.isUserInteractionEnabled = false
        w.isHidden = true
        return w
    }()
    lazy var kofoJsSDKUIWebView: UIWebView = {
        let w = UIWebView(frame: CGRect(origin: .zero, size: CGSize(width: 10.0, height: 10.0)))
        w.isUserInteractionEnabled = false
        w.isHidden = true
        return w
    }()
    
    /// Ethereum - 签名交易(RawTx).
    var ethSignRawTxCallback: ((String) -> ())?
    
    fileprivate static let ___donotUseThisVariableOfAELFWalletManager = AELFWalletManager()
    
    @discardableResult
    static func shared() -> AELFWalletManager {
        return AELFWalletManager.___donotUseThisVariableOfAELFWalletManager
    }
    
    func kofoJsSDKWebSetup() {
        kofoJsSDKWebView.configuration.userContentController.add(ETHJSMessageHandler(), name: CallbackEthSignRawTx)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            kKeyWindow?.addSubview(self.kofoJsSDKWebView)
            kKeyWindow?.addSubview(self.kofoJsSDKUIWebView)
            self.kofoJsSDKWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "wallet", ofType: "html")!)))
            self.kofoJsSDKUIWebView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "wallet", ofType: "html")!)))
        }
    }
    
    // MARK: - Wallet Storages.
    var wallet_eth: AELFWalletModel? {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "wallet_eth") as? String {
                return AELFWalletModel.deserialize(from: theInstance)
            }
            return nil
        }
        set {
            if let obj = newValue, let value = obj.toJSONString() {
                UserDefaults.standard.setValue(value, forKey: "wallet_eth")
            } else {
                UserDefaults.standard.removeObject(forKey: "wallet_eth")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
}

// MARK: - Common Methods.
extension AELFWalletManager {
    
    static func removeCustomWallet(byCurrency currency: AELFCurrencyName) {
        guard let _ = AELFIdentity.shared().identity else { return }
        switch currency {
        case .ETH:
            AELFWalletManager.shared().wallet_eth = nil
            break
        default:
            logerror(content: "Failed to remove the wallet: \(currency.rawValue) caused no such wallet.")
            break
        }
    }
    
    static func isERC20(withCurrency currency: String, chain: String) -> Bool {
        return currency.uppercased().contains("ERC20") || (chain.uppercased() == AELFChainName.Ethereum.rawValue.uppercased() && chain.uppercased() != currency.uppercased())
    }
    
}

extension String {
    
    func removeTokenPrefix() -> String {
        return self.replacingOccurrences(of: "S-", with: "").replacingOccurrences(of: "s-", with: "")
    }
    
}
