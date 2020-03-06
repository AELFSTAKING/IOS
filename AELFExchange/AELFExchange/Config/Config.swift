//
//  Config.swift
//  AELF
//
//  Created by tng on 2018/9/9.
//  Copyright © 2018年 AELF. All rights reserved.
//

import UIKit
import Foundation
import IQKeyboardManagerSwift
import Bugly
import Toast_Swift
import CryptoSwift

// MARK: - Global Switch

enum Environment: String {
    case test = "Test"
    case prod = "Prod"
    case stage = "Stage"
    case unknown = "Unknown"
    
    init (string: String) {
        self = Environment(rawValue: string) ?? .unknown
    }
}

final class Config {
    
    fileprivate static let ___donotUseThisVariableOfConfig = Config()
    
    @discardableResult
    static func shared() -> Config {
        return Config.___donotUseThisVariableOfConfig
    }
    
    func setup() -> Void {
        
        // Environment.
        let info = Bundle.main.infoDictionary!
        if let env = info["Config-Environment"] as? String {
            self.environment = Environment(string: env)
        }
        
        // Network.
        Network.setup()
        
        // Keyboard Manager.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
        // Toast.
        ToastManager.shared.position = .center
        ToastManager.shared.style.backgroundColor = kThemeColorBackgroundToast
        ToastManager.shared.style.titleColor = .white
        ToastManager.shared.style.messageFont = kThemeFontNormal
        ToastManager.shared.style.messageColor = .white
        ToastManager.shared.style.titleFont = kThemeFontNormal
        FTConfiguration.shared.globalShadow = true
        FTConfiguration.shared.backgoundTintColor = UIColor(hexStr: "262D46")
        FTConfiguration.shared.menuSeparatorColor = UIColor(hexStr: "202339")
        FTConfiguration.shared.menuSeparatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 0)
        
        // Thirdparty.
        self.buglySetup()
        //self.umengSetup()
        //self.tingyunSetup()
        
        // Common.
        //CurrencyManager.shared().decimalLenInfoSetup()
        MQTTManager.shared().setup()
        
