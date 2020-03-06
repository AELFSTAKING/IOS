//
//  CurrencyManager.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

@objc class CurrencyManager: NSObject {
    
    fileprivate static let ___donotUseThisVariableOfCurrencyManager = CurrencyManager()
    
    @discardableResult
    static func shared() -> CurrencyManager {
        return CurrencyManager.___donotUseThisVariableOfCurrencyManager
    }
    
    override init() {
        super.init()
    }
    
    var digitalCurrency: String {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "digitalCurrency") as? String { return theInstance }
            return "USDT"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "digitalCurrency")
            UserDefaults.standard.synchronize()
        }
    }
    
    var legalCurrency: String {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "legalCurrency") as? String { return theInstance }
            return "USD"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "legalCurrency")
            UserDefaults.standard.synchronize()
        }
    }
    
    var legalCurrencySymbol: String {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "legalCurrencySymbol") as? String { return theInstance }
            return "$"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "legalCurrencySymbol")
            UserDefaults.standard.synchronize()
        }
    }
    
}

// MARK: - Currency Info.
extension CurrencyManager {
    
    func decimalLenInfoSetup() -> Void {
        MarketManager.shared().allExchangeSymbolLatest { (symbols) in
            for symbolItem in symbols {
                guard let symbol = symbolItem.symbol else { continue }
                let params = [
                    "symbol":symbol
                ]
                Network.post(withUrl: URLs.shared().genUrl(with: .decimalLen), params: params, to: SymbolDecimalLenResponse.self, completionCallback: { (succeed, response) in
                    guard succeed == true, response.succeed == true, let data = response.data else { return }
                    DB.shared().async(something: { (rm) in
                        let entity = SymbolDecimalLenEntity()
                        entity.symbol = data.symbol
                        entity.currencyDicemalLen = data.productCoinScale
                        entity.baseCurrencyDicemalLen = data.currencyCoinScale
                        entity.dealDicemalLen = data.volumeScale
                        rm.add(entity, update: true)
                    })
                })
            }
        }
    }
    
    func cachedDecimalLen(of symbol: String) -> SymbolDecimalLenEntity? {
        let cache = DB.shared().rm.objects(SymbolDecimalLenEntity.self).filter("symbol = '\(symbol)'")
        if cache.count > 0 {
            for case let item in cache where item.symbol == symbol {
                return item
            }
        }
        return nil
    }
    
    func decimalLen(of symbol: String, completion: @escaping ((SymbolDecimalLenEntity) -> ())) -> Void {
        var hasCache = false
        let cache = DB.shared().rm.objects(SymbolDecimalLenEntity.self).filter("symbol = '\(symbol)'")
        if cache.count > 0 {
            for case let item in cache where item.symbol == symbol {
                hasCache = true
                completion(item)
                break
            }
        }
        
        // Refresh from remotes.
        let params = [
            "symbol":symbol
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .decimalLen), params: params, to: SymbolDecimalLenResponse.self, completionCallback: { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else { return }
            DB.shared().async(something: { (rm) in
                let entity = SymbolDecimalLenEntity()
                entity.symbol = data.symbol
                entity.currencyDicemalLen = data.productCoinScale
                entity.baseCurrencyDicemalLen = data.currencyCoinScale
                entity.dealDicemalLen = data.volumeScale
                rm.add(entity, update: true)
            })
            if !hasCache {
                let entity = SymbolDecimalLenEntity()
                entity.symbol = data.symbol
                entity.currencyDicemalLen = data.productCoinScale
                entity.baseCurrencyDicemalLen = data.currencyCoinScale
                entity.dealDicemalLen = data.volumeScale
                completion(entity)
            }
        })
    }
    
    func info(of currencyName: String, showIndicator: Bool = true, completion callback: @escaping ((CurrencyInfoData) -> ())) -> Void {
        if showIndicator { TopController().startLoadingHUD(withMsg: Consts.kMsgLoading) }
        let params = [
            "currencyCode":currencyName
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .currencyInfo), params: params, to: CurrencyInfoResponse.self) { (succeed, response) in
            if showIndicator { TopController().stopLoadingHUD() }
            guard succeed == true, response.succeed == true, let data = response.data else {
                InfoToast(withLocalizedTitle: response.msg)
                callback(CurrencyInfoData())
                return
            }
            callback(data)
        }
    }
    
    func availableAsset(for currencyName: String, callback: @escaping ((_ availableAsset: String) -> ())) -> Void {
        let params = [
            "currency":currencyName
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .assetsOfCurrency), params: params, to: AvailableAssetResponse.self) { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                InfoToast(withLocalizedTitle: response.msg)
                callback("0.0")
                return
            }
            callback(data.availableAmount ?? "0.0")
        }
    }
    
}

// MARK: - Utils.
public let kDecimalConfig = NSDecimalNumberHandler(
    roundingMode: NSDecimalNumber.RoundingMode.bankers,
    scale: 20,
    raiseOnExactness: false,
    raiseOnOverflow: false,
    raiseOnUnderflow: false,
    raiseOnDivideByZero: false
)

extension NSNumber {
    
    func digitalString() -> String {
        let def = "0.00000000"
        guard self.doubleValue.isNaN == false else {
            return def
        }
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = Config.digitalDecimalLenMax
        formatter.minimumFractionDigits = Config.digitalDecimalLenMin
        formatter.roundingMode = .floor
        return formatter.string(from: self) ?? def
    }
    
    func legalString() -> String {
        let def = "0.00"
        guard self.doubleValue.isNaN == false else {
            return def
        }
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = Config.legalDecimalLenMax
        formatter.minimumFractionDigits = Config.legalDecimalLenMin
        formatter.roundingMode = .floor
        return formatter.string(from: self) ?? def
    }
    
    func usdtString() -> String {
        let def = "0.0000"
        guard self.doubleValue.isNaN == false else {
            return def
        }
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = Config.usdtDecimalLenMax
        formatter.minimumFractionDigits = Config.usdtDecimalLenMin
        formatter.roundingMode = .floor
        return formatter.string(from: self) ?? def
    }
    
    func string(withDecimalLen len: Int, minLen: Int = 1) -> String {
        let def = "0.0"
        guard self.doubleValue.isNaN == false else {
            return def
        }
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = len
        formatter.minimumFractionDigits = minLen
        formatter.roundingMode = .floor
        return formatter.string(from: self) ?? def
    }
    
}

extension String {
    
    func digitalString() -> String {
        return NSDecimalNumber(string: self).digitalString()
    }
    
    func legalString() -> String {
        return NSDecimalNumber(string: self).legalString()
    }
    
    func usdtString() -> String {
        return NSDecimalNumber(string: self).usdtString()
    }
    
    func string(withDecimalLen len: Int, minLen: Int = 1) -> String {
        return NSDecimalNumber(string: self).string(withDecimalLen: len, minLen: minLen)
    }
    
}
