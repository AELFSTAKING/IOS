//
//  WithdrawViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

enum WithdrawMode: String {
    
    // 提现，走kofo闪对流程.
    case withdraw = "提现"
    
    // 转账，直接签名发送.
    case transfer = "转账"
    
}

enum WithdrawBTCAddressType: String {
    case normal = "普通"
    case segwit = "隔离见证"
}

@objc class WithdrawViewModel: NSObject {
    
    var mode = WithdrawMode.withdraw
    
    @objc dynamic var currency: String?
    
    @objc dynamic var availableAmount = "--"
    @objc dynamic var availableAmountUsd = "--"
    @objc dynamic var ethBalance = "--"
    var usdtPrice = "0.0"
    
    @objc dynamic var digitalQuantity = "0.0"
    
    @objc dynamic var addressFrom = AELFIdentity.wallet_eth?.address ?? "--"
    
    @objc dynamic var addressTo = ""
    @objc dynamic var addressToBTCType = WithdrawBTCAddressType.normal.rawValue
    
    @objc dynamic var gasPrice: String?
    
    @objc dynamic var password = ""
    
    var defaultGasInited = false
    var gasInfoData: ETHGassInfoData?
    let (gasInfoLoadedSignal, gasInfoLoadedObserver) = Signal<Bool, NoError>.pipe()
    
    func load() {
        self.loadBalance()
        self.loadGasConfigInfo()
    }
    
    /// 转账.
    ///
    /// - Returns: signal.
    func transferSignal() -> Signal<Bool, NoError> {
        let (signal, observer) = Signal<Bool, NoError>.pipe()
        
        // 1、创建转账交易.
        let chain = AELFChainName.Ethereum.rawValue
        var paramData = [
            "amount":self.digitalQuantity,
            "receiver":self.addressTo,
            "sender":self.addressFrom
        ]
        if let gas = self.gasPrice {
            paramData["gasPrice"] = gas
        }
        let params = [
            "chain":chain,
            "currency":self.currency ?? "",
            "data":paramData
            ] as [String : Any]
        Network.post(
            withUrl: URLs.shared().genGatewayUrl(with: .gatewayTransTxCreate),
            params: params,
            withoutDataField: true,
            header: ["chain":chain],
            to: ETHCreateTransferTxResponse.self
        ) { (succeed, response) in
            guard succeed == true, response.succeed == true else {
                InfoToast(withLocalizedTitle: response.msg)
                observer.send(value: false)
                observer.sendCompleted()
                return
            }
            
            guard let rawTx = response.data?.rawTransaction else {
                InfoToast(withLocalizedTitle: "创建交易信息错误")
                observer.send(value: false)
                observer.sendCompleted()
                return
            }
            
            // 2、签名tx.
            do {
                try AELFWalletManager.signETH(for: rawTx, password: self.password, completion: { (signature) in
                    
                    guard signature.count > 0 else {
                        InfoToast(withLocalizedTitle: "签名失败")
                        observer.send(value: false)
                        observer.sendCompleted()
                        return
                    }
                    
                    // 3、Gateway发送交易上链，完成后Gateway服务负责回调状态到业务服务器.
                    let sParams = [
                        "chain":chain,
                        "currency":self.currency ?? "",
                        "data":[
                            "signedRawTransaction":signature
                        ]] as [String : Any]
                    Network.post(
                        withUrl: URLs.shared().genGatewayUrl(with: .gatewayTransTxSend),
                        params: sParams,
                        withoutDataField: true,
                        header: ["chain":chain],
                        to: SendOrderTxResponse.self
                    ) { (gSucceed, gResponse) in
                        guard gSucceed == true, gResponse.succeed == true, let _ = gResponse.data?.txHash else {
                            InfoToast(withLocalizedTitle: "发送交易失败:\(gResponse.msg ?? "")")
                            observer.send(value: false)
                            observer.sendCompleted()
                            return
                        }
                        observer.send(value: true)
                        observer.sendCompleted()
                    }
                    
                })
            } catch {
                AELFIdentity.errorToast(withError: error)
            }
        }
        return signal
    }
    
