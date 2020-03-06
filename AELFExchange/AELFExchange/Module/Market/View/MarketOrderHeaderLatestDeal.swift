//
//  MarketOrderHeaderLatestDeal.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class MarketOrderHeaderLatestDeal: UIView {
    
    @IBOutlet weak var label1: Label!
    @IBOutlet weak var label2: Label!
    @IBOutlet weak var label3: Label!
    @IBOutlet weak var label4: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.label1.textColor = kThemeColorButtonUnableBlack
        self.label2.textColor = self.label1.textColor
        self.label3.textColor = self.label1.textColor
        self.label4.textColor = self.label1.textColor
    }

}
