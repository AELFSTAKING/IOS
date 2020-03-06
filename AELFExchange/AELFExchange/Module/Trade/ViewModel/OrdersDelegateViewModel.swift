//
//  CurrentDelegateOrderViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/24.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@objc class OrdersDelegateViewModel: NSObject {
    
    var symbol: String?
    
    @objc dynamic var hideOtherCurreny = false
    
    @objc dynamic var orderType = "" // MKT/LMT.
    
    @objc dynamic var action = "" // BUY、SELL，买和卖，为空表示所有.
    
    @objc dynamic var orderStatus = "OPEN" // CLOSED/DEAL/OPEN.
    
    @objc dynamic var data = NSMutableArray()
    
    let (updateSignal, updateObserver) = Signal<Bool, NoError>.pipe()
    
    func load(withPage page: Int) -> Void {
        var params = [
            /* 暂时尽可能全部load，撤单成功仅删除本地数据刷新UI不再刷新最新的当前委托订单（因为撤单接口为异步操作，立即刷新当前委托会造成不同步问题，暂时的workaround）. */
            "pageRows":999, //Config.generalListCountOfSinglePage,
            "currPage":page,
            "gmtStart":"0000000000000",
            "gmtEnd":"\(Int64(Date().timeIntervalSince1970))000",
            "symbol":self.symbol ?? "",
            "orderStatus":self.orderStatus
            ] as [String : Any]
        if self.orderType.count > 0 {
            params["orderType"] = self.orderType
        }
        if self.action.count > 0 {
            params["orderAction"] = self.action
        }
        if !self.hideOtherCurreny {
            params.removeValue(forKey: "symbol")
        }
        
        Network.post(withUrl: URLs.shared().genUrl(with: .ordersCurrent), params: params, to: OrderRecordsResponse.self) { [weak self] (succeed, response) in
            TopController().stopLoadingHUD()
            guard succeed == true, response.succeed == true, let data = response.data?.list else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            if page == Config.startIndexOfPage {
                self?.data.removeAllObjects()
            }
            self?.data.addObjects(from: data)
            self?.updateObserver.send(value: true)
        }
    }
    
    func cancelOrderSignal(with orderId: String) -> Signal<Bool, NoError> {
        // Do Cancel.
        let (signal, observer) = Signal<Bool, NoError>.pipe()
//        let params = [
//            "orderNo":orderId
//        ]
//        Network.post(withUrl: URLs.shared().genUrl(with: .cancelOrdeer), params: params, to: BaseAPIBusinessModel.self) { [weak self] (succeed, response) in
//            guard succeed == true, response.succeed == true else {
//                InfoToast(withLocalizedTitle: response.msg)
//                observer.send(value: false)
//                observer.sendCompleted()
//                return
//            }
//
//            // Remove local item first.
//            if let list = self?.data {
//                for item in list {
//                    if let item = item as? OrderRecordsDataItem, item.orderNo == orderId  {
//                        self?.data.remove(item)
//                        self?.updateObserver.send(value: true)
//                        break
//                    }
//                }
//            }
//
//            observer.send(value: true)
//            observer.sendCompleted()
//        }
        return signal
    }
    
}
