//
//  RiseGridItemView.swift
//  AELFExchange
//
//  Created by tng on 2019/1/8.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class RiseGridItemView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = kThemeColorBackground
        self.symbolLabel.textColor = kThemeColorTextNormal
        self.priceLabel.textColor = .white
        self.rateLabel.textColor = kThemeColorGreen
        self.symbolLabel.font = kThemeFontDINBold(13.0)
        self.priceLabel.font = kThemeFontDINBold(20.0)
        self.rateLabel.font = kThemeFontDINBold(14.0)
    }
    
    func sync(withData data: SymbolsTrendingItem) -> Void {
        let color = PriceColor(withDirection: data.theDirection)
        self.symbolLabel.textColor = kThemeColorTextUnabled
        self.symbolLabel.text = data.symbol
        self.priceLabel.text = data.price
        self.priceLabel.textColor = color
        self.rateLabel.text = "\(DirectionSymbol(withDirection: data.theDirection))\(data.wavePercent ?? "--")%"
        self.rateLabel.textColor = color
    }

}
