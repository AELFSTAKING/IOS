//
//  OrderRecordsViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@objc class OrderRecordsViewModel: NSObject {
    
    var hideCanceledOrders = false
    
    var startAt = ""
    
    var symbol: String?
    
    var orderType = "" // MKT/LMT.
    
    var action = "" // BUY、SELL，买和卖，为空表示所有.
    
    @objc dynamic var data = NSMutableArray()
    
    let (shouldReloadUISignal, shouldReloadUIObserver) = Signal<Bool, NoError>.pipe()
    let (loadedSignal, loadedObserver) = Signal<Bool, NoError>.pipe()
    let (nomoreSignal, nomoreObservere) = Signal<Bool, NoError>.pipe()
    
    func load(withPage page: Int) -> Void {
        var params = [
            "pageRows":Config.generalListCountOfSinglePage,
            "currPage":page,
            "gmtStart":"0000000000000",
            "gmtEnd":"\(Int64(Date().timeIntervalSince1970))000",
            "orderStatus":"CLOSED"
            ] as [String : Any]
        if self.startAt.count > 0 {
            params["gmtStart"] = self.startAt
        }
        if let symbol = self.symbol {
            params["symbol"] = symbol
        }
        if self.orderType.count > 0 {
            params["orderType"] = self.orderType
        }
        if self.action.count > 0 {
            params["orderAction"] = self.action
        }
        if self.hideCanceledOrders {
            params["orderStatus"] = "DEAL"
        }
        
        Network.post(withUrl: URLs.shared().genUrl(with: .ordersCurrent), params: params, to: OrderRecordsResponse.self) { [weak self] (succeed, response) in
            TopController().stopLoadingHUD()
            self?.loadedObserver.send(value: true)
            guard succeed == true, response.succeed == true, let data = response.data?.list else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            if page == Config.startIndexOfPage {
                self?.data.removeAllObjects()
            }
            
            self?.data.addObjects(from: data)
            self?.shouldReloadUIObserver.send(value: true)
            
            if data.count < Config.generalListCountOfSinglePage {
                self?.nomoreObservere.send(value: true)
            }
        }
    }
    
    func reload() -> Void {
        self.load(withPage: Config.startIndexOfPage)
    }
    
}
