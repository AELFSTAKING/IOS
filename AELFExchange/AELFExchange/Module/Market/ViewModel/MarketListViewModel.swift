//
//  MarketListViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/5/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

enum MarketListMode {
    case fullDisplay
    case selector
}

enum MarketTypeEnum: Int {
    case collection = 0
    case market = 1
    case symbolSelect = 2
}

enum MarktSortTypeEnum: Int {
    case volumeAsc
    case volumeDesc
    case priceAsc
    case priceDesc
    case directionAsc
    case directionDesc
    case none
}

@objc class MarketListViewModel: NSObject {
    
    var mode = MarketListMode.fullDisplay
    
    let (loadedSignal, loadedOberver) = Signal<Bool, NoError>.pipe()
    let (firstTimeLoadedSignal, firstTimeLoadedOberver) = Signal<Bool, NoError>.pipe()
    let (handleAreasSignal, handleAreasOberver) = Signal<[String], NoError>.pipe()
    var areas = [String]()
    @objc dynamic var menus = NSMutableArray()
    @objc dynamic var data = NSMutableArray()
    private var defaultTitles: [String] { return [LOCSTR(withKey: "自选"), LOCSTR(withKey: "全部")] }
    private var firstTimeLoaded = true
    
    var tradeAreaIndex = 1
    private var areaWholeData = [MarketSymbolGroupedAreaDataBO]()
    
    func load(withCurrentAreaIndex areaIndex: Int, completion: (() -> ())? = nil) {
        if self.mode == .selector {
            if let callback = completion {
                self.loadAllData {
                    callback()
                }
            } else {
                self.loadAllData()
            }
        } else {
            Network.post(withUrl: URLs.shared().genUrl(with: .marketGroupedList), params: nil, to: MarketSymbolGroupedAreaResponse.self, useCache: false) { [weak self] (succeed, response) in
                if let callback = completion {
                    self?.preAssembleForGroupedMarketData(withCurrentAreaIndex: areaIndex, succeed: succeed, response: response, completion: {
                        callback()
                    })
                } else {
                    self?.preAssembleForGroupedMarketData(withCurrentAreaIndex: areaIndex, succeed: succeed, response: response, completion: nil)
                }
            }
        }
    }
    
    func preAssembleForGroupedMarketData(withCurrentAreaIndex areaIndex: Int, succeed: Bool, response: MarketSymbolGroupedAreaResponse, completion: (() -> ())? = nil) {
        guard succeed == true, response.succeed == true, let data = response.data, data.count > 0 else {
            return
        }
        
        self.areas.removeAll()
        self.areaWholeData.removeAll()
        self.areas.append(contentsOf: defaultTitles)
        self.areaWholeData.append(contentsOf: data)
        
        for index in 0..<data.count {
            let item = data[index]
            if let area = (LanguageManager.shared().currentLanguage() == .ZH_HANS ? item.areaName:(item.areaEnName ?? "unknown")) {
                self.areas.append(area)
            }
            if index == areaIndex-defaultTitles.count, let listData = item.list {
                if let callback = completion {
                    self.preAssembleSymbolForMarket(listData, completion: ({
                        callback()
                    }))
                } else {
                    self.preAssembleSymbolForMarket(listData)
                }
            }
        }
        self.handleAreasOberver.send(value: self.areas)
    }
    
