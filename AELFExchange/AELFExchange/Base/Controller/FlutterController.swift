//
//  FlutterController.swift
//  AELFExchange
//
//  Created by tng on 2019/6/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import Flutter
import FlutterPluginRegistrant

class FlutterController: FlutterViewController {
    
    private var notificationChannel: FlutterMethodChannel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneratedPluginRegistrant.register(with: self.engine)
        notificationChannel = FlutterMethodChannel(name: "chl_notification", binaryMessenger: self)
        
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.notificationChannel.invokeMethod("backFromNative", arguments: nil)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        
    }
    
    private func signalSetup() -> Void {
        // Base.
        //
        self.setMessageHandlerOnChannel("navigation_pop") { [weak self] (_, _) in
            self?.pop()
        }
        
        let generalInfoToken = FlutterMethodChannel(name: "info_general", binaryMessenger: self)
        generalInfoToken.setMethodCallHandler { (call, result) in
            switch call.method {
            case "language":
                result(LanguageManager.shared().apiCurrentLanguage())
                break
            case "deviceId":
                result(Util.deviceID())
                break
            case "apiDomain":
                if  let args = call.arguments as? String,
                    let jsonArgs = args.json2obj() as? [String:Any],
                    let removeApis = jsonArgs["removePrefixApis"] as? Bool,
                    removeApis == true {
                    result(URLs.shared().apiDomain(withoutApis: true))
                } else {
                    result(URLs.shared().apiDomain())
                }
                break
            case "ethAddress":
                guard AELFIdentity.hasIdentity() else {
                    result("Did not initial.")
                    return
                }
                result(AELFIdentity.wallet_eth?.address ?? "")
                break
            default: break
            }
        }
        
        // Navigator.
        //
        let channelNavigation = FlutterMethodChannel(name: "navigation_push", binaryMessenger: self)
        channelNavigation.setMethodCallHandler { (call, _) in
            switch call.method {
            case "security_settings":
                // ...
                break
            default: break
            }
        }
        
        // Network.
        //
        let channelHttp = FlutterMethodChannel(name: "http_post", binaryMessenger: self)
        channelHttp.setMethodCallHandler { (call, result) in
            guard let args = call.arguments as? String,
                let jsonArgs = args.json2obj() as? [String:Any],
                let url = jsonArgs["url"] as? String else {
                    logerror(content: "FlutterController::error args: \(String(describing: call.arguments))")
                    return
            }
            
            let withoutParamDataField = jsonArgs["withoutParamDataField"] as? Bool ?? false
            if let params = jsonArgs["params"] as? [String:Any], params.count > 0 {
                Network.jsonPost(withUrl: url, params: params, withoutParamDataField: withoutParamDataField, completionCallback: { (succeed, jsonResponse) in
                    guard succeed == true else {
                        result(FlutterError(code: "-1", message: "Error", details: nil))
                        return
                    }
                    result(jsonResponse)
                })
            } else {
                Network.jsonPost(withUrl: url, withoutParamDataField: withoutParamDataField, completionCallback: { (succeed, jsonResponse) in
                    guard succeed == true else {
                        result(FlutterError(code: "-1", message: "Error", details: nil))
                        return
                    }
                    result(jsonResponse)
                })
            }
        }
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}
