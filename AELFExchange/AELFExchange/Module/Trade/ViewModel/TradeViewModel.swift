//
//  TradeViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/22.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

enum TradeViewModeEnum: String {
    case buy = "BUY"
    case sell = "SELL"
}

enum TradeViewOrderCurrentModeEnum: Int {
    case normal
    case buy
    case sell
}

enum TradeOrderTypeEnum: String {
    case limit = "限价单"
    case market = "市价单"
}

@objc class TradeViewModel: NSObject {
    
    var isNotTopLevel = false
    
    @objc dynamic var mode = TradeViewModeEnum.buy.rawValue
    @objc dynamic var ordersDelegateMode = TradeViewOrderCurrentModeEnum.normal.rawValue
    @objc dynamic var orderType = TradeOrderTypeEnum.limit.rawValue
    @objc dynamic var userOrdersType = UserOrderTypeEnum.current.rawValue
    
    var handleLatestPriceFromRESTAPICallback: ((_ price: String?, _ priceUSD: String?, _ price: PriceDirectionEnum) -> ())?
    
    /// 兑换币种.
    @objc dynamic var currency = ""
    
    /// 计价换算币种.
    @objc dynamic var baseCurrency = ""
    
    var symbolItem: SymbolsItem?
    @objc dynamic var symbol = "" {
        didSet {
            self.currency = symbol.currencyFromSymbol() ?? "--"
            self.baseCurrency = symbol.baseCurrencyFromSymbol() ?? "--"
            if symbol.count > 0 {
                self.loadDepthConfig()
                self.loadAssets()
            }
        }
    }
    
    @objc dynamic var digitalPrice = "0"
    
    @objc dynamic var legalAmount = "--"
    
    @objc dynamic var digitalQuantity = "0.00"
    
    @objc dynamic var availableAsset = "--"
    
    @objc dynamic var bestPrice2BuyOrSell: String?
    
    @objc dynamic var currencyDecimalLenMax = Config.digitalDecimalLenMax
    @objc dynamic var baseCurrencyDecimalLenMax = Config.digitalDecimalLenMax
    var priceDecimalLen = Config.digitalDecimalLenMax
    
    /// 当前委托订单&订单簿&小数位数配置.
    var depthMenuConfigOfCurrentSymbol: DepthConfigData?
    @objc dynamic var depth = Consts.kDepthDefault
    @objc dynamic var depthForMenuDisplay = Consts.kDepthMenuDefault
    
    let (orderBookLoadedSignal, orderBookLoadedObserver) = Signal<Bool, NoError>.pipe()
    let ordersCurrentTableViewCellCountSingle = 6
    var delegateOrdersData: OrdersDelegateData?
    var delegateOrdersTotalQuantityBuy: Float = 0.0
    var delegateOrdersTotalQuantitySell: Float = 0.0
    
    let (userOrdersLoadedSignal, userOrdersLoadedObserver) = Signal<Bool, NoError>.pipe()
    let (userOrdersNoMoreSignal, userOrdersNoMoreObserver) = Signal<Bool, NoError>.pipe()
    var userOrdersPage = Config.startIndexOfPage
    var userOrdersData = [UserOrdersListData]()
    
}

// MARK: - Assets.
extension TradeViewModel {
    
    func loadAssets() -> Void {
        if self.mode == TradeViewModeEnum.buy.rawValue {
            UserInfoManager.shared().asset(forCurrency: self.baseCurrency) { [weak self] (assetData) in
                self?.availableAsset = assetData?.balance ?? "--"
            }
        } else {
            UserInfoManager.shared().asset(forCurrency: self.currency) { [weak self] (assetData) in
                self?.availableAsset = assetData?.balance ?? "--"
            }
        }
    }
    
