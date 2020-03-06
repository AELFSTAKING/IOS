//
//  MarketManager.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

@objc class MarketManager: NSObject {
    
    fileprivate static let ___donotUseThisVariableOfMarketManager = MarketManager()
    
    @discardableResult
    static func shared() -> MarketManager {
        return MarketManager.___donotUseThisVariableOfMarketManager
    }
    
    private var allSymbols = [SymbolsItem]()
    
    func allGroupSymbols(_ completion: @escaping (([SymbolsItem]) -> ())) {
        var returned = false
        if self.allSymbols.count > 0 {
            returned = true
            completion(self.allSymbols)
        }
        Network.post(withUrl: URLs.shared().genUrl(with: .markeyGroup), params: nil, to: MarketSymbolGroupedResponse.self, useCache: true, cacheCallback: { (_, _) in }) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                return
            }
            var tmpArr = [SymbolsItem]()
            for group in data {
                if let list = group.list {
                    for case let item in list where item.isShow == true || Config.shared().showMarket == true {
                        tmpArr.append(item)
                    }
                }
            }
            if tmpArr.count > 0 {
                self?.allSymbols.removeAll()
                self?.allSymbols.append(contentsOf: tmpArr)
                if returned == false {
                    completion(tmpArr)
                }
            }
        }
    }
    
    func allExchangeSymbolLatest(withCache cache: Bool = false, completion: @escaping (([AllMarketSymbolData]) -> ())) -> Void {
        Network.post(withUrl: URLs.shared().genUrl(with: .allMarketSymbols), to: AllMarketSymbolResponse.self, useCache: true, cacheCallback: { (succeed, response) in
            guard cache == true, succeed == true, response.succeed == true, let data = response.data else { return }
            completion(data)
        }) { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                completion([AllMarketSymbolData]())
                return
            }
            completion(data)
        }
    }
    
    func allExchangeSymbol(_ completion: @escaping (([SymbolsItem]) -> ())) -> Void {
        Network.post(withUrl: URLs.shared().genUrl(with: .allMarketSymbols), to: SymbolResponse.self) { (succeed, response) in
            guard succeed == true, response.succeed == true, let list = response.data else {
                return
            }
            DB.shared().sync2db4exchangeSymbols(with: list, for: .market)
            //guard hasCache == false else { return } // 暂时屏蔽缓存，因为改表结构必须卸载安装应用.
            completion(list)
        }
    }
    
    func defaultExchangeSymbol(_ completion: @escaping ((SymbolsItem) -> ())) -> Void {
        self.allExchangeSymbol { (symbols) in
            for symbol in symbols {
                if symbol.isShow == true || Config.shared().showMarket == true {
                    completion(symbol)
                    break
                }
            }
        }
    }
    
}

// MARK: - Config.
extension MarketManager {
    
    func depthConfig(of symbol: String, completion: @escaping ((DepthConfigData?) -> ())) -> Void {
        var hasCache = false
        let cache = DB.shared().rm.objects(DepthConfigEntity.self).filter("symbol = '\(symbol)'")
        if cache.count > 0 {
            hasCache = true
            var depths = [String]()
            for item in cache {
                if let d = item.depth {
                    depths.append(d)
                }
            }
            let config = DepthConfigData(with: depths, menuForDisplayObjs: self.depthConfigForDisplayMenus(for: depths))
            if config.apiObjs.count == config.menuForDisplayObjs.count {
                completion(config)
            }
        }
        
        // Fetch from remotes.
        let params = [
            "symbol":symbol
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .depthConfig), params: params, withoutDataField: true, to: DepthConfigResponse.self) { (succeed, response) in
            guard succeed == true, response.succeed == true, let list = response.data else {
                return
            }
            DB.shared().sync2db4depthConfig(with: list, symbol: symbol)
            guard hasCache == false else { return }
            let config = DepthConfigData(with: list, menuForDisplayObjs: self.depthConfigForDisplayMenus(for: list))
            if config.apiObjs.count == config.menuForDisplayObjs.count {
                completion(config)
            }
        }
    }
    
    func depthConfigForDisplayMenus(for depthList: [String]) -> [String] {
        guard depthList.count > 0 else { return [String]() }
        var menus = [String]()
        for item in depthList {
            menus.append(LOCSTR(withKey: "{}位小数").replacingOccurrences(of: "{}", with: "\(item.count(of: "0"))"))
        }
        return menus
    }
    
    func tradeSymbolConfig(of symbol: String, completion: @escaping ((TradeSymbolInfoData?) -> ())) -> Void {
        /*
        var hasCache = false
        if let cache = DB.shared().rm.objects(TradeSymbolInfoEntity.self).filter("symbol = '\(symbol)'").first, useCache == true {
            hasCache = true
            let config = TradeSymbolInfoData()
            config.symbol = cache.symbol
            config.availableSell = cache.availableSell
            config.availableBuy = cache.availableBuy
            config.productCoinQuantityMin = cache.productCoinQuantityMin
            config.productCoinQuantityMax = cache.productCoinQuantityMax
            config.currencyCoinQuantityMin = cache.currencyCoinQuantityMin
            config.currencyCoinQuantityMax = cache.currencyCoinQuantityMax
            config.priceBestBuy = cache.priceBestBuy
            config.priceBestSell = cache.priceBestSell
            config.tradeStatus = cache.tradeStatus
            config.productCoinQuantityScale = cache.productCoinQuantityScale
            config.currencyCoinQuantityScale = cache.currencyCoinQuantityScale
            config.priceScale = cache.priceScale
            config.deviation = cache.deviation
            config.amountScale = cache.amountScale
            config.minAmount = cache.minAmount
            config.maxAmount = cache.maxAmount
            completion(config)
        }*/
        
        // Fetch from remotes.
        let params = [
            "symbol":symbol,
            "address":AELFIdentity.wallet_eth?.address ?? ""
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .tradeSymbolInfo), params: params, withoutDataField: true, to: TradeSymbolInfoResponse.self) { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                completion(nil)
                return
            }
            DB.shared().sync2db4tradeSymbolConfig(with: data)
            //if useCache == true && hasCache == true { return }
            completion(data)
        }
    }
    
    func usdtPrice(of currency: String, completion: @escaping ((String) -> ())) {
        let params = [
            "currency":currency
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .usdtPrice), params: params, withoutDataField: true, to: USDTPriceResponse.self, useCache: true, cacheCallback: { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else { return }
            completion(data)
        }) { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else { return }
            completion(data)
        }
    }
    
}

// MARK: - Order.
extension MarketManager {

    func userOrders(withType type: UserOrderTypeEnum = .current, page: Int = 1, size: Int = Config.generalListCountOfSinglePage, useCache: Bool = true, completion: @escaping ((_ data: [UserOrdersListData]?, _ fromCache: Bool) -> ())) {
        guard AELFIdentity.hasIdentity() else {
            completion(nil, false)
            return
        }
        let params = [
            "address":AELFIdentity.wallet_eth?.address ?? "",
            "pageIndex":page,
            "pageSize":size
            ] as [String : Any]
        let url = URLs.shared().genUrl(with: type == .current ? .userOrdersCurrent:.userOrdersHistory)
        Network.post(withUrl: url, params: params, to: UserOrdersResponse.self, useCache: true, cacheCallback: { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data?.list, useCache == true else { return }
            completion(data, true)
        }) { (succeed, response) in
            guard succeed == true, response.succeed == true else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            completion(response.data?.list, false)
        }
    }
    
}
