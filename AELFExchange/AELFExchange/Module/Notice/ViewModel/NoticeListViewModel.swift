//
//  NoticeListViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

@objc class NoticeListViewModel: NSObject {
    
    @objc dynamic var noticeItems = NSMutableArray()
    
    @objc dynamic var page = Config.startIndexOfPage
    
    let (didLoadSignal, didLoadObserver) = Signal<Bool, NoError>.pipe()
    let (nomoreDataSignal, nomoreDataObserver) = Signal<Bool, NoError>.pipe()
    
    func load() -> Void {
        let params = [
            "pageRows":Config.generalListCountOfSinglePage,
            "currPage":self.page
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .noticeList), params: params, to: NoticeListResponse.self, useCache: true, cacheCallback: { [weak self] (succeed, response) in
            self?.gotData(response, succeed: succeed)
        }) {  [weak self] (succeed, response) in
            self?.didLoadObserver.send(value: true)
            self?.gotData(response, succeed: succeed)
        }
    }
    
    private func gotData(_ response: NoticeListResponse, succeed: Bool) -> Void {
        guard succeed == true, response.succeed == true, let list = response.data?.list else {
            return
        }
        if list.count > 0 {
            if self.page == Config.startIndexOfPage {
                self.noticeItems.removeAllObjects()
            }
            self.mutableArrayValue(forKey: "noticeItems").addObjects(from: list)
        }
        if list.count < Config.generalListCountOfSinglePage {
            self.nomoreDataObserver.send(value: true)
        }
    }
    
}
