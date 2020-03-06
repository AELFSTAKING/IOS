//
//  BaseNavigationController.swift
//  AELF
//
//  Created by tng on 2018/9/20.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self.interactivePopGestureRecognizer as? UIGestureRecognizerDelegate
        
        if #available(iOS 11.0, *) {
            self.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:kThemeColorNavigationBackButton]
        }
        self.navigationBar.tintColor = kThemeColorNavigationBackButton
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    /// For the controllers that is not to be controlled with BaseTabbarController.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return TheCurrentScreenOrientation
    }
    
}

extension BaseNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count == 1 {
            self.interactivePopGestureRecognizer?.isEnabled = false
        } else {
            self.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
}
