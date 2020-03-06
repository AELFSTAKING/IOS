//
//  FileUploadModel.swift
//  AELF
//
//  Created by tng on 2018/10/19.
//  Copyright © 2018 AELF. All rights reserved.
//

import Foundation
import HandyJSON

class FileUploadModelData: HandyJSON {
    
    /// .
    var path: String?
    
    required init() {}
    
}

class FileUploadModel: BaseAPIBusinessModel {
    
    var data: FileUploadModelData?
    
}
