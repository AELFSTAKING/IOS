//
//  LanguageManager.swift
//  AELF
//
//  Created by tng on 2019/1/7.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public func InfoPlistString(withKey key: String, comment: String? = nil) -> String {
    return LanguageManager.shared().localizedString(forKey: key, value: "", tblStr: "InfoPlist")
}

public func LOCSTR(withKey key: String, comment: String? = nil) -> String {
    return LanguageManager.shared().localizedString(forKey: key, value: "", tblStr: "Localizable")
}

enum LanguageType: String {
    case ZH_HANS = "ZH_HANS"
    case EN = "EN"
    case AUTO = "Automatically"
}

class LanguageManager {
    
    let (languageDidChangedSignal, languageDidChangedObserver) = Signal<LanguageType, NoError>.pipe()
    
    private static let kUserLanguageKey = "kUserLanguage"
    
    private var bundle: Bundle?
    
    fileprivate static let ___donotUseThisVariableOfLanguageManager = LanguageManager()
    
    @discardableResult
    static func shared() -> LanguageManager {
        return LanguageManager.___donotUseThisVariableOfLanguageManager
    }
    
    private func languageFormat(withLanguage l: LanguageType) -> String {
        if l == .ZH_HANS {
            return "zh-Hans"
        }
        return "en"
    }
    
    func currentLanguage() -> LanguageType {
        if  let customLanguage = UserDefaults.standard.value(forKey: LanguageManager.kUserLanguageKey) as? String,
            let l = LanguageType(rawValue: customLanguage) {
            return l
        }
//        if let ls = NSLocale.preferredLanguages.first { // 默认中文.
//            if ls.contains("zh-Hans") {
                return .ZH_HANS
//            }
//        }
//        return .EN
    }
    
    private func currentBundle() -> Bundle? {
        if let bundle = self.bundle {
            return bundle
        }
        if let bpath = Bundle.main.path(forResource: self.languageFormat(withLanguage: self.currentLanguage()), ofType: "lproj") {
            let b = Bundle(path: bpath)
            self.bundle = b
            return b
        }
        return nil
    }
    
}

extension LanguageManager {
    
    func localizedString(forKey key: String, value: String, tblStr: String) -> String {
        guard let bundle = self.currentBundle() else {
            return key
        }
        guard key.count > 0 else {
            return "-"
        }
        let string = NSLocalizedString(key, tableName: tblStr, bundle: bundle, value: value, comment: "")
        if string.count > 0 {
            return string
        }
        return key
    }
    
    func apiCurrentLanguage() -> String {
        let l = self.currentLanguage()
        if l == .ZH_HANS {
            return "zh-CN"
        }
        return "en-US"
    }
    
    func currentLanguageDescription() -> String {
        let l = self.currentLanguage()
        if l == .ZH_HANS {
            return "简体中文"
        }
        return "English"
    }
    
    func setLanguage(with type: LanguageType) {
        if type == .AUTO {
            UserDefaults.standard.removeObject(forKey: LanguageManager.kUserLanguageKey)
        } else {
            UserDefaults.standard.setValue(type.rawValue, forKey: LanguageManager.kUserLanguageKey)
        }
        UserDefaults.standard.synchronize()
        self.bundle = nil
        self.bundle = self.currentBundle()
        self.languageDidChangedObserver.send(value: type)
    }
    
}