    private func loadAllData(_ completion: (() -> ())? = nil) {
        Network.post(withUrl: URLs.shared().genUrl(with: .markeyGroup), params: nil, to: MarketSymbolGroupedResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else { return }
            if let callback = completion {
                self?.preAssembleSymbolForMarket(data, completion: ({
                    callback()
                }))
            } else {
                self?.preAssembleSymbolForMarket(data)
            }
        }) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else { return }
            if let callback = completion {
                self?.preAssembleSymbolForMarket(data, completion: ({
                    callback()
                }))
            } else {
                self?.preAssembleSymbolForMarket(data)
            }
        }
    }
    
    private func preAssembleSymbolForMarket(_ data: [MarketSymbolGroupedDataBO], completion: (() -> ())? = nil) {
        if let callback = completion {
            self.assembleSymbolForMarket(data, completion: ({
                callback()
            }))
        } else {
            self.assembleSymbolForMarket(data)
        }
    }
    
    private func assembleSymbolForMarket(_ list: [MarketSymbolGroupedDataBO], completion: (() -> ())? = nil) {
        self.menus.removeAllObjects()
        self.data.removeAllObjects()
        
        var menuData = [String]()
        var data = [MarketSymbolGroupedDataBO]()
        if self.mode == .selector {
            menuData.append(LOCSTR(withKey: "自选"))
            data.append(MarketSymbolGroupedDataBO())
        }
        
        for group in list {
            let newList = group.list?.filter({ (item) -> Bool in
                return item.isShow == true || Config.shared().showMarket == true
            })
            
            guard newList?.count ?? 0 > 0 else {
                continue
            }
            
            guard let title = group.group else { return }
            menuData.append(title)
            
            let gd = MarketSymbolGroupedDataBO()
            gd.group = title
            gd.list = newList
            data.append(gd)
            DB.shared().sync2db4exchangeSymbols(with: newList!, for: .market)
        }
        
        self.menus.addObjects(from: menuData)
        self.data.addObjects(from: data)
        if let callback = completion {
            callback()
        } else {
            self.loadedOberver.send(value: true)
        }
        self.sendFirstLoadedSignalIfNeeded()
    }
    
    func loadCollectionData(_ forAreaChanged: Bool? = nil, _ completion: ((Bool) -> ())?) {
        Network.post(withUrl: URLs.shared().genUrl(with: .collectedSymbols), to: CollectedSymbolResponse.self, useCache: false, cacheCallback: { (_, _) in
            /*
            if let callback = completion {
                self?.preAssembleCollectionData(succeed: succeed, response: response, forAreaChanged: forAreaChanged, completion: { (ret) in callback(ret) })
            } else {
                self?.preAssembleCollectionData(succeed: succeed, response: response, forAreaChanged: forAreaChanged, completion: nil)
            }*/
        }){ [weak self] (succeed, response) in
            if let callback = completion {
                self?.preAssembleCollectionData(succeed: succeed, response: response, forAreaChanged: forAreaChanged, completion: { (ret) in callback(ret) })
            } else {
                self?.preAssembleCollectionData(succeed: succeed, response: response, forAreaChanged: forAreaChanged, completion: nil)
            }
        }
    }
    
    private func preAssembleCollectionData(succeed: Bool, response: CollectedSymbolResponse, forAreaChanged: Bool? = nil, completion: ((Bool) -> ())?) {
        guard succeed == true, response.succeed == true, let symbols = response.data?.symbolList else {
            if let callback = completion {
                callback(false)
            } else {
                self.data.removeAllObjects()
                self.loadedOberver.send(value: true)
                self.sendFirstLoadedSignalIfNeeded()
            }
            return
        }
        
        Network.post(withUrl: URLs.shared().genUrl(with: .allMarketSymbols), to: SymbolResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            if let callback = completion {
                self?.assembleCollectionData(symbols: symbols, succeed: succeed, response: response, forAreaChanged: forAreaChanged, completion: { (ret) in callback(ret) })
            } else {
                self?.assembleCollectionData(symbols: symbols, succeed: succeed, response: response, forAreaChanged: forAreaChanged, completion: nil)
            }
            }, completionCallback: { [weak self] (succeed, response) in
                if let callback = completion {
                    self?.assembleCollectionData(symbols: symbols, succeed: succeed, response: response, forAreaChanged: forAreaChanged, completion: { (ret) in callback(ret) })
                } else {
                    self?.assembleCollectionData(symbols: symbols, succeed: succeed, response: response, forAreaChanged: forAreaChanged, completion: nil)
                }
        })
        DB.shared().sync2db4collectedExchangeSymbols(with: symbols, for: .collection)
    }
    
    private func assembleCollectionData(symbols: [String], succeed: Bool, response: SymbolResponse, forAreaChanged: Bool? = nil, completion: ((Bool) -> ())?) {
        guard succeed == true, response.succeed == true, let allSymbolList = response.data else {
            if let callback = completion { callback(false) }
            return
        }
        
        let availableSymbols = allSymbolList.filter({ (item) -> Bool in return item.isShow == true || Config.shared().showMarket == true })
        var tmpArr = [SymbolsItem]()
        for symbol in availableSymbols {
            guard symbol.isShow == true || Config.shared().showMarket == true else { continue}
            guard let s = symbol.symbol, symbols.contains(s) else { continue }
            let item = SymbolsItem()
            item.symbol = symbol.symbol
            item.highestPrice = symbol.highestPrice
            item.highestUsdPrice = symbol.highestUsdPrice
            item.lowestPrice = symbol.lowestPrice
            item.lowestUsdPrice = symbol.lowestUsdPrice
            item.price = symbol.price
            item.lastPrice = symbol.lastPrice
            item.usdPrice = symbol.usdPrice
            item.lastUsdPrice = symbol.lastUsdPrice
            item.quantity = symbol.quantity
            item.wavePrice = symbol.wavePrice
            item.wavePercent = symbol.wavePercent
            item.direction = symbol.direction ?? 0
            tmpArr.append(item)
        }
        
        self.data.removeAllObjects()
        let gd = MarketSymbolGroupedDataBO()
        gd.group = LOCSTR(withKey: "自选")
        gd.list = tmpArr
        self.data.add(gd)
        if forAreaChanged == true {
            self.loadedOberver.send(value: true)
        } else {
            if let callback = completion { callback(true) }
        }
        self.sendFirstLoadedSignalIfNeeded()
    }
    
    private func sendFirstLoadedSignalIfNeeded() {
        if self.firstTimeLoaded {
            self.firstTimeLoaded.toggle()
            self.firstTimeLoadedOberver.send(value: true)
        }
    }
    
}

