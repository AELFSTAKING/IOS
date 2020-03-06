//
//  WebController+JSHandler.swift
//  AELFExchange
//
//  Created by tng on 2019/3/6.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import JavaScriptCore

extension WebController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        logdebug(content: "<< Got msg of WebController js: \(message.body)")
        if message.name == "c2cNeedsLogin" {
            self.navigationController?.popToRootViewController(animated: false)
//            self.present(LoginController(), animated: true) {}
        }
    }
    
}
