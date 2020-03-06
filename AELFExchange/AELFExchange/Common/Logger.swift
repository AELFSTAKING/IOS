//
//  Logger.swift
//  AELF
//
//  Created by tng on 2018/9/13.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation

public let enableLog = true

public let logLevelDebug = LogLevel.Debug
public let logLevelRelease = LogLevel.Debug

public enum LogLevel: Int {
    case Debug = 0
    case Info  = 1
    case Warn  = 2
    case Error = 3
}

public func log(content: String, level: LogLevel) -> Void {
    if !enableLog {
        return
    }
    
    if IsRelease && level.rawValue < logLevelRelease.rawValue {
        return
    }
    
    if IsDebug && level.rawValue < logLevelDebug.rawValue {
        return
    }
    
    print("[\(level)] \(Date()) \(content)")
}

public func logdebug(content: String) -> Void {
    log(content: "🔗 \(content)", level: .Debug)
}

public func loginfo(content: String) -> Void {
    log(content: "♻️ \(content)", level: .Info)
}

public func logwarn(content: String) -> Void {
    log(content: "⚠️ \(content)", level: .Warn)
}

public func logerror(content: String) -> Void {
    log(content: "❌ \(content)", level: .Error)
}
