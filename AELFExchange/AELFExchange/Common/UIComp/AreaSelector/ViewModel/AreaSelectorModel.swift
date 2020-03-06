//
//  AreaSelectorModel.swift
//  AELFExchange
//
//  Created by tng on 2019/1/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class AreaSelectorModelData: HandyJSON {
    
    var code: String?
    
    var countryId: String?
    
    var mobileArea: String?
    
    var name: String?
    
    required init() {}
    
}

class AreaSelectorModel: BaseAPIBusinessModel {
    
    var data: [AreaSelectorModelData]?
    
}
