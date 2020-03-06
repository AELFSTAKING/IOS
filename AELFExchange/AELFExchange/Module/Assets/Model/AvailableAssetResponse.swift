//
//  AvailableAssetResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/30.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class AvailableAssetData: HandyJSON {
    
    var availableAmount: String?
    
    required init() {}
    
}

class AvailableAssetResponse: BaseAPIBusinessModel {
    
    var data: AvailableAssetData?
    
}
