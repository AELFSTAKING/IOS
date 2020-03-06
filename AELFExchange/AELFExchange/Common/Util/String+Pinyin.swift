//
//  String+Pinyin.swift
//  AELFExchange
//
//  Created by tng on 2019/1/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

extension String {
    
    func pinyin() -> String {
        let format = HanyuPinyinOutputFormat()
        format?.toneType = ToneTypeWithoutTone
        format?.vCharType = VCharTypeWithV
        format?.caseType = CaseTypeUppercase
        return PinyinHelper.toHanyuPinyinString(with: self, with: format, with: " ")
    }
    
    func pinyinFirstChar() -> String {
        let pinyin = self.pinyin()
        if pinyin.count > 0 {
            return String(pinyin[pinyin.startIndex ..< pinyin.index(pinyin.startIndex, offsetBy: 1)])
        }
        return ""
    }
    
    func firstChar() -> String {
        let format = HanyuPinyinOutputFormat()
        format?.toneType = ToneTypeWithoutTone
        format?.vCharType = VCharTypeWithV
        format?.caseType = CaseTypeUppercase
        
        let fullPinyinStr = PinyinHelper.toHanyuPinyinString(with: self, with: format, with: " ")
        let pinyinComps = fullPinyinStr?.components(separatedBy: " ")
        var firstChar = ""
        if let list = pinyinComps {
            for item in list {
                if item.count > 0 {
                    firstChar = String(item[item.startIndex ..< item.index(item.startIndex, offsetBy: 1)])
                    break
                }
            }
        }
        return firstChar
    }
    
}
