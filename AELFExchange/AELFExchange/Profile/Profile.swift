//
//  Profile.swift
//  AELFExchange
//
//  Created by tng on 2019/1/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class Profile {
    
    fileprivate static let ___donotUseThisVariableOfProfile = Profile()
    
    @discardableResult
    static func shared() -> Profile {
        return Profile.___donotUseThisVariableOfProfile
    }
    
    let (logoutSignal, logoutObserver) = Signal<Bool, NoError>.pipe()
    let (loginSignal, loginObserver) = Signal<Bool, NoError>.pipe()
    
}

// MARK: - Cache Data.
extension Profile {
    
}
