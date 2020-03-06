//
//  OrderBookDetailHeaderView.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import UIKit

class OrderBookDetailHeaderView: UIView {
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var dateLabel: Label!
    @IBOutlet weak var statusLabel: Label!
    @IBOutlet weak var getbackTitleLabel: UILabel!
    @IBOutlet weak var getBackTimeLabel: UILabel!
    @IBOutlet weak var sepView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.modeLabel.addBorder(withWitdh: 0.8, color: kThemeColorRed)
        self.sepView.backgroundColor = kThemeColorSeparator
    }
    
}
