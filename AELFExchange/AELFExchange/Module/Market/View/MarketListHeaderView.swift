//
//  MarketListHeaderView.swift
//  AELFExchange
//
//  Created by tng on 2019/5/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class MarketListHeaderView: UIView {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.label1.textColor = kThemeColorTextUnabled
        self.label2.textColor = self.label1.textColor
        self.label3.textColor = self.label1.textColor
        
        let sep = UIView()
        sep.backgroundColor = kThemeColorSeparator
        self.addSubview(sep)
        sep.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0.65)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.65)
        }
    }
    
    func titleSetup(forSelectorMode: Bool) {
        label1.text = LOCSTR(withKey: "交易对/24H量")
    }
    
}