    /// 挂单.
    ///
    /// - Parameter password: the password of wallet.
    /// - Returns: promise.
    func createOrderSignal(withPassword password: String) -> Signal<Bool, NoError> {
        let (signal, observer) = Signal<Bool, NoError>.pipe()
        
        // 1、创建订单.
        let params = [
            "address":AELFIdentity.wallet_eth?.address ?? "",
            "symbol":self.symbol,
            "action":self.mode,
            "orderType":self.orderType == TradeOrderTypeEnum.limit.rawValue ? "LMT" : "MKT",
            "priceLimit":self.digitalPrice,
            "quantity":self.digitalQuantity,
            "amount":self.digitalQuantity
        ]
        Network.post(
            withUrl: URLs.shared().genUrl(with: .createOrder),
            params: params,
            to: CreateOrderResponse.self
        ) { (succeed, response) in
            guard succeed == true, response.succeed == true else {
                InfoToast(withLocalizedTitle: response.msg)
                observer.send(value: false)
                observer.sendCompleted()
                return
            }
            
            guard let txData = response.data?.createOrderTxResp, let rawTx = txData.rawTransaction else {
                InfoToast(withLocalizedTitle: "OrderTx信息错误)")
                observer.send(value: false)
                observer.sendCompleted()
                return
            }
            
            guard let orderData = response.data?.order,
                let orderId = orderData.orderNo,
                let chain = orderData.counterChain else {
                    InfoToast(withLocalizedTitle: "订单信息错误")
                    observer.send(value: false)
                    observer.sendCompleted()
                    return
            }
            
            // 2、签名tx.
            do {
                try AELFWalletManager.signETH(for: rawTx, password: password, completion: { (signature) in
                    
                    guard signature.count > 0 else {
                        InfoToast(withLocalizedTitle: "签名失败")
                        observer.send(value: false)
                        observer.sendCompleted()
                        return
                    }
                    
                    // 3、Gateway发送交易上链.
                    let gParams = [
                        "orderId":orderId,
                        "signedRawTransaction":signature,
                    ]
                    Network.post(
                        withUrl: URLs.shared().genGatewayUrl(with: .gatewaySendBuyTx),
                        params: gParams,
                        withoutDataField: true,
                        header: ["chain":chain],
                        to: SendOrderTxResponse.self
                    ) { (gSucceed, gResponse) in
                        guard gSucceed == true, gResponse.succeed == true, let txHash = gResponse.data?.txHash else {
                            InfoToast(withLocalizedTitle: "发送交易失败:\(gResponse.msg ?? "")")
                            observer.send(value: false)
                            observer.sendCompleted()
                            return
                        }
                        
                        // 4、回调Rest服务器.
                        let cbParams = [
                            "orderNo":orderId,
                            "txHash":txHash
                        ]
                        Network.post(
                            withUrl: URLs.shared().genUrl(with: .createOrderCallback),
                            params: cbParams,
                            withoutDataField: true,
                            to: BaseAPIBusinessModel.self
                        ) { (_, _) in
                            observer.send(value: true)
                            observer.sendCompleted()
                        }
                    }
                    
                })
            } catch {
                AELFIdentity.errorToast(withError: error)
            }
        }
        return signal
    }
    
    /// 撤单.
    ///
    /// - Parameter password: the password of wallet.
    /// - Parameter orderNo: order no.
    /// - Parameter chain: chain name.
    /// - Returns: promise.
    func cancelOrderSignal(withPassword password: String, orderNo: String, chain: String) -> Signal<Bool, NoError> {
        let (signal, observer) = Signal<Bool, NoError>.pipe()
        
        // 1、创建撤单.
        let params = [
            "orderNo":orderNo,
        ]
        Network.post(
            withUrl: URLs.shared().genUrl(with: .cancelOrder),
            params: params,
            to: CancelOrderResponse.self
        ) { (succeed, response) in
            guard succeed == true, response.succeed == true else {
                InfoToast(withLocalizedTitle: response.msg)
                observer.send(value: false)
                observer.sendCompleted()
                return
            }
            
            guard let txData = response.data?.createStackingTxResp, let rawTx = txData.rawTransaction else {
                InfoToast(withLocalizedTitle: "OrderTx信息错误")
                observer.send(value: false)
                observer.sendCompleted()
                return
            }
            
            guard let orderData = response.data?.orderCancelMessage,
                let orderId = orderData.orderNo,
                chain.count > 0 else {
                    InfoToast(withLocalizedTitle: "订单信息错误")
                    observer.send(value: false)
                    observer.sendCompleted()
                    return
            }
            
            // 2、签名tx.
            do {
                try AELFWalletManager.signETH(for: rawTx, password: password, completion: { (signature) in
                    
                    guard signature.count > 0 else {
                        InfoToast(withLocalizedTitle: "签名失败")
                        observer.send(value: false)
                        observer.sendCompleted()
                        return
                    }
                    
                    // 3、Gateway发送交易上链.
                    let gParams = [
                        "orderId":orderId,
                        "signedRawTransaction":signature,
                    ]
                    Network.post(
                        withUrl: URLs.shared().genGatewayUrl(with: .gatewaySendCancelTx),
                        params: gParams,
                        withoutDataField: true,
                        header: ["chain":chain],
                        to: SendOrderTxResponse.self
                    ) { (gSucceed, gResponse) in
                        guard gSucceed == true, gResponse.succeed == true, let txHash = gResponse.data?.txHash else {
                            InfoToast(withLocalizedTitle: "发送交易失败:\(gResponse.msg ?? "")")
                            observer.send(value: false)
                            observer.sendCompleted()
                            return
                        }
                        
                        // 4、回调Rest服务器.
                        let cbParams = [
                            "orderNo":orderId,
                            "txId":txHash
                        ]
                        Network.post(
                            withUrl: URLs.shared().genUrl(with: .cancelOrderCallback),
                            params: cbParams,
                            withoutDataField: true,
                            to: BaseAPIBusinessModel.self
                        ) { (_, _) in
                            observer.send(value: true)
                            observer.sendCompleted()
                        }
                    }
                    
                })
            } catch {
                AELFIdentity.errorToast(withError: error)
            }
        }
        return signal
    }
    
}

