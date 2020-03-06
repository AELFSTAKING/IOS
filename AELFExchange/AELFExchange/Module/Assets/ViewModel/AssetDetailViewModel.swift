//
//  AssetDetailViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@objc class AssetDetailViewModel: NSObject {
    
    var currencyData: TotalAssetsDataItem?
    
    let (txRecordsNoMoreSignal, txRecordsNoMoreObserver) = Signal<Bool, NoError>.pipe()
    @objc dynamic var txRecords = NSMutableArray()
    
    var page = Config.startIndexOfPage
    
    func loadTxRecords() {
        let params = [
            "address":AELFIdentity.wallet_eth?.address ?? "",
            "currency":self.currencyData?.currency ?? "",
            "pageIndex":self.page,
            "pageSize":Config.generalListCountOfSinglePage
            ] as [String : Any]
        Network.post( withUrl: URLs.shared().genUrl(with: .transactionRecords), params: params, to: TransactionRecordsResponse.self) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data?.transactions else { return }
            if self?.page == 1 {
                self?.txRecords.removeAllObjects()
            }
            if data.count > 0 {
                self?.mutableArrayValue(forKey: "txRecords").addObjects(from: data)
            }
            if data.count < Config.generalListCountOfSinglePage {
                self?.txRecordsNoMoreObserver.send(value: true)
            }
        }
    }
    
}
