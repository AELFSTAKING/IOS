//
//  MarketSymbolSelector.swift
//  AELFExchange
//
//  Created by tng on 2019/5/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class MarketSymbolSelector: BaseViewController {
    
    private var selectedCallback: ((SymbolsItem) -> ())?
    var height = kScreenSize.height-180.0
    
    let coverBgView = UIView()
    let marketListPage = UIStoryboard(name: "Market", bundle: nil).instantiateViewController(withIdentifier: "marketList") as! MarketListVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        self.view.alpha = 0.0
        
        self.coverBgView.backgroundColor = .black
        self.coverBgView.alpha = 0.0
        self.view.addSubview(self.coverBgView)
        self.coverBgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hide))
        self.coverBgView.addGestureRecognizer(tap)
        
        self.addChild(self.marketListPage)
        self.view.addSubview(self.marketListPage.view)
        self.marketListPage.view.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(height)
        }
        self.marketListPage.didSelectedSymbolCallback = { [weak self] (symbol) in
            if let callback = self?.selectedCallback {
                callback(symbol)
            }
        }
    }
    
    @objc func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.coverBgView.alpha = 0.0
            self.marketListPage.view.transform = .identity
        }, completion: { (_) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    static func show(on controller: UIViewController, completion completionCallback: @escaping ((SymbolsItem) -> ()), collectChanged collectChangeCallback: @escaping (() -> ())) {
        let selector = MarketSymbolSelector()
        selector.marketListPage.isSelector = true
        selector.selectedCallback = { (symbol) in
            completionCallback(symbol)
            selector.hide()
        }
        selector.marketListPage.didUpdateCollectionCallback = {
            collectChangeCallback()
        }
        controller.addChild(selector)
        controller.view.addSubview(selector.view)
        selector.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.2) {
            selector.view.alpha = 1.0
            selector.coverBgView.alpha = 0.5
            selector.marketListPage.view.transform = CGAffineTransform(translationX: 0, y: -selector.height)
        }
    }
    
}