// MARK: - Dynamic Data.
extension TradeViewModel {
    
    func loadBestPrice() -> Void {
        let params = [
            "symbol":self.symbol,
            "action":self.mode
        ]
        Network.post( withUrl: URLs.shared().genUrl(with: .bestPricee), params: params, withoutDataField: true, to: BestPriceResponse.self) { [weak self] (succeed, response) in
            TopController().stopLoadingHUD()
            guard succeed == true, response.succeed == true, let data = response.data else { return }
            self?.bestPrice2BuyOrSell = data.bestPrice
        }
    }
    
}

// MARK: - Orders.
extension TradeViewModel {
    
    func gotDelegateOrder(with response: OrdersDelegateResponse, succeed: Bool) -> Void {
        guard succeed == true, response.succeed == true, let data = response.data else {
            InfoToast(withLocalizedTitle: response.msg)
            self.orderBookLoadedObserver.send(value: true)
            return
        }
        
        DispatchQueue.main.async {
            if  let askList = data.askList,
                let bidList = data.bidList {
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
            }
            
            // Reverse the Sell Orders.
            if let askList = data.askList {
                data.askList = askList.reversed()
                if let retList = data.askList, self.ordersDelegateMode == TradeViewOrderCurrentModeEnum.normal.rawValue {
                    if retList.count > self.ordersCurrentTableViewCellCountSingle {
                        let reduceLen = retList.count - self.ordersCurrentTableViewCellCountSingle
                        data.askList = Array(retList[reduceLen ..< retList.endIndex]) // Sort with max row.
                    }
                    else if retList.count < self.ordersCurrentTableViewCellCountSingle {
                        var tmpList = retList
                        for _ in 0 ..< self.ordersCurrentTableViewCellCountSingle-retList.count {
                            let item = OrdersDelegateOrderItem()
                            item.isEmptyCell = true
                            tmpList.insert(item, at: 0)
                        }
                        data.askList = tmpList
                    }
                }
            }
            
            self.delegateOrdersData = data
            self.orderBookLoadedObserver.send(value: true)
        }
    }
    
    func loadUserOrders(withFirstPage: Bool = false) {
        if withFirstPage {
            self.userOrdersPage = Config.startIndexOfPage
        }
        MarketManager.shared().userOrders(withType: UserOrderTypeEnum(rawValue: self.userOrdersType)!, page: self.userOrdersPage, useCache: false) { [weak self] (data, _) in
            if self?.userOrdersPage == Config.startIndexOfPage {
                self?.userOrdersData.removeAll()
            }
            if let data = data {
                self?.userOrdersData.append(contentsOf: data)
            }
            self?.userOrdersLoadedObserver.send(value: true)
            if data?.count ?? 0 < Config.generalListCountOfSinglePage {
                self?.userOrdersNoMoreObserver.send(value: true)
            }
        }
    }
    
    func resetUserOrders() {
        self.userOrdersData.removeAll()
        self.userOrdersLoadedObserver.send(value: true)
    }
    
}

// MARK: - Config.
extension TradeViewModel {
    
    func loadDepthConfig() -> Void {
        MarketManager.shared().depthConfig(of: self.symbol) { [weak self] (depthConfig) in
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
            self?.priceDecimalLen = Int(symbolConfig.priceScale ?? "\(Config.digitalDecimalLenMax)") ?? Config.digitalDecimalLenMax
        }
    }
    
}
