//
//  DepthDataResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class DepthDataItem: HandyJSON {
    
    var price: String?
    
    var quantity: String?
    
    /// 不明字段,暂时忽略.
    var stepValue: String?
    
    func samesAs(target: DepthDataItem?) -> Bool {
        return target?.price == price && target?.quantity == quantity
    }
    
    required init() {}
    
}

class DepthData: HandyJSON {
    
    var symbol: String?
    
    /// 买最高价.
    var bidsMaxPrice: String?
    
    /// 卖最低价.
    var asksMinPrice: String?
    
    /// 深度比例(暂时忽略).
    var depthPercent: String?
    
    /// x轴最小值(最小价格).
    var xMinPrice: String?
    
    /// x轴最大值(最大价格).
    var xMaxPrice: String?
    
    /// y轴最大数量.
    var yQuantity: String?
    
    /// 最新买单数据列表.
    var bids: [DepthDataItem]?
    
    /// 最新卖单数据列表.
    var asks: [DepthDataItem]?
    
    required init() {}
    
}

class DepthDataResponse: BaseAPIBusinessModel {
    
    var data: DepthData?
    
    func samesAs(target: DepthDataResponse?, completion: @escaping ((Bool) -> ())) {
        DispatchQueue.global().async {
            guard let responseBids = target?.data?.bids,
                let responseAsks = target?.data?.asks,
                let currentBids = self.data?.bids,
                let currentAsks = self.data?.asks else {
                    DispatchQueue.main.async { completion(false) }
                    return
            }
            for i in 0 ..< responseBids.count {
                guard i < currentBids.count else {
                    DispatchQueue.main.async { completion(false) }
                    return
                }
                if responseBids[i].samesAs(target: currentBids[i]) == false {
                    DispatchQueue.main.async { completion(false) }
                    return
                }
            }
            for i in 0 ..< responseAsks.count {
                guard i < currentAsks.count else {
                    DispatchQueue.main.async { completion(false) }
                    return
                }
                if responseAsks[i].samesAs(target: currentAsks[i]) == false {
                    DispatchQueue.main.async { completion(false) }
                    return
                }
            }
            DispatchQueue.main.async { completion(true) }
        }
    }
    
}