// MARK: - MQTT.
extension MarketListViewModel {
    
    func handleGroupPushData(_ mqttData: [MQTTGroupedMarketDataBO]) {
        guard self.mode == .fullDisplay else { return }
        if self.tradeAreaIndex == 0 {
            // Collection.
            if let collections = self.data.firstObject as? MarketSymbolGroupedDataBO, let list = collections.list {
                for collectionedSymbol in list {
                    for group in mqttData {
                        if let groupSymbolList = group.list {
                            for case let newSymbol in groupSymbolList where newSymbol.symbol == collectionedSymbol.symbol {
                                collectionedSymbol.lastPrice = newSymbol.lastPrice
                                collectionedSymbol.lastUsdPrice = newSymbol.lastUsdPrice
                                collectionedSymbol.quantity = newSymbol.quantity
                                collectionedSymbol.wavePrice = newSymbol.wavePrice
                                collectionedSymbol.wavePercent = newSymbol.wavePercent
                                collectionedSymbol.direction = newSymbol.direction
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.loadedOberver.send(value: true)
            }
        } else if self.tradeAreaIndex == 1 {
            // All.
            var groupList = [MarketSymbolGroupedDataBO]()
            for item in mqttData {
                if groupList.contains(where: { (bo) -> Bool in
                    return bo.group == item.group
                }) {
                    for case let containedGroup in groupList where containedGroup.group == item.group {
                        if var containedGroupList = containedGroup.list {
                            if let newList = item.list {
                                for newItem in newList {
                                    if !containedGroupList.contains(where: { (bo) -> Bool in
                                        return bo.symbol == newItem.symbol
                                    }) {
                                        containedGroupList.append(newItem)
                                    }
                                }
                            }
                        } else {
                            containedGroup.list = item.list
                        }
                        break
                    }
                } else {
                    let newGroup = MarketSymbolGroupedDataBO()
                    newGroup.group = item.group
                    newGroup.list = item.list
                    groupList.append(newGroup)
                }
            }
            DispatchQueue.main.async {
                self.preAssembleSymbolForMarket(groupList)
            }
        } else if self.tradeAreaIndex > 1 {
            /* 组装成MarketSymbolGroupedAreaResponse格式，暂时用不到，单独走:func handleAreaPushData.
            // ...
            var areaList = [MarketSymbolGroupedAreaDataBO]()
            for item in mqttData {
                if areaList.contains(where: { (bo) -> Bool in
                    return bo.areaNo == item.areaNo
                }) {
                    for case let containedArea in areaList where containedArea.areaNo == item.areaNo {
                        let newGroup = MarketSymbolGroupedDataBO()
                        newGroup.group = item.group
                        newGroup.list = item.list
                        if var containedGroup = containedArea.list {
                            containedGroup.append(newGroup)
                        } else {
                            containedArea.list = [newGroup]
                        }
                        break
                    }
                } else {
                    let newGroup = MarketSymbolGroupedDataBO()
                    newGroup.group = item.group
                    newGroup.list = item.list
                    let newArea = MarketSymbolGroupedAreaDataBO()
                    newArea.areaName = item.areaName
                    newArea.areaNo = item.areaNo
                    newArea.list = [newGroup]
                    areaList.append(newArea)
                }
            }

            /*
            var area = MarketSymbolGroupedAreaResponse()
            area.data = areaList*/

            for newArea in areaList {
                for localArea in self.areaWholeData {
                    if localArea.areaNo == newArea.areaNo {
                        localArea.list = newArea.list
                    }
                }
            }*/
        }
    }
    
    func handleAreaPushData(_ mqttData: MarketSymbolGroupedAreaResponse) {
        guard self.mode == .fullDisplay else { return }
        // General Areas.
        DispatchQueue.main.async {
            self.preAssembleForGroupedMarketData(withCurrentAreaIndex: self.tradeAreaIndex, succeed: true, response: mqttData, completion: nil)
        }
    }
    
}

// MARK: - Outter API.
extension MarketListViewModel {
    
    func checkoutForTradeArea(to index: Int) {
        self.tradeAreaIndex = index
        if index < self.defaultTitles.count {
            if index == 0 {
                // Collection.
                self.loadCollectionData(true, nil)
            } else {
                // All.
                self.loadAllData()
            }
        } else {
            // Areas.
            guard self.mode == .fullDisplay, index < self.areaWholeData.count+self.defaultTitles.count else { return }
            self.menus.removeAllObjects()
            self.data.removeAllObjects()
            if let data = self.areaWholeData[index-self.defaultTitles.count].list {
                let menu = data.map { (data) -> String in
                    return data.group ?? "--"
                }
                self.menus.addObjects(from: menu)
                self.data.addObjects(from: data)
            }
            self.loadedOberver.send(value: true)
        }
    }
    
}
