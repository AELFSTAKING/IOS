//
//  BaseTabbarController.swift
//  AELF
//
//  Created by tng on 2018/9/27.
//  Copyright © 2018 AELF. All rights reserved.
//

import Foundation
import UIKit

class BaseTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BarButton Init.
        self.constsSetup()
        
        // Preload the Controllers.
        if let controllers = self.viewControllers {
            for navigation in controllers {
                if let navigationCotroller = navigation as? BaseNavigationController,
                    let controller = navigationCotroller.topViewController {
                        if String(cString: object_getClassName(controller)).contains("TradeVC") {
                        print(String(cString: object_getClassName(controller)))
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                            controller.loadViewIfNeeded()
                        })
                    }
                }
            }
        }
        
        // Signals.
        LanguageManager.shared().languageDidChangedSignal.observeValues { [weak self] (_) in
            self?.constsSetup()
        }
    }
    
    private func constsSetup() {
        let titles = [
            LOCSTR(withKey: "首页"),
            LOCSTR(withKey: "行情"),
            LOCSTR(withKey: "交易"),
            LOCSTR(withKey: "资产"),
            LOCSTR(withKey: "我的")
        ]
        let colorUnable = kThemeColorTextUnabled
        let colorEnable = kThemeColorSelected
        if let barItems = self.tabBar.items, barItems.count > 2 {
            for index in 0..<barItems.count {
                let bar = barItems[index]
                bar.title = titles[index]
                bar.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:colorUnable], for: .normal)
                bar.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:colorEnable], for: .selected)
                if let imageNormal = bar.image {
                    bar.image = imageNormal.withRenderingMode(.alwaysOriginal)
                }
                if let imageSelected = bar.selectedImage {
                    bar.selectedImage = imageSelected.withRenderingMode(.alwaysOriginal)
                }
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return TheCurrentScreenOrientation
    }
    
}
