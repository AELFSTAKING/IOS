//
//  WebViewMenuView.swift
//  AELFExchange
//
//  Created by tng on 2019/3/20.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

enum WebViewMenuEventEnum {
    case exit
    case fullscreenOn
    case fullscreenOff
}

class WebViewMenuView: UIView {
    
    var isMenuAppeared = false
    var isFullScreen = false
    var eventCallback: ((WebViewMenuEventEnum) -> ())?
    
    private var size: CGSize?
    
    let showMenuButton = UIButton(type: .system)
    let menuView = UIView()
    let exitButton = UIButton(type: .system)
    let fullScreenButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.menuView.backgroundColor = ColorRGBA(r: 0.0, g: 0.0, b: 0.0, a: 0.5)
        self.menuView.addCorner(withRadius: 5.0)
        self.menuView.alpha = 0.0
        self.uiSetup()
        
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(self.panGesHanlder(_:)))
        self.showMenuButton.addGestureRecognizer(panGes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func uiSetup() {
        showMenuButton.tintColor = .white
        exitButton.tintColor = showMenuButton.tintColor
        fullScreenButton.tintColor = showMenuButton.tintColor
        exitButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5.0, bottom: 0, right: 5.0)
        fullScreenButton.imageEdgeInsets = exitButton.imageEdgeInsets
        showMenuButton.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        showMenuButton.addTarget(self, action: #selector(self.menuPressed), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(self.exitPressed), for: .touchUpInside)
        fullScreenButton.addTarget(self, action: #selector(self.fullScreenPressed), for: .touchUpInside)
        
        showMenuButton.backgroundColor = self.menuView.backgroundColor
        showMenuButton.addCorner(withRadius: 5.0)
        showMenuButton.imageView?.contentMode = .scaleAspectFit
        showMenuButton.setImage(UIImage(named: "icon-web-menu"), for: .normal)
        self.addSubview(showMenuButton)
        showMenuButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 40.0, height: 40.0))
        }
        
        self.addSubview(menuView)
        menuView.snp.makeConstraints { (make) in
            make.top.equalTo(showMenuButton.snp.bottom).offset(5.0)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        menuView.addSubview(exitButton)
        menuView.addSubview(fullScreenButton)
        
        exitButton.imageView?.contentMode = .scaleAspectFit
        exitButton.setImage(UIImage(named: "icon-web-exit"), for: .normal)
        exitButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5.0)
            make.left.equalToSuperview()
            //make.bottom.equalTo(fullScreenButton.snp.top).offset(-5.0)
            make.bottom.equalToSuperview().offset(-5.0)
            make.right.equalToSuperview()
        }
        
        /*
        fullScreenButton.imageView?.contentMode = .scaleAspectFit
        fullScreenButton.setImage(UIImage(named: "icon-web-fullscreen-on"), for: .normal)
        fullScreenButton.snp.makeConstraints { (make) in
            make.top.equalTo(exitButton.snp.bottom).offset(5.0)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5.0)
            make.left.equalToSuperview()
            make.height.equalTo(exitButton)
        }*/
    }
    
    @objc private func menuPressed() {
        self.isMenuAppeared.toggle()
        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = self.isMenuAppeared ? 1.0 : 0.0
        }
    }
    
    @objc private func exitPressed() {
        self.menuPressed()
        if let callback = self.eventCallback {
            callback(.exit)
        }
    }
    
    @objc private func fullScreenPressed() {
        self.menuPressed()
        if let callback = self.eventCallback {
            callback(self.isFullScreen ? .fullscreenOff : .fullscreenOn)
        }
        self.isFullScreen.toggle()
        fullScreenButton.setImage(UIImage(named: "icon-web-fullscreen-\(self.isFullScreen ? "off" : "on")"), for: .normal)
    }
    
    func shouldEnterFullScreen() {
        self.isMenuAppeared = false
        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 0.0
        }
        if let callback = self.eventCallback {
            callback(.fullscreenOn)
        }
        self.isFullScreen = true
        fullScreenButton.setImage(UIImage(named: "icon-web-fullscreen-off"), for: .normal)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isMenuAppeared {
            return super.hitTest(point, with: event)
        } else {
            if self.menuView.frame.contains(point) {
                return nil
            } else {
                return super.hitTest(point, with: event)
            }
        }
    }
    
}

extension WebViewMenuView {
    
    @objc func panGesHanlder(_ ges: UIPanGestureRecognizer) {
        let location = ges.location(in: kKeyWindow)
        var x = location.x
        var y = location.y+self.showMenuButton.frame.height+5.0
        
        switch ges.state {
        case .began:
            if nil == self.size {
                self.size = self.frame.size
            }
        case .changed:
            self.snp.remakeConstraints { (make) in
                make.centerX.equalTo(x)
                make.centerY.equalTo(y)
                make.size.equalTo(self.size ?? self.frame.size)
            }
        case .failed, .cancelled, .ended:
            let tabbarHeight = CGFloat(self.isFullScreen ? 0 : kTabBarHeight)
            if  x > kScreenSize.width-self.showMenuButton.frame.width+6.0 ||
                x < self.frame.width-self.showMenuButton.frame.width+25.0 ||
                y > kScreenSize.height-tabbarHeight-self.menuView.frame.height+25.0 ||
                y < CGFloat(kContentOffsetInfinityScreen+20.0)+self.showMenuButton.frame.height+15.0 {
                
                if x > kScreenSize.width-self.showMenuButton.frame.width+6.0 {
                    x = kScreenSize.width-self.showMenuButton.frame.width+6.0
                } else if x < self.frame.width-self.showMenuButton.frame.width+25.0 {
                    x = self.frame.width-self.showMenuButton.frame.width+25.0
                }
                if y > kScreenSize.height-tabbarHeight-self.menuView.frame.height+23.0 {
                    y = kScreenSize.height-tabbarHeight-self.menuView.frame.height+23.0
                } else if y < CGFloat(kContentOffsetInfinityScreen+20.0)+self.showMenuButton.frame.height+15.0 {
                    y = CGFloat(kContentOffsetInfinityScreen+20.0)+self.showMenuButton.frame.height+15.0
                }
                
                UIView.animate(withDuration: 0.2) {
                    self.snp.remakeConstraints { (make) in
                        make.centerX.equalTo(x)
                        make.centerY.equalTo(y)
                        make.size.equalTo(self.size ?? self.frame.size)
                    }
                    if let parentController = self.parentContainerViewController() {
                        parentController.view.layoutIfNeeded()
                    }
                }
                
            }
        default:break
        }
    }
    
}
