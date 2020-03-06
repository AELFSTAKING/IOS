//
//  MarketEntranceVC.swift
//  AELFExchange
//
//  Created by tng on 2019/7/16.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

class MarketEntranceVC: TabmanViewController {
    
    let menus = [LOCSTR(withKey: "自选"), LOCSTR(withKey: "全部")]
    var controllers = [UIViewController]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    private func itemPressed(withData data: SymbolsItem) {
        self.push(to: KLineController(with: data), animated: true)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "行情")
        self.view.backgroundColor = kThemeColorBackground
        
        let collectionController = MarketEntranceContentListVC()
        collectionController.viewModel.doNotShowAddButton = false
        collectionController.viewModel.mode = .collection
        collectionController.didPressedGoColelctCallback = { [weak self] in
            self?.scrollToPage(.last, animated: true)
        }
        collectionController.didSelectedSymbolCallback = { [weak self] (item) in
            self?.itemPressed(withData: item)
        }
        
        let allMarketController = MarketEntranceContentListVC()
        allMarketController.viewModel.mode = .market
        allMarketController.didSelectedSymbolCallback = { [weak self] (item) in
            self?.itemPressed(withData: item)
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
extension MarketEntranceVC: TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        guard index < self.menus.count else {
            return TMBarItem(title: "")
        }
        return TMBarItem(title: self.menus[index])
    }
    
}

// MARK: - PageboyViewControllerDataSource/Delegate
extension MarketEntranceVC: PageboyViewControllerDataSource {
    
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
