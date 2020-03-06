//
//  AELFWalletManager+ETH.swift
//  AELFExchange
//
//  Created by tng on 2019/7/29.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import WebKit
import PromiseKit

let CallbackEthSignRawTx = "ethSignRawTxCallback"

// MARK: - Extensions.
class ETHJSMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let content = message.body as? String {
            if message.name == CallbackEthSignRawTx {
                if let callback = AELFWalletManager.shared().ethSignRawTxCallback { callback(content) }
            }
        }
    }
}

// MARK: - Common.
extension AELFWalletManager {
    
    static func importEthereumWallet(withPrivateKey privateKey: String) -> Promise<AELFWalletModel?> {
        return Promise { seal in
            DispatchQueue.global().async {
                guard privateKey.count > 0 else {
                    logerror(content: "Invalid length of Ethereum Private Key.")
                    DispatchQueue.main.async { seal.reject(AELFWalletError.invalidParams) }
                    return
                }
                
                DispatchQueue.main.async {
                    let privKey = privateKey.replacingOccurrences(of: "0x", with: "")
                    let containedWallet = AELFWalletManager.shared().wallet_eth
                    let isFirstTimeToImport = (containedWallet == nil)
                    if containedWallet != nil {
                        let addr = containedWallet?.address ?? ""
                        if containedWallet?.privateKey == privKey {
                            logwarn(content: "The wallet(\(containedWallet?.address ?? "--")) is already exists.")
                            DispatchQueue.main.async { seal.resolve(containedWallet, nil) }
                        } else {
                            self.removeCustomWallet(byCurrency: .ETH)
                            logdebug(content: "Removed the latest Ethereum wallet that addr is: \(addr)")
                        }
                    }
                    
                    let js = "JSON.stringify(KofoWallet.importPrivateWallet({chain: 'ETH', currency: 'ETH', privateKey:'\(privKey)'}).export());"
                    let walletJson = AELFWalletManager.shared().kofoJsSDKUIWebView.stringByEvaluatingJavaScript(from: js)?.json2obj() as? [String:Any]
                    guard let walletObj = walletJson,
                        let address = walletObj["address"] as? String,
                        let publicKey = walletObj["publicKey"] as? String else {
                            logerror(content: "Failed to generate the wallet with private key, response: \(String(describing: walletJson))")
                            DispatchQueue.main.async { seal.reject(AELFWalletError.operationFailed) }
                            return
                    }
                    
                    let wallet = AELFWalletModel()
                    wallet.name = AELFWalletName.Ethereum.rawValue
                    wallet.currency = AELFCurrencyName.ETH.rawValue
                    wallet.chain = AELFChainName.Ethereum.rawValue
                    wallet.privateKey = privKey
                    wallet.publicKey = publicKey
                    wallet.address = address.contains("0x") ? address:"0x\(address)"
                    wallet.path = walletObj["path"] as? String
                    AELFWalletManager.shared().wallet_eth = nil
                    AELFWalletManager.shared().wallet_eth = wallet
                    
                    let param = [
                        "address":AELFIdentity.wallet_eth?.address ?? ""
                    ]
                    Network.post(withUrl: URLs.shared().genUrl(with: .registerAddress), params: param, to: BaseAPIBusinessModel.self, completionCallback: { (succeed, response) in
                        guard succeed == true, response.succeed == true else {
                            if isFirstTimeToImport {
                                AELFWalletManager.shared().wallet_eth = nil
                            }
                            DispatchQueue.main.async { seal.reject(AELFWalletError.unavailable) }
                            return
                        }
                        logdebug(content: "Succeed to import Ethereum wallet: \(wallet.address ?? "")")
                        DispatchQueue.main.async { seal.resolve(wallet, nil) }
                    })
                }
            }
        }
    }
    
