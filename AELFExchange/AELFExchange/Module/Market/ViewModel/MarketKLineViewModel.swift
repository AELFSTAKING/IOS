//
//  MarketKLineViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

enum MarketDetailOrderTypeEnum: Int {
    case depthAndDelegateOrder
    case latestDeal
}

@objc class MarketKLineViewModel: NSObject {
    
    var data: SymbolsItem? {
        didSet {
            self.symbol = data?.symbol ?? ""
        }
    }
    @objc dynamic var symbol = ""
    var currency: String?
    
    @objc dynamic var klineRange = Consts.kKLineRangeDefault
    
    @objc dynamic var currencyDecimalLenMax = Config.digitalDecimalLenMax
    @objc dynamic var baseCurrencyDecimalLenMax = Config.digitalDecimalLenMax
    
    var isKlineRightEdge = true
    var isTimelineMode = false
    var klineData = NSMutableArray()
    let (klineDataLoadedSignal, klineDataLoadedObserver) = Signal<Bool, NoError>.pipe()
    let (klineDataAppendedSignal, klineDataAppendedObserver) = Signal<Bool, NoError>.pipe()
    let (marketBaseInfoLoadedSignal, marketBaseInfoLoadedObserver) = Signal<[SymbolsItem], NoError>.pipe()
    
    @objc dynamic var orderType = MarketDetailOrderTypeEnum.latestDeal.rawValue
    
    /// 当前委托订单&最新成交订单.
    var depthMenuConfigOfCurrentSymbol: DepthConfigData?
    @objc dynamic var depth = Consts.kDepthDefault
    @objc dynamic var depthForMenuDisplay = Consts.kDepthMenuDefault
    
    let (ordersLoadedSignal, ordersLoadedObserver) = Signal<Bool, NoError>.pipe()
    let (ordersLoadedFromRESTAPISignalForSubscriber, ordersLoadedFromRESTAPIObserverForSubscriber) = Signal<Bool, NoError>.pipe()
    var delegateOrdersData: OrdersDelegateData?
    var delegateOrdersCount = 0
    var delegateOrdersTotalQuantityBuy: Float = 0.0
    var delegateOrdersTotalQuantitySell: Float = 0.0
    
    @objc dynamic var latestDealOrdersData = NSMutableArray()
    
    /// 深度.
    let (depthLoadedSignal, depthLoadedObserver) = Signal<Bool, NoError>.pipe()
    var depthDataResponse: DepthDataResponse?
    var depthDatas = [CHKDepthChartItem]()
    var depthMaxAmount = 0.0
    @objc dynamic var depthPercent = "0.00%"
    
    // MARK: Base Info.
    func loadMarketBaseInfoAndDisplayIfNeeded() {
        guard !self.symbol.isEmpty else { return }
        Network.post(withUrl: URLs.shared().genUrl(with: .allMarketSymbols), to: SymbolResponse.self) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let allSymbolList = response.data else {
                return
            }
            self?.marketBaseInfoLoadedObserver.send(value: allSymbolList)
        }
    }
    
}

// MARK: KLine.
extension MarketKLineViewModel {
    
    func loadKlineHistory(_ completion: @escaping (() -> ())) -> Void {
        let current = Int64(Date().timeIntervalSince1970)
        let before = current-Int64(self.klineRange)!/1000*256
        let params = [
            "symbol":self.data?.symbol ?? "",
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

// MARK: - Depth Data.
extension MarketKLineViewModel {
    
    func loadDepthData() -> Void {
        let params = [
            "symbol":self.symbol
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .depthData), params: params, to: DepthDataResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            self?.gotDepthData(with: response, succeed: succeed)
        }) { [weak self] (succeed, response) in
            self?.gotDepthData(with: response, succeed: succeed)
        }
    }
    
    func gotDepthData(with response: DepthDataResponse, succeed: Bool) -> Void {
        self.depthDataResponse = response
        guard succeed == true,
            response.succeed == true,
            let data = response.data,
            let bids = data.bids,
            let asks = data.asks,
            bids.count > 0,
            asks.count > 0 else {
                return
        }
        
        DispatchQueue.main.async {
            self.depthDatas.removeAll()
            for item in bids {
                let model = CHKDepthChartItem()
                model.value = CGFloat(Double(item.price ?? "0.0") ?? 0.0)
                model.amount = CGFloat(Double(item.quantity ?? "0.0") ?? 0.0)
                model.type = .bid
                self.depthDatas.append(model)
            }
            for item in asks {
                let model = CHKDepthChartItem()
                model.value = CGFloat(Double(item.price ?? "0.0") ?? 0.0)
                model.amount = CGFloat(Double(item.quantity ?? "0.0") ?? 0.0)
                model.type = .ask
                self.depthDatas.append(model)
            }
            self.depthMaxAmount = Double(data.yQuantity ?? "0.0") ?? 0.0
            self.depthPercent = "\(data.depthPercent ?? "--")%"
            self.depthLoadedObserver.send(value: true)
        }
    }
    
}

// MARK: - Orders.
extension MarketKLineViewModel {
    
