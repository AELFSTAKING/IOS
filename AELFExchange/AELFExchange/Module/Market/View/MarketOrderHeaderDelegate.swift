//
//  MarketOrderHeaderDelegate.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class MarketOrderHeaderDelegate: UIView {
    
    @IBOutlet weak var buyLabel: Label!
    @IBOutlet weak var sellLabeel: Label!
    @IBOutlet weak var priceLabel: Label!
    @IBOutlet weak var depthButton: Button! {
        didSet {
            depthButton.titleLabel?.font = UIFont.systemFont(size: 10.0)
            depthButton.setTitleColor(kThemeColorTextUnabled, for: .normal)
            depthButton.addCorner(withRadius: 2.0)
            depthButton.addBorder(withWitdh: 0.6, color: kThemeColorTextUnabled)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    func sync(with currency: String, baseCurrency: String) {
        self.buyLabel.text = "买盘 数量(\(currency))"
        self.sellLabeel.text = "数量(\(currency)) 卖盘"
        self.priceLabel.text = "价格(\(baseCurrency))"
    }

}
