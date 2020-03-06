//
//  MarketListVC.swift
//  AELFExchange
//
//  Created by tng on 2019/5/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class MarketListVC: TabmanViewController {
    
    var didSelectedSymbolCallback: ((SymbolsItem) -> ())?
    var didUpdateCollectionCallback: (() -> ())?
    
    let menus = [LOCSTR(withKey: "自选"), LOCSTR(withKey: "全部")]
    var controllers = [UIViewController]()
    var isSelector = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.view.backgroundColor = kThemeColorBackground
        
        let collectionController = MarketEntranceContentListVC()
        collectionController.viewModel.mode = .collection
        collectionController.isSelector = self.isSelector
        collectionController.viewModel.doNotShowAddButton = true
        collectionController.didPressedGoColelctCallback = { [weak self] in
            self?.scrollToPage(.last, animated: true)
        }
        collectionController.didSelectedSymbolCallback = { [weak self] (symbol) in
            self?.didSelectedSymbolCallback?(symbol)
        }
        let allMarketController = MarketEntranceContentListVC()
        allMarketController.viewModel.mode = .market
        allMarketController.isSelector = self.isSelector
        allMarketController.didSelectedSymbolCallback = { [weak self] (symbol) in
            self?.didSelectedSymbolCallback?(symbol)
        }
        
        self.controllers.append(collectionController)
        self.controllers.append(allMarketController)
        
        let bar = TMBar.ButtonBar()
        bar.backgroundView.style = TMBarBackgroundView.Style.flat(color: .white)
        bar.layout.contentInset = UIEdgeInsets(top: 0, left: (kScreenSize.width-180.0)/2.0, bottom: 0, right: (kScreenSize.width-180.0)/2.0)
        bar.layout.contentMode = .fit
        bar.layout.interButtonSpacing = 80.0
        bar.indicator.weight = .light
        bar.indicator.cornerStyle = .eliptical
        bar.indicator.tintColor = kThemeColorTextNormal
        bar.buttons.customize { (button) in
            button.tintColor = kThemeColorTextUnabled
            button.selectedTintColor = bar.indicator.tintColor
            button.font = .boldSystemFont(size: 14.0)
        }
        self.dataSource = self
        self.addBar(bar, dataSource: self, at: .top)
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

// MARK: - PageboyViewControllerDataSource
extension MarketListVC: TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        guard index < self.menus.count else {
            return TMBarItem(title: "")
        }
        return TMBarItem(title: self.menus[index])
    }
    
}

// MARK: - PageboyViewControllerDataSource/Delegate
extension MarketListVC: PageboyViewControllerDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.controllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        guard index < self.controllers.count else {
            return nil
        }
        return self.controllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
}
