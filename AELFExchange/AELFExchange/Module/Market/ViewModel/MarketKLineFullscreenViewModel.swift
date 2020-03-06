//
//  MarketKLineFullscreenViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/2/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@objc class MarketKLineFullscreenViewModel: NSObject {
    
    var symbol = ""
    
    @objc dynamic var klineRange = Consts.kKLineRangeDefault
    
    var isKlineRightEdge = true
    var isTimelineMode = false
    var klineData = NSMutableArray()
    let (klineDataLoadedSignal, klineDataLoadedObserver) = Signal<Bool, NoError>.pipe()
    let (klineDataAppendedSignal, klineDataAppendedObserver) = Signal<Bool, NoError>.pipe()
    
    func loadKlineHistory(_ completion: @escaping (() -> ())) -> Void {
        let current = Int64(Date().timeIntervalSince1970)
        let before = current-Int64(self.klineRange)!/1000*256
        let params = [
            "symbol":self.symbol,
            "startTime":"\(before)000",
            "endTime":"\(current)000",
            "range":self.klineRange
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .klineHistory), params: params, withoutDataField: true, to: KLineResponse.self) { [weak self] (succeed, response) in
            completion()
            guard succeed == true, response.succeed == true, let list = response.data?.quotationHistory else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            
            DispatchQueue.global().async {
                var tmpArr = [CHChartItem]()
                for item in list {
                    let model = CHChartItem()
                    model.time = (Int(item.time ?? "0") ?? 0)/1000
                    model.openPrice = CGFloat(Double(item.first ?? "0") ?? 0.0)
                    model.highPrice = CGFloat(Double(item.max ?? "0") ?? 0.0)
                    model.lowPrice = CGFloat(Double(item.min ?? "0") ?? 0.0)
                    model.closePrice = CGFloat(Double(item.last ?? "0") ?? 0.0)
                    model.vol = CGFloat(Double(item.quantity ?? "0") ?? 0.0)
                    tmpArr.append(model)
                }
                self?.klineData.removeAllObjects()
                self?.klineData.addObjects(from: tmpArr)
                DispatchQueue.main.async {
                    self?.klineDataLoadedObserver.send(value: true)
                }
            }
        }
    }
    
    func appendKline(with item: KLineItem) -> Void {
        guard let thisTime = item.time,
            let thisTimeMs = Int64(thisTime),
            let latestItem = self.klineData.lastObject as? CHChartItem,
            thisTimeMs/1000 > Int64(latestItem.time) else {
                logdebug(content: "<< 重复的time of kline：\(item.time ?? "")")
                return
        }
        
        loginfo(content: "<< 有效的time of kline：\(item.time ?? "")")
        let model = CHChartItem()
        model.time = (Int(item.time ?? "0") ?? 0)/1000
        model.openPrice = CGFloat(Double(item.first ?? "0") ?? 0.0)
        model.highPrice = CGFloat(Double(item.max ?? "0") ?? 0.0)
        model.lowPrice = CGFloat(Double(item.min ?? "0") ?? 0.0)
        model.closePrice = CGFloat(Double(item.last ?? "0") ?? 0.0)
        model.vol = CGFloat(Double(item.quantity ?? "0") ?? 0.0)
        self.klineData.add(model)
        self.klineDataAppendedObserver.send(value: true)
    }
    
}
