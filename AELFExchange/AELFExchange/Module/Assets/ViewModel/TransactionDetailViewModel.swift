//
//  TransactionDetailViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/7/29.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

struct TransactionDetailItem {
    var title: String
    var value: String?
}

@objc class TransactionDetailViewModel: NSObject {
    
    @objc dynamic var data = NSMutableArray()
    
    var txData: TransactionRecordsDataItem?
    
    func load() {
        let chain = AELFChainName.Ethereum.rawValue
        let currency = (self.txData?.currency ?? "").uppercased()
        let params = [
            "chain":chain,
            "currency":currency,
            "data":[
                "hash":self.txData?.hash ?? ""
            ]] as [String : Any]
        Network.post(
            withUrl: URLs.shared().genGatewayUrl(with: .gatewayTxDetailInfo),
            params: params,
            withoutDataField: true,
            header: ["chain":chain],
            to: ETHTransactionDetailResponse.self
        ) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            if let sender = self?.txData?.sender {
                self?.mutableArrayValue(forKey: "data").add(TransactionDetailItem(title: LOCSTR(withKey: "发送地址"), value: sender))
            }
            if let receiver = (self?.txData?.txType == "WITHDRAW" ? self?.txData?.withdrawReceiver:self?.txData?.receiver) {
                
                self?.mutableArrayValue(forKey: "data").add(TransactionDetailItem(title: LOCSTR(withKey: "接收地址"), value: receiver))
            }
            if let gas = data.fee {
                self?.mutableArrayValue(forKey: "data").add(TransactionDetailItem(title: LOCSTR(withKey: "矿工费"), value: "\(gas) \(chain)"))
            }
            if let blockHeight = data.blockNumber {
                self?.mutableArrayValue(forKey: "data").add(TransactionDetailItem(title: LOCSTR(withKey: "区块"), value: blockHeight))
            }
            if let timestamp = self?.txData?.timestamp {
                self?.mutableArrayValue(forKey: "data").add(TransactionDetailItem(title: LOCSTR(withKey: "交易时间"), value: timestamp.timestamp2date(withFormat: "yyyy-MM-dd HH:mm")))
            }
            if let hash = data.hash {
                self?.mutableArrayValue(forKey: "data").add(TransactionDetailItem(title: LOCSTR(withKey: "交易ID"), value: hash))
            }
        }
    }
    
}
