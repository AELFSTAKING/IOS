//
//  Network+Credential.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

extension Network {
    
    static func credentialValidation(with model: BaseAPIBusinessModel) -> Void {
        guard let code = model.respCode else { return }
        guard code != "100000" else {
            loginfo(content: "<< Requires to login.")
            return
        }
    }
    
}