    /// 提现.
    ///
    /// - Returns: signal.
    func withdrawSignal() -> Signal<Bool, NoError> {
        let (signal, observer) = Signal<Bool, NoError>.pipe()
        
        // 1、创建提现订单，Rest服务想kofo发起闪对兑换单交易.
        let chain = AELFChainName.Ethereum.rawValue
        var params = [
            "kofoId":KofoSDKManager.shared().getKofoID() ?? "",
            "chain":chain,
            "currency":self.currency ?? "",
            "amount":self.digitalQuantity,
            "fromAddress":self.addressFrom,
            "toAddress":self.addressTo
            ] as [String : Any]
        let paramsUrl = params.sorted { (a, b) -> Bool in
            return a.key.compare(b.key) == .orderedAscending
            }.map { (k, v) -> String in
                return "\(k)=\(v)"
        }.joined(separator: "&")
        params["takerSignature"] = KofoSDKManager.shared().sign(forMsg: paramsUrl)
        Network.post(
            withUrl: URLs.shared().genUrl(with: .createWithdraw),
            params: params,
            to: CreateWithdrawResponse.self
        ) { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                InfoToast(withLocalizedTitle: response.msg)
                observer.send(value: false)
                observer.sendCompleted()
                return
            }
            
            guard let _ = data.withdrawNo else {
                InfoToast(withLocalizedTitle: "创建交易信息错误")
                observer.send(value: false)
                observer.sendCompleted()
                return
            }
            
            data.makerCurrency = data.makerCurrency?.lowercased()
            data.takerCurrency = data.takerCurrency?.lowercased()
            data.makerChain = data.makerChain?.lowercased()
            data.takerChain = data.takerChain?.lowercased()
            
            // 2、拿到兑换单信息发起闪对交易，流程同KOFO，完成后Gateway回调Rest.
            KofoSDKManager.shared().submitFlahsOrder(withResponse: data, completion: { (result) in
                guard result?.succeed == true, let _ = result?.txHash else {
                    InfoToast(withLocalizedTitle: "发送交易失败:\(result?.message ?? "")")
                    DispatchQueue.main.async {
                        observer.send(value: false)
                        observer.sendCompleted()
                    }
                    return
                }
                DispatchQueue.main.async {
                    observer.send(value: true)
                    observer.sendCompleted()
                }
            })
        }
        return signal
    }
    
}

// MARK: - Common.
extension WithdrawViewModel {
    
    func loadBalance() {
        // Token.
        UserInfoManager.shared().asset(forCurrency: self.currency?.removeTokenPrefix() ?? "") { [weak self] (data) in
            self?.availableAmountUsd = data?.usdtPrice ?? "--"
            self?.availableAmount = data?.balance ?? "--"
            self?.usdtPrice = data?.usdtPrice ?? "0.0"
        }
        
        // Main Wallet(ETH).
        let chain = AELFChainName.Ethereum.rawValue
        let params = [
            "chain":chain,
            "currency":chain,
            "data":[
                "address":AELFIdentity.wallet_eth?.address ?? ""
            ]] as [String : Any]
        Network.post(
            withUrl: URLs.shared().genGatewayUrl(with: .gatewayBalance),
            params: params,
            withoutDataField: true,
            header: ["chain":chain],
            to: ETHBalanceResponse.self
        ) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            self?.ethBalance = data.amount ?? ""
        }
    }
    
    func loadGasConfigInfo() {
        let chain = AELFChainName.Ethereum.rawValue
        let params = [
            "chain":chain,
            "currency":self.currency ?? "",
            "data":[
                "type":self.mode == .transfer ? "transfer":"approve"
            ]] as [String : Any]
        Network.post(
            withUrl: URLs.shared().genGatewayUrl(with: .gatewayGasFeeInfo),
            params: params,
            withoutDataField: true,
            header: ["chain":chain],
            to: ETHGassInfoResponse.self
        ) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            self?.gasInfoData = data
            self?.gasInfoLoadedObserver.send(value: true)
        }
    }
    
}

// MARK: - Address.
extension WithdrawViewModel {
    
}
