//
//  NoticeDetailVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import WebKit

class NoticeDetailVC: BaseViewController {
    
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var sepView: UIView! {
        didSet {
            sepView.backgroundColor = kThemeColorSeparator
        }
    }
    @IBOutlet weak var detailTextView: UITextView! {
        didSet {
            detailTextView.backgroundColor = .clear
            detailTextView.indicatorStyle = .white
        }
    }
    
    var theTitle: String?
    var content: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        
        self.titleLabel.text = self.theTitle
        guard let html = self.content else {
            return
        }
        
        do {
            if  let data = "\(kThemeStyleImage)\(html)".data(using: String.Encoding.unicode) {
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
                self.detailTextView.attributedText = infoAttr
            }
        } catch {}
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
        self.title = LOCSTR(withKey: "公告")
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
