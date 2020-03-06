//
//  SupportsDetailVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/17.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class SupportsDetailVC: BaseViewController {
    
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var detailTextview: UITextView! {
        didSet {
            detailTextview.backgroundColor = kThemeColorForeground
            detailTextview.indicatorStyle = .white
        }
    }
    
    var data: NoticeDetailResponseData?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let data = self.data else {
            InfoToast(withLocalizedTitle: "信息加载失败")
            self.pop()
            return
        }
        self.title = LOCSTR(withKey: "帮助&支持")
        self.titleLabel.text = data.title
        
        do {
            if  let info = data.content,
                let data = "\(kThemeStyleImage)\(info)".data(using: String.Encoding.unicode) {
                let infoAttr = try NSMutableAttributedString(
                    data: data,
                    options: [
                        NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,
                        ],
                    documentAttributes: nil
                )
                infoAttr.addAttributes([
                    NSAttributedString.Key.foregroundColor:UIColor.white,
                    NSAttributedString.Key.backgroundColor:UIColor.clear,
                    NSAttributedString.Key.font:kThemeFontNormal
                    ],
                    range: NSRange(location: 0, length: infoAttr.length)
                )
                self.detailTextview.attributedText = infoAttr
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                    self.detailTextview.contentOffset = .zero
                }
            }
        } catch {}
    }
    
    private func signalSetup() -> Void {
        
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}
