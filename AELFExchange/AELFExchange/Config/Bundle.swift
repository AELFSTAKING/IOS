//
//  Bundle.swift
//  AELF
//
//  Created by tng on 2018/9/13.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation

var IsDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}

let IsRelease = !IsDebug

var isSimulator: Bool {
    #if arch(i386) || arch(x86_64)
    return true
    #endif
    return false
}

extension Bundle {
    
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    var buildNumberInt: Int {
        return Int(Bundle.main.buildNumber ?? "-1") ?? -1
    }
    
    var fullVersion: String {
        let versionNumber = Bundle.main.versionNumber ?? ""
        let buildNumber = Bundle.main.buildNumber ?? ""
        return "\(versionNumber) (\(buildNumber))"
    }
    
}