    func loadOrders() -> Void {
        if self.orderType == MarketDetailOrderTypeEnum.depthAndDelegateOrder.rawValue {
            let params = [
                "depthStep":self.depth,
                "symbol":self.data?.symbol ?? ""
            ]
            Network.post(withUrl: URLs.shared().genUrl(with: .delegateOrders), params: params, withoutDataField: true, to: OrdersDelegateResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
                self?.gotDelegateOrder(with: response, succeed: succeed)
                self?.ordersLoadedFromRESTAPIObserverForSubscriber.send(value: true)
            }) { [weak self] (succeed, response) in
                self?.gotDelegateOrder(with: response, succeed: succeed)
                self?.ordersLoadedFromRESTAPIObserverForSubscriber.send(value: true)
            }
        } else {
            let params = [
                "symbol":self.data?.symbol ?? ""
            ]
            Network.post(withUrl: URLs.shared().genUrl(with: .latestOrderDeal), params: params, withoutDataField: true, to: OrdersLatestdealResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
                self?.gotLatestDealOrder(with: response, succeed: succeed)
                self?.ordersLoadedFromRESTAPIObserverForSubscriber.send(value: true)
            }) { [weak self] (succeed, response) in
                self?.gotLatestDealOrder(with: response, succeed: succeed)
                self?.ordersLoadedFromRESTAPIObserverForSubscriber.send(value: true)
            }
        }
    }
    
    func gotDelegateOrder(with response: OrdersDelegateResponse, succeed: Bool) -> Void {
        guard succeed == true, response.succeed == true, let data = response.data else {
            InfoToast(withLocalizedTitle: response.msg)
            self.ordersLoadedObserver.send(value: true)
            return
        }
        
        DispatchQueue.main.async {
            if  var askList = data.askList,
                var bidList = data.bidList {
                self.delegateOrdersTotalQuantityBuy = 0
                self.delegateOrdersTotalQuantitySell = 0
                for item in bidList {
                    if let q = item.quantity, let qv = Float(q) {
                        self.delegateOrdersTotalQuantityBuy += qv
                    }
                }
                for item in askList {
                    if let q = item.quantity, let qv = Float(q) {
                        self.delegateOrdersTotalQuantitySell += qv
                    }
                }
                self.delegateOrdersCount = max(askList.count, bidList.count)
                
                // Insert the EmptyItemData if needed.
                if askList.count != bidList.count {
                    let distance = abs(askList.count-bidList.count)
                    for _ in 0..<distance {
                        let i = OrdersDelegateOrderItem()
                        i.isEmptyCell = true
                        if askList.count < bidList.count {
                            askList.append(i)
                        } else {
                            bidList.append(i)
                        }
                    }
                    data.askList = askList
                    data.bidList = bidList
                }
            }
            self.delegateOrdersData = data
            self.ordersLoadedObserver.send(value: true)
        }
    }
    
    func gotLatestDealOrder(with response: OrdersLatestdealResponse, succeed: Bool) -> Void {
        DispatchQueue.main.async {
            guard succeed == true, response.succeed == true, let list = response.data else {
                InfoToast(withLocalizedTitle: response.msg)
                self.ordersLoadedObserver.send(value: true)
                return
            }
            self.latestDealOrdersData.removeAllObjects()
            self.latestDealOrdersData.addObjects(from: list)
            self.ordersLoadedObserver.send(value: true)
        }
    }
    
}

// MARK: - Config.
extension MarketKLineViewModel {
    
    func loadDepthConfig() -> Void {
        guard let symbol = self.data?.symbol else { return }
        MarketManager.shared().depthConfig(of: symbol) { [weak self] (depthConfig) in
            self?.depthMenuConfigOfCurrentSymbol = depthConfig
            if let depDisplay = depthConfig?.menuForDisplayObjs.last {
                self?.depthForMenuDisplay = depDisplay
            }
            if let dep = depthConfig?.apiObjs.last {
                self?.depth = dep
            }
        }
    }
    
    func loadDecimalLenConfig() -> Void {
        MarketManager.shared().tradeSymbolConfig(of: self.symbol) { [weak self] (symbolConfig) in
            guard let symbolConfig = symbolConfig else { return }
            self?.currencyDecimalLenMax = Int(symbolConfig.quantityScale ?? "\(Config.digitalDecimalLenMax)") ?? Config.digitalDecimalLenMax
            self?.baseCurrencyDecimalLenMax = Int(symbolConfig.quantityScale ?? "\(Config.digitalDecimalLenMax)") ?? Config.digitalDecimalLenMax
        }
    }
    
}
