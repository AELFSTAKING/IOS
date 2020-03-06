//
//  MarketHomeCell.swift
//  AELFExchange
//
//  Created by tng on 2019/1/20.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class MarketHomeCell: UITableViewCell {
    
    var pressedCollectCallback: ((String, UIButton) -> ())?

    @IBOutlet weak var theContentView: UIView! {
        didSet {
            theContentView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var symbolLabel: Label!
    @IBOutlet weak var digitalPriceLabel: Label!
    @IBOutlet weak var volumeLabel: Label!
    @IBOutlet weak var legalPriceLabel: Label!
    @IBOutlet weak var rateButton: Button! {
        didSet {
            rateButton.isUserInteractionEnabled = false
            rateButton.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    private var data: SymbolsItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.rateButton.setTitleColor(.white, for: .normal)
        self.rateButton.addCorner(withRadius: 3.0)
        self.rateButton.titleLabel?.font = kThemeFontDINBold(16.0)
        self.volumeLabel.font = kThemeFontDINBold(12.0)
        self.digitalPriceLabel.font = kThemeFontDINBold(18.0)
        self.digitalPriceLabel.textColor = kThemeColorTextNormal
        self.legalPriceLabel.font = kThemeFontDINBold(12.0)
        self.legalPriceLabel.textColor = kThemeColorTextUnabled
        self.rateButton.addTarget(self, action: #selector(self.collectButtonPressed), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func collectButtonPressed() {
        guard let d = self.data, let callback = self.pressedCollectCallback, let symbol = d.symbol else { return }
        callback(symbol, self.rateButton)
    }
    
    func sync(with data: SymbolsItem, indexPath: IndexPath, mode: MarketListMode) -> Void {
        self.data = data
        
        if  let symbol = data.symbol,
            let indexOfLine = symbol.index(of: "/") {
            DispatchQueue.global().async {
                let len = symbol.count
                let symboAttr = NSMutableAttributedString(string: symbol)
                let attrLeft = [
                    NSAttributedString.Key.font : kThemeFontDINBold(16.0),
                    NSAttributedString.Key.foregroundColor : kThemeColorTextNormal
                ]
                let attrRight = [
                    NSAttributedString.Key.font : kThemeFontDINBold(13.0),
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
        
        self.digitalPriceLabel.text = data.lastPrice
        //let legalRate2Legal = NSDecimalNumber(string: CurrencyManager.shared().exchangeRate(forLegalCurrency: CurrencyManager.shared().legalCurrency).exchangeRate)
        //let legalPrice = NSDecimalNumber(string: data.usdPrice).multiplying(by: legalRate2Legal, withBehavior: kDecimalConfig).legalString()
        //self.legalPriceLabel.text = "\(CurrencyManager.shared().legalCurrencySymbol) \(data.lastUsdPrice ?? "--")"
        self.legalPriceLabel.text = data.lastUsdPrice ?? "--"
        
        let directionColor = data.theDirection == .flat ? kThemeColorTextUnabled : PriceColor(withDirection: data.theDirection)
        let rate = "\(DirectionSymbol(withDirection: data.theDirection))\(data.wavePercent ?? "--")%"
        self.volumeLabel.text = "\(LOCSTR(withKey: "24H量")) \(data.quantity ?? "--")"
        self.volumeLabel.textColor = kThemeColorTextUnabled
        if mode == .fullDisplay {
            self.rateButton.setImage(nil, for: .normal)
            self.rateButton.setImage(nil, for: .selected)
            self.rateButton.imageEdgeInsets = .zero
            self.rateButton.isUserInteractionEnabled = false
            self.rateButton.setTitle(rate, for: .normal)
            self.rateButton.backgroundColor = directionColor
        } else {
            self.rateButton.setImage(UIImage(named: "icon-mk-kline-collect"), for: .normal)
            self.rateButton.setImage(UIImage(named: "icon-home-star-collected"), for: .selected)
            self.rateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 65.0, bottom: 0, right: 0)
            self.rateButton.setTitle(nil, for: .normal)
            self.rateButton.backgroundColor = .clear
            self.rateButton.isUserInteractionEnabled = true
            if mode == .selector {
                self.rateButton.isSelected = DB.shared().isSymbolCollected(for: data.symbol)
            } else {
                self.rateButton.isSelected = false
            }
        }
    }
    
}
