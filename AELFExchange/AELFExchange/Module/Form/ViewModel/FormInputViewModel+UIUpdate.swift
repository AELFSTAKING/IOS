//
//  FormInputViewModel+UIUpdate.swift
//  AELFExchange
//
//  Created by tng on 2019/8/16.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

extension FormInputViewModel {

    func fillContentForScan(with data: FormInputViewItem, result: String) {
        for case let item in self.forms where item.requestParamKey == data.requestParamKey {
            item.defaultValue = result
            self.loadedObserver.send(value: true)
            break
        }
    }

}
