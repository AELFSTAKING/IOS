//
//  GT3CaptchaManager.swift
//  AELFExchange
//
//  Created by tng on 2019/1/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import KofoCore
import PromiseKit

class KofoSDKManager {

    fileprivate static let ___donotUseThisVariableOfKofoSDKManager = KofoSDKManager()

    @discardableResult
    static func shared() -> KofoSDKManager {
        return KofoSDKManager.___donotUseThisVariableOfKofoSDKManager
    }

    private let kofoSDK = KofoCore()
    var statusCallback: ((_ connected: Bool) -> Void)?
    var makerBeginGenPreImageCallback: ((_ settlementId: String) -> Void)?

    @discardableResult
    func setup() -> Bool {
        let kofoId = kofoSDK.pair.kofoId
        let status = kofoSDK.setup(
            mqHost: URLs.shared().kofoMqttHost(),
            mqPort: URLs.shared().kofoMqttPort(),
            kofoId: kofoId,
            gatewayUrl: URLs.shared().kofoSDKHost(),
            settlementServerUrl: URLs.shared().kofoSDKHost(),
            language: .ZH_CN,
            delegate: self
        )
        logdebug(content: "<< kofo sdk init status: \(status)")
        return status
    }

    func allowedAccessToKofoSDK() -> Bool {
        return AELFIdentity.hasIdentity()
    }

    func getKofoID() -> String? {
        guard self.allowedAccessToKofoSDK() else {
            return nil
        }
        return self.kofoSDK.pair.kofoId
    }
    
    func sign(forMsg msg: String) -> String {
        return self.kofoSDK.sig(forMessage: msg)
    }

    func getKofoPair(withWalletPassword password: String) -> Promise<KofoPair?> {
        return Promise { seal in
            DispatchQueue.global().async {
                guard AELFIdentity.hasIdentity() else {
                    DispatchQueue.main.async { seal.resolve(nil, AELFWalletError.noSuchWalletIdentity) }
                    return
                }
                guard !password.isEmpty else {
                    DispatchQueue.main.async { seal.resolve(nil, AELFWalletError.invalidPassword) }
                    return
                }
                if password != AELFIdentity.shared().identity?.password {
                    DispatchQueue.main.async { seal.resolve(nil, AELFWalletError.invalidPassword) }
                }
                DispatchQueue.main.async { seal.resolve(self.kofoSDK.pair, nil) }
            }
        }
    }

}

extension KofoSDKManager {

    func sign(message content: String) -> String {
        guard self.allowedAccessToKofoSDK() else {
            return ""
        }
        return self.kofoSDK.sig(forMessage: content)
    }

    func verifySign(forMessage message: String, sig: String) -> Bool {
        guard self.allowedAccessToKofoSDK() else {
            return false
        }
        return self.kofoSDK.verify(forSignature: sig, message: message)
    }

}

// MARK: - Flahs Order Process.
extension KofoSDKManager {

    func submitFlahsOrder(withResponse response: CreateWithdrawData, completion: @escaping ((KofoFlashOrderResultBO?) -> ())) {
        guard let settlementId = response.settlementId,
            let chain = response.takerChain,
            let currency = response.takerCurrency,
            let amount = response.takerAmount,
            let sender = response.takerAddress,
            let receiver = response.takerCounterAddress else {
                completion(nil)
                return
        }

        self.submitFlahsOrderConfirm(
            settlementId: settlementId,
            chain: chain,
            currency: currency,
            amount: amount,
            h: "",
            lockTime: 7200,
            sender: sender,
            receiver: receiver,
            adminPubkey: "",
            isApproveTx: AELFWalletManager.isERC20(withCurrency: currency, chain: chain),
            isSegWitAddress: false
        ) { (bo) in
            completion(bo)
        }

    }

    private func submitFlahsOrderConfirm(
        settlementId: String,
        chain: String,
        currency: String,
        amount: String,
        h: String,
        lockTime: Int64,
        sender: String,
        receiver: String,
        adminPubkey: String? = nil,
        isApproveTx: Bool,
        isSegWitAddress: Bool?,
        completion: @escaping ((KofoFlashOrderResultBO?) -> ())
        ) {
        let order = KofoFlashOrderParamsBO(
            withSettlementId: settlementId,
            chain: chain,
            currency: currency,
            amount: amount,
            h: h,
            lockTime: lockTime,
            sender: sender,
            receiver: receiver,
            adminPubkey: adminPubkey,
            isApproveTx: isApproveTx,
            isSegWitAddress: isSegWitAddress
        )
        self.kofoSDK.submitFlashExOrder(withData: order) { (result) in
            completion(result)
        }
    }

}

// MARK: - Signature Callback.
extension KofoSDKManager: KofoCoreProtocol {

    /// MQTT连接状态.
    func kofoMqttConnectionStatus(isConnected connected: Bool) {
        if let callback = self.statusCallback { callback(connected) }
    }

    /// Maker开始生成Preimage.
    func kofoMakerGenPreimage(with settlementId: String, chain: KofoCoreOpenChainType) {
        if let callback = self.makerBeginGenPreImageCallback { callback(settlementId) }
    }

    /// 要求客户端签名.
    func kofoSignTransaction(for rawTransaction: KofoTransactionBO, settlementId: String, chain: KofoCoreOpenChainType) -> [String] {
        switch chain {
        case .ETH:
            if let raw = rawTransaction.rawTransaction?.first {
                do {
                    let result = try AELFWalletManager.syncSignETH(for: raw)
                    if let sig = result { return [sig] }
                } catch {
                    logerror(content: "AUTO-Sign ETH: Failed to sign for: \(chain.rawValue) with tx: \(raw) error: \(error)")
                    return [""]
                }
            }
            break
        default:break
        }
        logerror(content: "AUTO-Sign: Unknown ChainType: \(chain.rawValue)")
        return [""]
    }

}
