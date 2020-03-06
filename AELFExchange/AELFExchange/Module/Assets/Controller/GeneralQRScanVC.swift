//
//  GeneralQRScanVC.swift
//  CEXExchange
//
//  Created by tng on 2019/8/14.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import UIKit
import Photos

class GeneralQRScanVC: LBXScanViewController {
    
    var completion: ((String) -> ())?
    var backToClass: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @objc private func albumPressed() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        guard authStatus == .authorized || authStatus == .notDetermined else {
            SystemAlert(withStyle: .alert, on: TopController(), title: LOCSTR(withKey: "访问权限"), detail: LOCSTR(withKey: "暂无相册访问权限，是否立即开启？"), actions: [LOCSTR(withKey: "取消"), LOCSTR(withKey: "立即开启")], callback: { (index) in
                guard let index = index, index == 1, let url = URL(string: UIApplication.openSettingsURLString) else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey:Any](), completionHandler: { (_) in})
                } else {
                    UIApplication.shared.openURL(url)
                }
            })
            return
        }
        self.openPhotoAlbum()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "扫码二维码")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let navBarItem = UIBarButtonItem(title: LOCSTR(withKey: "相册"), style: .plain, target: self, action: #selector(self.albumPressed))
        let attr = [NSAttributedString.Key.foregroundColor:kThemeColorTextNormal,NSAttributedString.Key.font:kThemeFontNormal]
        navBarItem.setTitleTextAttributes(attr, for: .normal)
        navBarItem.setTitleTextAttributes(attr, for: .highlighted)
        navBarItem.setTitlePositionAdjustment(UIOffset(horizontal: 8.0, vertical: 0.0), for: .default)
        self.navigationItem.rightBarButtonItems = [navBarItem]
        
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44.0
        style.photoframeLineW = 6.0
        style.photoframeAngleW = 24.0
        style.photoframeAngleH = 24.0
        style.xScanRetangleOffset = 80.0
        style.colorRetangleLine = kThemeColorSeparator
        style.colorAngle = kThemeColorForeground
        style.isNeedShowRetangle = true
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.On
        style.anmiationStyle = LBXScanViewAnimationStyle.NetGrid
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net")
        self.readyString = "\(LOCSTR(withKey: "正在启动"))..."
        self.scanStyle = style
        self.isOpenInterestRect = true
        self.scanResultDelegate = self
        
        /*
        let infoLabel = UILabel()
        infoLabel.textColor = .white
        infoLabel.backgroundColor = ColorRGB(r: 17.0, g: 17.0, b: 17.0)
        infoLabel.font = kThemeFontSmall
        infoLabel.textAlignment = .center
        infoLabel.alpha = 0.75
        infoLabel.text = "   \(self.infoTitle ?? "")   "
        infoLabel.addCorner(withRadius: 15.0)
        infoLabel.addBorder(withWitdh: 0.8, color: kThemeColorTextUnabled)
        self.view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(130.0)
            make.height.equalTo(30.0)
        }*/
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon-backarrow"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        let backItem = UIBarButtonItem(customView: button)
        backItem.imageInsets = UIEdgeInsets(top: 0, left: -6.5, bottom: 0, right: 6.5)
        self.navigationItem.leftBarButtonItems = [backItem]
    }
    
    private func signalSetup() -> Void {
        
    }
    
    @objc fileprivate func backAction() -> Void {
        guard let controllers = self.navigationController?.viewControllers, let backTo = self.backToClass else {
            self.pop()
            return
        }
        for case let controller in controllers where String(cString: object_getClassName(controller)).contains(backTo) {
            self.navigationController?.popToViewController(controller, animated: true)
            return
        }
        self.pop()
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension GeneralQRScanVC: LBXScanViewControllerDelegate {
    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        guard let content = scanResult.strScanned, let callback = self.completion else { return }
        if let error = error {
            InfoToast(withLocalizedTitle: error)
            return
        }
        callback(content)
    }
    
}
