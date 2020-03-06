//
//  MarketIntroductionView.swift
//  AELFExchange
//
//  Created by tng on 2019/8/19.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit
import SafariServices

class MarketIntroductionView: UIView {

    @IBOutlet weak var ICON: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var value1: UILabel!
    @IBOutlet weak var value2: UILabel!
    @IBOutlet weak var value3: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.websitePressed))
        self.value3.isUserInteractionEnabled = true
        self.value3.addGestureRecognizer(tap)
    }
    
    @objc private func websitePressed() {
        guard let url = URL(string: self.value3.text ?? "") else {
            return
        }
        TopController().present(SFSafariViewController(url: url), animated: true) {}
    }

}
