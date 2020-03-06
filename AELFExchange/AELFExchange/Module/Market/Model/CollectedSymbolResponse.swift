//
//  CollectedSymbolResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class CollectedSymbolData: HandyJSON {
    
    var symbolList: [String]?
    
    required init() {}
    
}

class CollectedSymbolResponse: BaseAPIBusinessModel {
    
    var data: CollectedSymbolData?
    
}