        // Other.
        AELFWalletManager.shared().kofoJsSDKWebSetup()
        KofoSDKManager.shared().setup()
        //AELFTokenManager.shared().getChannelInfoes([]) { (_) in }
        //MarketManager.shared().allGroupSymbols { (_) in }
        
    }
    
    // MARK: - General.
    /// The Environment.
    var environment = Environment.prod
    
    /// Timeout time interval of request(s).
    static let timeoutOfRequest = 120
    static let timeoutOfRequestFileUpload = 300
    static let versionCheckInterval: TimeInterval = 120
    static let timeintervalOfRertyForTCP: TimeInterval = 60
    
    static let withdrawNameLenMax = 10
    
    static let mqttClientId = "\(NSUUID().uuidString)-\(timestampms())"
    
    /// The general list start index for pages.
    static let startIndexOfPage = 1
    
    /// The count of every single videos page.
    static let generalListCountOfSinglePage = 20
    
    /// Decimal Length.
    static let digitalDecimalLenMax = 8
    static let digitalDecimalLenMin = 8
    static let legalDecimalLenMax = 2
    static let legalDecimalLenMin = 2
    static let usdtDecimalLenMax = 4
    static let usdtDecimalLenMin = 4
    
    var secPrivateKey: String? {
        get {
            var finContent = ""
            let theInstance = UserDefaults.standard.value(forKey: "s-p-k")
            do {
                if let countValue = theInstance as? String,
                    let data = Data(base64Encoded: countValue)?.bytes {
                    let aes = try AES(key: Consts.kAESKey, iv: Consts.kAESIV)
                    let ret = try aes.decrypt(data)
                    if let decrypted = String(data: Data(ret), encoding: .ascii) {
                        finContent = decrypted
                    }
                }
            } catch {
                finContent = theInstance as! String
            }
            return finContent
        }
        set {
            var finContent = ""
            do {
                let aes = try AES(key: Consts.kAESKey, iv: Consts.kAESIV)
                if let content = newValue {
                    let ret = try aes.encrypt(Array(content.utf8))
                    if let encrypted = ret.toBase64() {
                        finContent = encrypted
                    }
                }
            }
            catch {
                finContent = newValue ?? ""
            }
            UserDefaults.standard.setValue(finContent, forKey: "s-p-k")
            UserDefaults.standard.synchronize()
        }
    }
    
    var userNo: String? {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "userNo") as? String { return theInstance }
            return ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userNo")
            UserDefaults.standard.synchronize()
        }
    }
    
    var channelInfoes: [ThirdChannelInfoData]? {
        get {
            if  let json = UserDefaults.standard.value(forKey: "ci-list") as? String ,
                let values = [ThirdChannelInfoData].deserialize(from: json) {
                var list = [ThirdChannelInfoData]()
                for item in values {
                    if let item = item {
                        list.append(item)
                    }
                }
                return list
            }
            return []
        }
        set {
            if let value = newValue, let json = value.toJSONString() {
                UserDefaults.standard.setValue(json, forKey: "ci-list")
            } else {
                UserDefaults.standard.removeObject(forKey: "ci-list")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    var showMarket: Bool {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "showMarket") as? Bool { return theInstance }
            return true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "showMarket")
            UserDefaults.standard.synchronize()
        }
    }
    
    var hideAssetNumber: Bool {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "hideAssetNumber") as? Bool { return theInstance }
            return false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "hideAssetNumber")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Setting.
    /// Using HTTP Cache.
    var usingCache: Bool {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "usingCache") as? Bool { return theInstance }
            return true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "usingCache")
            UserDefaults.standard.synchronize()
        }
    }
    
    let pathOfHttpCache: String = {
        let path = "\(NSHomeDirectory())/Documents/com.AELF.http"
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: false, attributes: nil)
            } catch {}
        }
        
        print("####################################################################################")
        print("HTTP Cache Path:\(path)\n")
        print("####################################################################################")
        return path
    }()
    
    // MARK: - Thirdparty Framework.
    private func buglySetup() -> Void {
        if isSimulator || IsDebug { return }
        let config = BuglyConfig()
        config.channel = Consts.appChannel()
        config.debugMode = IsDebug
        config.consolelogEnable = IsRelease
        config.reportLogLevel = .info
        config.blockMonitorEnable = true
        Bugly.start(withAppId: Consts.kBuglyAppID, developmentDevice: IsDebug, config: config)
        Bugly.setUserIdentifier(osid(forService: Consts.kBundleID))
    }
    
//    private func umengSetup() -> Void {
//        if isSimulator || IsDebug { return }
//        UMConfigure.initWithAppkey(Consts.kUMengAppKey, channel: Consts.appChannel())
//        UMConfigure.setLogEnabled(false)
//        UMConfigure.setEncryptEnabled(true)
//        MobClick.setCrashReportEnabled(false)
//    }
//
//    private func tingyunSetup() {
//        if isSimulator || IsDebug || self.environment != .prod { return }
//        OConfig.tingyunStartOptionSetup()
//        NBSAppAgent.start(withAppID: Consts.kTingYunAppKey)
//        NBSAppAgent.setUserIdentifier(osid(forService: Consts.kBundleID))
//    }
    
    // MARK: - Other.
    func environmentIndicatorSetup() {
        guard self.environment != .prod else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            let netIndicator = UILabel()
            netIndicator.textColor = .red;
            netIndicator.font = UIFont.systemFont(size: 8.0)
            netIndicator.textAlignment = IsInfinityScreen ? .left : .right
            netIndicator.text = self.environment == .test ? "测试环境" : "生产预发环境"
            kKeyWindow?.addSubview(netIndicator)
            netIndicator.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(kContentOffsetInfinityScreen)
                make.left.equalToSuperview().offset(IsInfinityScreen ? 10.0 : -30.0)
                make.height.equalTo(20.0)
                make.width.equalToSuperview().multipliedBy(0.5)
            }
        }
    }
    
}
