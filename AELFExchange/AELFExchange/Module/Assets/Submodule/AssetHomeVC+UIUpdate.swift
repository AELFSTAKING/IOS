//
//  AssetHomeVC+UIUpdate.swift
//  AELFExchange
//
//  Created by tng on 2019/8/1.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

extension AssetHomeVC {
    
    func staticsUpdate() {
        self.tableTopOffset.constant = AELFIdentity.hasIdentity() ? 0.0:32.0
        
        let hasIdentity = AELFIdentity.shared().identity != nil
        self.nameLabel.isHidden = !hasIdentity
        //self.lagalValueLabel.isHidden = !hasIdentity
        self.lagalValueLabel.isHidden = true // 暂时隐藏.
        self.settingButton.isHidden = !hasIdentity
        self.rewardView.isHidden = !hasIdentity
        self.topBarView.isHidden = hasIdentity
        
        if AELFIdentity.hasIdentity() {
            self.nameLabel.text = AELFIdentity.shared().identity?.name
        }
    }
    
    func headerUpdate() {
        guard let data = self.viewModel.assetData else {
            return
        }
        self.quantityValueLabel.text = self.viewModel.hideAssetsNumber ? "****":data.totalUsdtAsset?.usdtString()
        self.lagalValueLabel.text = self.viewModel.hideAssetsNumber ? "***":"≈ $\((data.totalUsdAsset ?? "0.0").legalString())"
        
        // Reward.
        self.receivedValueLabel.text = "\(self.viewModel.rewardData?.sendedRewardFormatted ?? "--")"
        self.waittingForValueLabel.text = "\(self.viewModel.rewardData?.unsendRewardFormatted ?? "--")"
        self.rewardCurrencyLabel1.text = self.viewModel.rewardData?.rewardCurrency ?? ""
    }
    
}
