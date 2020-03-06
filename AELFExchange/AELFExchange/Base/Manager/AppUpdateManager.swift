//
//  AppUpdateManager.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveCocoa

@objc class AppUpdateManager: NSObject {
    
    fileprivate static let ___donotUseThisVariableOfAppUpdateManager = AppUpdateManager()
    
    @discardableResult
    static func shared() -> AppUpdateManager {
        return AppUpdateManager.___donotUseThisVariableOfAppUpdateManager
    }
    
    private var timer: Timer!
    
    private override init() {
        super.init()
        timer = Timer.scheduledTimer(
            timeInterval: Config.versionCheckInterval,
            target: self,
            selector: #selector(self.autoCheck),
            userInfo: nil,
            repeats: true
        )
        timer.fireDate = Date.distantFuture
    }
    
    func checkout(completion: @escaping ((Bool) -> ())) -> Void {
        let params = [
            "version":Bundle.main.versionNumber ?? "",
            "os":Consts.kAppOS
            ] as [String : Any]
        Network.post(withUrl: URLs.shared().genUrl(with: .latestVersion, withoutDexSuffix: true), params: params, to: APPLatestVersionResponse.self) { [weak self] (succeed, response) in
            self?.timer.fireDate = Date(timeIntervalSinceNow: Config.versionCheckInterval)
            guard succeed == true, response.succeed == true else {
                completion(false)
                return
            }
            
            guard response.data?.update == true, let url = response.data?.downloadUrl else {
                completion(false)
                return
            }
            
            completion(true)
            self?.showUpdate(
                with: response.data?.summary ?? "...",
                url: url,
                force: response.data?.forcedUpdate ?? false
            )
        }
    }
    
    private func showUpdate(with updateDesc: String, url: String, force: Bool) -> Void {
        guard kKeyWindow?.viewWithTag(6868) == nil else {
            if let hud = kKeyWindow?.viewWithTag(6868) as? APPUpdateView {
                hud.contentSetup(withDesc: updateDesc)
            }
            return
        }
        
        let hud = Bundle.main.loadNibNamed("APPUpdateView", owner: nil, options: nil)?.first as! APPUpdateView
        hud.contentSetup(withDesc: updateDesc)
        hud.tag = 6868
        hud.closeButton.reactive.controlEvents(.touchUpInside).take(during: self.reactive.lifetime).observeValues { (_) in
            if !force {
                hud.hide()
            } else {
                exit(0)
            }
        }
        hud.confirmButton.reactive.controlEvents(.touchUpInside).take(during: self.reactive.lifetime).observeValues { (_) in
            if let theUrl = URL(string: url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(theUrl, options: [UIApplication.OpenExternalURLOptionsKey:Any](), completionHandler: { (_) in})
                } else {
                    UIApplication.shared.openURL(theUrl)
                }
            }
            if force {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                    exit(0)
                })
            }
        }
        
        kKeyWindow?.addSubview(hud)
        hud.snp.makeConstraints { (make) in
            make.edges.equalTo(kKeyWindow!)
        }
        hud.show()
    }
    
}

extension AppUpdateManager {
    
    @objc func autoCheck() -> Void {
        self.checkout { (_) in }
    }
    
}
