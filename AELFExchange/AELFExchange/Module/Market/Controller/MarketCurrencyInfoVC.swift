//
//  CurrencyDetailVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/22.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class MarketCurrencyInfoVC: BaseViewController {
    
    @IBOutlet weak var contentViewHeightOffset: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currencyLabel: Label!
    @IBOutlet weak var chainNameLabel: Label!
    @IBOutlet weak var currencyIcon: UIImageView!
    @IBOutlet weak var intro: Label!
    @IBOutlet weak var mainWebsiteAddr: Label!
    @IBOutlet weak var dateLaebl: Label!
    @IBOutlet weak var availableQuantityLabel: Label!
    @IBOutlet weak var distributeQuanityLabel: Label!
    @IBOutlet weak var priceLabel: Label!
    @IBOutlet weak var wpaperAddrLabel: Label!
    @IBOutlet weak var blockExploreLabel: Label!
    
    var currency: String?
    private var currencyInfo: CurrencyInfoData?
    
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
    @IBAction func mainWebsitePressed(_ sender: Any) {
        guard let urlStr = self.currencyInfo?.officialWebsite else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            return
        }
        self.push(to: WebPage(withUrl: urlStr, as: self.currency), animated: true)
    }
    
    @IBAction func whitepaperPressed(_ sender: Any) {
        guard let urlStr = self.currencyInfo?.whitePaper else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            return
        }
        self.push(to: WebPage(withUrl: urlStr, as: self.currency), animated: true)
    }
    
    @IBAction func blockExplorePressed(_ sender: Any) {
        guard let urlStr = self.currencyInfo?.blockChainAddressSearch else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            return
        }
        self.push(to: WebPage(withUrl: urlStr, as: self.currency), animated: true)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let currency = self.currency else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            return
        }
        self.title = currency
        
        CurrencyManager.shared().info(of: currency) { [weak self] (data) in
            self?.currencyInfo = data
            self?.currencyLabel.text = ""
            self?.chainNameLabel.text = data.currencyCode
            if let url = URL(string: data.currencyTwIntroduction ?? "") {
                self?.currencyIcon.kf.setImage(with: ImageResource(downloadURL: url))
            }
            self?.intro.text = data.currencyCnIntroduction
            self?.mainWebsiteAddr.text = data.officialWebsite
            self?.dateLaebl.text = data.issueDate?.timestamp2date(withFormat: "yyyy-MM-dd")
            self?.availableQuantityLabel.text = data.circulateQuantity
            self?.distributeQuanityLabel.text = data.issueQuantity
            self?.priceLabel.text = data.issuePrice
            self?.wpaperAddrLabel.text = data.whitePaper
            self?.blockExploreLabel.text = data.blockChainAddressSearch
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                let realHeight = 550.0+(self?.intro.frame.height ?? 0.0)
                let containerHeight = self?.scrollView.frame.height ?? 0
                if realHeight > containerHeight {
                    self?.contentViewHeightOffset.constant = realHeight-containerHeight
                }
            })
        }
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
