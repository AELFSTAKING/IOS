//
//  DepthConfigEntity.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import RealmSwift

class DepthConfigEntity: Object {
    
    /// = "\(symbol)+\(depth)"
    @objc dynamic var prtKey: String?
    
    @objc dynamic var symbol: String?
    
    @objc dynamic var depth: String?
    
    override static func primaryKey() -> String? {
        return "prtKey"
    }
    
}
