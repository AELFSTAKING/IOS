//
//  HomeSymbolListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/4/9.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class HomeSymbolListCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var detailLabelLeft: UILabel!
    @IBOutlet weak var detailLabelCenter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.symbolLabel.font = kThemeFontDINBold(16.0)
        self.priceLabel.font = kThemeFontDINBold(16.0)
        self.rateLabel.font = kThemeFontDINBold(14.0)
        self.priceLabel.textColor = kThemeColorTextNormal
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func sync(with data: SymbolsItem, mode: HomeSymbolRankListCellType) {
        if  let symbol = data.symbol,
            let indexOfLine = symbol.index(of: "/") {
            DispatchQueue.global().async {
                let len = symbol.count
                let symboAttr = NSMutableAttributedString(string: symbol)
                let attrLeft = [
                    NSAttributedString.Key.font : kThemeFontDINNormal,
                    NSAttributedString.Key.foregroundColor : kThemeColorTextNormal
                ]
                let attrRight = [
                    NSAttributedString.Key.font : kThemeFontDINSmall,
                    NSAttributedString.Key.foregroundColor : kThemeColorTextUnabled
                ]
                symboAttr.addAttributes(attrLeft, range: NSRange(location: 0, length: indexOfLine))
                symboAttr.addAttributes(attrRight, range: NSRange(location: indexOfLine, length: len-indexOfLine))
                DispatchQueue.main.async {
                    self.symbolLabel.attributedText = symboAttr
                }
            }
        } else {
            self.symbolLabel.text = data.symbol
        }
        
        self.priceLabel.text = data.price ?? data.lastPrice
        self.detailLabelCenter.text = "≈ \(data.lastUsdPrice ?? data.usdPrice ?? "0")"
        
        if mode == .price {
            self.detailLabelLeft.text = "\(LOCSTR(withKey: "24H量")) \(data.quantity ?? "0")"
            self.rateLabel.textAlignment = .center
            self.rateLabel.backgroundColor = data.theDirection == .flat ? kThemeColorTextUnabled : PriceColor(withDirection: data.theDirection)
            self.rateLabel.text = "\(DirectionSymbol(withDirection: data.theDirection))\(data.wavePercent ?? "--")%"
        } else {
            self.detailLabelLeft.text = "\(LOCSTR(withKey: "涨跌幅")) \(data.wavePercent ?? "--")%"
            self.rateLabel.textAlignment = .right
            self.rateLabel.backgroundColor = .clear
            self.rateLabel.textColor = kThemeColorTextNormal
            self.rateLabel.text = data.quantity
        }
    }
    
}
