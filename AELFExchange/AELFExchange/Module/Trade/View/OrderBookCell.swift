//
//  OrderBookCell.swift
//  AELFExchange
//
//  Created by tng on 2019/7/17.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class OrderBookCell: UITableViewCell {
    
    @IBOutlet weak var cancelButton: Button!
    @IBOutlet weak var statusArrowIcon: UIImageView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var dateLabel: Label!
    @IBOutlet weak var priceTitleLabel: Label!
    @IBOutlet weak var priceValueLabel: Label!
    @IBOutlet weak var quantityTitleLabel: Label!
    @IBOutlet weak var quantityValueLabel: Label!
    @IBOutlet weak var freezeTitleLabel: Label!
    @IBOutlet weak var freezeValueLabel: Label!
    @IBOutlet weak var dealAmountTitleLabel: Label!
    @IBOutlet weak var dealAmountValueLabel: Label!
    @IBOutlet weak var avgPriceTitleLabel: Label!
    @IBOutlet weak var avgPriceValueLabel: Label!
    @IBOutlet weak var dealQuantityTitleLabel: Label!
    @IBOutlet weak var dealQuantityValueLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.modeLabel.addBorder(withWitdh: 0.8, color: kThemeColorRed)
        self.cancelButton.addBorder(withWitdh: 0.8, color: kThemeColorTextUnabled)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Sync data.
    ///
    /// - Parameters:
    ///   - data: .
    ///   - isDeal: delegate of deal.
    func sync(withData data: UserOrdersListData, isDeal: Bool) {
        let color = OrderActionColor(withAction: data.theAction)
        self.modeLabel.text = data.actionDescription
        self.modeLabel.textColor = color
        self.modeLabel.layer.borderColor = color.cgColor
        self.symbolLabel.text = data.symbol
        self.dateLabel.text = data.utcCreate?.timestamp2date(withFormat: "HH:mm MM/dd")
        self.priceTitleLabel.text = "\(LOCSTR(withKey: "委托价"))(\(data.counterCurrency ?? "--"))"
        self.priceValueLabel.text = data.priceLimit?.string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
        self.quantityTitleLabel.text = "\(LOCSTR(withKey: "委托量"))(\(data.currency ?? "--"))"
        self.quantityValueLabel.text = data.quantity?.string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
        
        self.dealAmountTitleLabel.isHidden = !isDeal
        self.dealAmountValueLabel.isHidden = !isDeal
        self.avgPriceTitleLabel.isHidden = !isDeal
        self.avgPriceValueLabel.isHidden = !isDeal
        self.dealQuantityTitleLabel.isHidden = !isDeal
        self.dealQuantityValueLabel.isHidden = !isDeal
        
        self.cancelButton.isUserInteractionEnabled = !isDeal
        self.statusArrowIcon.isHidden = !isDeal
        
        // 冻结/手续费.
        if isDeal {
            self.cancelButton.isEnabled = true
            self.cancelButton.layer.borderColor = UIColor.clear.cgColor
            self.cancelButton.contentHorizontalAlignment = .right
            self.cancelButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8.0)
            self.cancelButton.setTitle(data.statusDescOfDealList, for: .normal)

            self.freezeTitleLabel.text = "\(LOCSTR(withKey: "手续费"))(\(data.feeCurrency ?? "--"))"
            self.freezeValueLabel.text = data.fee?.string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
            
            // 历史委托相关.
            self.dealAmountTitleLabel.text = "\(LOCSTR(withKey: "成交总额"))(\(data.counterCurrency ?? "--"))"
            self.dealAmountValueLabel.text = NSDecimalNumber(string: data.amount).string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
            self.avgPriceTitleLabel.text = "\(LOCSTR(withKey: "成交均价"))(\(data.counterCurrency ?? "--"))"
            self.avgPriceValueLabel.text = NSDecimalNumber(string: data.priceAverage).string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
            self.dealQuantityTitleLabel.text = "\(LOCSTR(withKey: "成交量"))(\(data.currency ?? "--"))"
            self.dealQuantityValueLabel.text = NSDecimalNumber(string: data.quantity)
                .subtracting(NSDecimalNumber(string: data.quantityRemaining), withBehavior: kDecimalConfig)
                .string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
        } else {
            self.cancelButton.layer.borderColor = self.cancelButton.titleColor(for: .normal)?.cgColor
            self.cancelButton.contentHorizontalAlignment = .center
            self.cancelButton.titleEdgeInsets = .zero
            self.cancelButton.isEnabled = !data.isWaittingForConfirm
            if data.isWaittingForConfirm {
                self.cancelButton.setTitle(data.statusDesc, for: .normal)
                self.cancelButton.layer.borderColor = UIColor.clear.cgColor
            } else {
                self.cancelButton.setTitle(LOCSTR(withKey: "撤销"), for: .normal)
                self.cancelButton.layer.borderColor = kThemeColorTextUnabled.cgColor
            }
            
            self.freezeTitleLabel.text = "\(LOCSTR(withKey: "冻结"))(\(data.freezeCurrency ?? "--"))"
            self.freezeValueLabel.text = data.freezeAmount?.string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
        }
    }
    
}
