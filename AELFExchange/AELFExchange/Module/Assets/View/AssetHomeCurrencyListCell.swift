//
//  AssetHomeCurrencyListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class AssetHomeCurrencyListCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var chainLabel: Label!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var legalLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(withData data: TotalAssetsDataItem, hideAsset: Bool) {
        self.icon.image = UIImage(named: (data.currency ?? "").lowercased().removeTokenPrefix())
        self.currencyLabel.text = data.currency
        self.chainLabel.text = AELFIdentity.wallet_eth?.chain
        self.quantityLabel.text = hideAsset ? "***":data.balance?.digitalString()
        
        let usdtVal = NSDecimalNumber(string: data.usdtPrice)
            .multiplying(by: NSDecimalNumber(string: data.balance), withBehavior: kDecimalConfig)
            .usdtString()
        self.legalLabel.text = hideAsset ? "***":"≈ \(usdtVal)"
    }
    
}
