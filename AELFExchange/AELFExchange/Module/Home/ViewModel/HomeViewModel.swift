//
//  HomeViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/8.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

enum HomeSymbolRankListCellType {
    case price
    case quantity
}

@objc class HomeViewModel: NSObject {
    
    var symbolRankListOrderType = HomeSymbolRankListCellType.price
    
    @objc dynamic var bannerItems = NSMutableArray()
    var bannerUrls = [String]()
    @objc dynamic var noticeItems = NSMutableArray()
    var noticeTitles = [String]()
    
    let (bannerUpdatedSignal, bannerUpdatedObs) = Signal<Bool, NoError>.pipe()
    let (trendingSymbolUpdatedSignal, trendingSymbolUpdatedObs) = Signal<Bool, NoError>.pipe()
    @objc dynamic var trendingSymbolItems = NSMutableArray()
    @objc dynamic var marketItems = NSMutableArray()
    var marketItemsOriginal = [SymbolsItem]()
    
    @objc dynamic var financialItems = NSMutableArray()
    
    func loadData() -> Void {
//        // Banner and Notice.
//        Network.post(withUrl: URLs.shared().genUrl(with: .homeInfo), to: BannerAndNoticeResponse.self, useCache: true, cacheCallback: { (succeed, response) in
//            self.gotNoticeAndBanner(withData: response, succeed: succeed)
//        }) { (succeed, response) in
//            self.gotNoticeAndBanner(withData: response, succeed: succeed)
//        }
        
//        // Trending Symbols.
//        Network.post(withUrl: URLs.shared().genUrl(with: .symbolTrending), to: SymbolsTrendingResponse.self) { [weak self] (succeed, response) in
//            guard succeed == true, response.succeed == true, let list = response.data?.recommendSymbolList else {
//                return
//            }
//            self?.gotTrendingSymbols(list)
//        }

        // Symbols for Market.
        if self.marketItems.count == 0 {
            Network.post(withUrl: URLs.shared().genUrl(with: .allMarketSymbols), to: SymbolResponse.self) { [weak self] (succeed, response) in
                guard succeed == true, response.succeed == true, let list = response.data else {
                    return
                }
                self?.gotMarketSymbols(list)
            }
        }
        
//        // Financial List.
//        Network.post(withUrl: URLs.shared().genUrl(with: .financialList), to: FinancialListResponse.self) { [weak self] (succeed, response) in
//            guard succeed == true, response.succeed == true, let data = response.data else {
//                return
//            }
//            self?.mutableArrayValue(forKey: "financialItems").removeAllObjects()
//            self?.mutableArrayValue(forKey: "financialItems").addObjects(from: data)
//        }
    }
    
    private func gotNoticeAndBanner(withData response: BannerAndNoticeResponse, succeed: Bool) -> Void {
        guard succeed == true, response.succeed == true else {
            return
        }
        
        if response.data?.bannerList?.count ?? 0 > 0 {
            self.bannerItems.removeAllObjects()
            self.bannerUrls.removeAll()
            for item in (response.data?.bannerList)! {
                if let url = item.imageUrl {
                    self.bannerUrls.append(url)
                }
            }
            self.mutableArrayValue(forKey: "bannerItems").addObjects(from: (response.data?.bannerList)!)
        } else {
            self.bannerItems.removeAllObjects()
            self.bannerUrls.removeAll()
            self.bannerUpdatedObs.send(value: true)
        }
        
        if response.data?.announcementList?.count ?? 0 > 0 {
            self.noticeItems.removeAllObjects()
            self.noticeTitles.removeAll()
            for item in (response.data?.announcementList)! {
                if let title = item.title {
                    self.noticeTitles.append(title)
                }
            }
            self.mutableArrayValue(forKey: "noticeItems").addObjects(from: (response.data?.announcementList)!)
        }
    }
    
    func gotTrendingSymbols(_ list: [SymbolsTrendingItem]) {
        self.trendingSymbolItems.removeAllObjects()
        var data = [SymbolsTrendingItem]()
        for case let item in list where item.isShow == true || Config.shared().showMarket == true {
            data.append(item)
        }
        self.mutableArrayValue(forKey: "trendingSymbolItems").addObjects(from: data)
        self.trendingSymbolUpdatedObs.send(value: true)
    }
    
    func gotMarketSymbols(_ list: [SymbolsItem]) {
        self.marketItems.removeAllObjects()
        self.marketItemsOriginal = list
        var data = [SymbolsItem]()
        for case let item in list where item.isShow == true || Config.shared().showMarket == true {
            data.append(item)
        }
        
        data.sort { (a, b) -> Bool in
            if self.symbolRankListOrderType == .price {
                var av = NSDecimalNumber(string: a.wavePercent)
                if a.theDirection == .down { av = av.multiplying(by: -1.0, withBehavior: kDecimalConfig) }
                var bv = NSDecimalNumber(string: b.wavePercent)
                if b.theDirection == .down { bv = bv.multiplying(by: -1.0, withBehavior: kDecimalConfig) }
                if av.compare(bv) == ComparisonResult.orderedSame {
                    return (a.symbol?.compare(b.symbol ?? "")) == .orderedAscending
                }
                return (av.compare(bv) == ComparisonResult.orderedDescending)
            }
            
            let av = NSDecimalNumber(string: a.quantity)
            let bv = NSDecimalNumber(string: b.quantity)
            if av.compare(bv) == ComparisonResult.orderedSame {
                return (a.symbol?.compare(b.symbol ?? "")) == .orderedAscending
            }
            return (av.compare(bv) == ComparisonResult.orderedDescending)
        }
        
        self.mutableArrayValue(forKey: "marketItems").addObjects(from: data)
        DB.shared().sync2db4exchangeSymbols(with: list, for: .market)
    }
    
}
