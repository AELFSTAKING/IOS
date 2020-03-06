//
//  Toast.swift
//  AELF
//
//  Created by tng on 2018/9/28.
//  Copyright © 2018 AELF. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func ToastInfoError() -> Void {
        SystemAlert(withStyle: .alert, title: "错误", detail: "信息有误，请重试", actions: ["好的"], callback: { (_) in})
    }
    
    func ToastLoading() -> Void {
        SystemAlert(withStyle: .alert, title: "提示", detail: "信息读取中，请重试", actions: ["好吧"], callback: { (_) in})
    }
    
    func startLoadingHUD(withMsg msg: String? = nil, on container: UIView? = nil, center: Bool = false, clearBg: Bool = false, bgAlpha: CGFloat = 0.35) -> Void {
        if let hud = (container == nil ? self.view : container!).viewWithTag(886699) {
            if  let msg = msg,
                let label = hud.viewWithTag(669911) as? UILabel {
                label.text = msg
            }
        } else {
            let hud = UIView()
            hud.tag = 886699
            hud.backgroundColor = .clear
            if let container = container {
                container.addSubview(hud)
                hud.snp.makeConstraints { (make) in
                    make.edges.equalTo(container)
                }
            } else {
                self.view.addSubview(hud)
                hud.snp.makeConstraints { (make) in
                    make.edges.equalTo(self.view)
                }
            }
            
            let coverView = UIView()
            if !clearBg {
                coverView.backgroundColor = .black
                coverView.alpha = bgAlpha
            }
            hud.addSubview(coverView)
            coverView.snp.makeConstraints { (make) in
                make.edges.equalTo(hud)
            }
            
            let img = UIImageView()
            img.animationImages = [
                UIImage(named: "icon-loading-1")!,
                UIImage(named: "icon-loading-2")!,
                UIImage(named: "icon-loading-3")!,
                UIImage(named: "icon-loading-4")!,
                UIImage(named: "icon-loading-5")!,
                UIImage(named: "icon-loading-6")!
            ]
            img.tag = 668899
            img.animationDuration = 1.0
            img.contentMode = .scaleAspectFit
            hud.addSubview(img)
            img.snp.makeConstraints { (make) in
                if center {
                    make.centerY.equalTo(hud)
                } else {
                    make.centerY.equalTo(hud).offset(-50.0)
                }
                make.centerX.equalTo(hud)
                make.width.equalTo(108.0)
                make.height.equalTo(30.0)
            }
            
            if let msg = msg {
                let label = UILabel()
                label.font = kThemeFontSmall
                label.textColor = .white
                label.textAlignment = .center
                label.text = msg
                label.tag = 669911
                hud.addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.top.equalTo(img.snp.bottom).offset(5.0)
                    make.left.equalTo(hud).offset(10.0)
                    make.right.equalTo(hud).offset(-10.0)
                }
            }
            
            img.startAnimating()
            UIView.animate(withDuration: 0.2) {
                hud.alpha = 1.0
            }
        }
    }
    
    func stopLoadingHUD(on container: UIView? = nil) -> Void {
        guard let hud = (container == nil ? self.view : container!).viewWithTag(886699),
            let img = hud.viewWithTag(668899) as? UIImageView else {
                return
        }
        img.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            hud.alpha = 0
        }) { (_) in
            hud.removeFromSuperview()
        }
    }
    
}
