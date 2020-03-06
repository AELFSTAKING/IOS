//
//  TradeOrderCurrentHeader.swift
//  AELFExchange
//
//  Created by tng on 2019/1/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class TradeOrderCurrentHeader: UIView {
    
    @IBOutlet weak var priceTitleLabel: Label!
    @IBOutlet weak var quantityTitleLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.priceTitleLabel.textColor = kThemeColorButtonUnableGary
        self.quantityTitleLabel.textColor = kThemeColorButtonUnableGary
        self.priceTitleLabel.font = .systemFont(size: 10.0)
        self.quantityTitleLabel.font = self.priceTitleLabel.font
    }
    
    func updateCurrency(withCurreny currency: String, baseCurreny: String) {
        if currency.count > 0 {
            self.priceTitleLabel.text = "\(LOCSTR(withKey: "价格"))(\(baseCurreny))"
        }
        if baseCurreny.count > 0 {
            self.quantityTitleLabel.text = "\(LOCSTR(withKey: "数量"))(\(currency))"
        }
    }
    
}
