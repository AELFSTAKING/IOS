//
//  SearchHistoryEntity.swift
//  AELFExchange
//
//  Created by tng on 2019/5/17.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import RealmSwift

class SearchHistoryEntity: Object {
    
    @objc dynamic var keywords: String?
    
    override static func primaryKey() -> String? {
        return "keywords"
    }
    
}
