//
//  AreaSelectorViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

@objc class AreaSelectorViewModel: NSObject {
    
    fileprivate static let ___donotUseThisVariableOfAreaSelectorViewModel = AreaSelectorViewModel()
    
    @discardableResult
    static func shared() -> AreaSelectorViewModel {
        return AreaSelectorViewModel.___donotUseThisVariableOfAreaSelectorViewModel
    }
    
    var countyList = [AreaSelectorModelData]()
    var displayCountryList = [[String:[AreaSelectorModelData]]]()
    var displayCountryIndexList = [String]()
    
    override init() {
        super.init()
        LanguageManager.shared().languageDidChangedSignal.observeValues { [unowned self] (_) in
            self.getCountyList(withCompletion: { (_) in }, useCache: false)
        }
    }
    
    func getCountyList(withCompletion callback: @escaping (([AreaSelectorModelData]) -> ()), useCache: Bool = true) -> Void {
        if useCache {
            guard self.countyList.count == 0 else {
                callback(self.countyList)
                return
            }
        }
        
        Network.post(withUrl: URLs.shared().genUrl(with: .countyList), to: AreaSelectorModel.self) { [weak self] (succeed, response) in
            guard succeed == true, response.succeed == true, let list = response.data, list.count > 0 else {
                callback([AreaSelectorModelData]())
                return
            }
            self?.countyList.removeAll()
            self?.countyList.append(contentsOf: list)
            if let list = self?.countyList {
                callback(list)
            }
        }
    }
    
    /// For Displaying on screen.
    func getDisplayList(withCompletion callback: @escaping (([[String:[AreaSelectorModelData]]]) -> ())) -> Void {
        /*
        guard self.countyList.count == 0 else {
            callback(self.assambleDisplayList(withOrigData: self.countyList))
            return
        }*/
        self.getCountyList(withCompletion: { (list) in
            callback(self.assambleDisplayList(withOrigData: list))
        }, useCache: false)
    }
    
    private func assambleDisplayList(withOrigData data: [AreaSelectorModelData]) -> [[String:[AreaSelectorModelData]]] {
        var datas = [String:[AreaSelectorModelData]]()
        for item in data {
            if let name = item.name {
                let firstChar = name.pinyinFirstChar()
                if var arr = datas[firstChar] {
                    arr.append(item)
                    arr = arr.sorted { (b, c) -> Bool in return b.name?.compare(c.name ?? "") == .orderedAscending }
                    datas[firstChar] = arr
                } else {
                    datas[firstChar] = [item]
                    self.displayCountryIndexList.append(firstChar)
                }
            }
        }
        
        // Sort.
        self.displayCountryList.removeAll()
        for item in datas {
            self.displayCountryList.append([item.key : item.value])
        }
        self.displayCountryList.sort() { $0.keys.first! < $1.keys.first! }
        self.displayCountryIndexList.sort() { $0 < $1 }
        return self.displayCountryList
    }
    
}

// MARK: - Util.
extension AreaSelectorViewModel {
    
    func getName(withAreaCode code: String, callback: @escaping ((String) -> ())) -> Void {
        self.getCountyList(withCompletion: { (data) in
            for case let item in data where item.mobileArea == code {
                callback(item.name ?? "")
            }
        })
    }
    
    func getCounty(withAreaCode code: String, callback: @escaping ((String) -> ())) -> Void {
        self.getCountyList(withCompletion: { (data) in
            for case let item in data where item.mobileArea == code {
                callback(item.countryId ?? "")
            }
        })
    }
    
}
