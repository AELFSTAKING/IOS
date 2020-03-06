//
//  CollectedExchangeSymbolEntity.swift
//  AELFExchange
//
//  Created by tng on 2019/1/28.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import RealmSwift

class CollectedExchangeSymbolEntity: Object {
    
    /// 0: Collection, 1:Market.
    @objc dynamic var type: String?
    
    @objc dynamic var symbol: String?
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
    
}