    static func createEthereumWallet() -> Promise<AELFWalletModel?> {
        return Promise { seal in
            DispatchQueue.main.async {
                let js = "JSON.stringify(KofoWallet.createWallet({chain: 'ETH', currency: 'ETH'}).wallet.signingKey);"
                let walletJson = AELFWalletManager.shared().kofoJsSDKUIWebView.stringByEvaluatingJavaScript(from: js)?.json2obj() as? [String:Any]
                guard let walletObj = walletJson,
                    let address = walletObj["address"] as? String,
                    let publicKey = walletObj["publicKey"] as? String,
                    let privateKey = walletObj["privateKey"] as? String else {
                        logerror(content: "Failed to generate the wallet with private key, response: \(String(describing: walletJson))")
                        DispatchQueue.main.async { seal.reject(AELFWalletError.operationFailed) }
                        return
                }
                
                let wallet = AELFWalletModel()
                wallet.name = AELFWalletName.Ethereum.rawValue
                wallet.currency = AELFCurrencyName.ETH.rawValue
                wallet.chain = AELFChainName.Ethereum.rawValue
                wallet.privateKey = privateKey
                wallet.publicKey = publicKey
                wallet.address = address.contains("0x") ? address:"0x\(address)"
                wallet.path = walletObj["path"] as? String
                wallet.mnemonic = walletObj["mnemonic"] as? String
                AELFWalletManager.shared().wallet_eth = nil
                AELFWalletManager.shared().wallet_eth = wallet
                
                let param = [
                    "address":AELFIdentity.wallet_eth?.address ?? ""
                ]
                Network.post(withUrl: URLs.shared().genUrl(with: .registerAddress), params: param, to: BaseAPIBusinessModel.self, completionCallback: { (succeed, response) in
                    guard succeed == true, response.succeed == true else {
                        AELFWalletManager.shared().wallet_eth = nil
                        DispatchQueue.main.async { seal.reject(AELFWalletError.unavailable) }
                        return
                    }
                    logdebug(content: "Succeed to create The Ethereum Wallet: \(wallet.address ?? "")")
                    DispatchQueue.main.async { seal.resolve(wallet, nil) }
                })
            }
        }
    }
    
    /// Ethereum - 通过私钥导出公钥.
    static func ethPrivateKeyToPublic(for privateKey: String) -> String {
        let instanceName = "pubkey_\(timestamps())"
        let js =
        """
        \(instanceName) = KofoWallet.importPrivateWallet({chain: 'ETH', currency: 'ETH', privateKey:'\(privateKey)'}).export().publicKey;
        """
        let pubKey = AELFWalletManager.shared().kofoJsSDKUIWebView.stringByEvaluatingJavaScript(from: js)
        return pubKey ?? ""
    }
    
    /// Ethereum - 签名交易(RawTx).
    private func ethSignRawTx(withPrivateKey pk: String, rawTx: String) {
        let instanceName = "ethWallet_\(timestampms())"
        let sigInstanceName = "ethSig_\(timestampms())"
        let js =
        """
        \(instanceName) = KofoWallet.importPrivateWallet({chain: 'ETH', currency: 'ETH', privateKey:'\(pk)'});
        \(sigInstanceName) = \(instanceName).sign('\(rawTx)');
        \(sigInstanceName).then(value => window.webkit.messageHandlers.ethSignRawTxCallback.postMessage(value));
        """
        DispatchQueue.main.async { self.kofoJsSDKWebView.evaluateJavaScript(js) { (_, err) in } }
    }
    
    static func signETH(for rawTx: String, password: String, completion: @escaping ((String) -> ())) throws {
        // 'password' unused for now.
        if let eth = AELFWalletManager.shared().wallet_eth {
            do {
                guard let prvkey = eth.privateKey else {
                    throw AELFWalletError.noSuchPrivateKey
                }
                AELFWalletManager.shared().ethSignRawTxCallback = { (signature) in
                    completion(signature)
                }
                AELFWalletManager.shared().ethSignRawTx(withPrivateKey: prvkey, rawTx: rawTx)
            } catch {
                logerror(content: error.localizedDescription)
                throw error
            }
        } else {
            throw AELFWalletError.noSuchWallet
        }
    }
    
    static func syncSignETH(for rawTx: String) throws -> String? {
        if let eth = AELFWalletManager.shared().wallet_eth {
            do {
                guard let _ = eth.privateKey else {
                    throw AELFWalletError.noSuchPrivateKey
                }
                
                var sig = ""
                let signal = DispatchSemaphore(value: 0)
                
                try AELFWalletManager.signETH(for: rawTx, password: "") { (signature) in
                    sig = signature
                    signal.signal()
                }
                let _ = signal.wait(timeout: DispatchTime.now()+Consts.kGeneralOprTimeout)
                return sig
            } catch {
                logerror(content: error.localizedDescription)
                throw error
            }
        } else {
            throw AELFWalletError.noSuchWallet
        }
    }
    
}
