//
//  MarketSearchCell.swift
//  AELFExchange
//
//  Created by tng on 2019/5/24.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class MarketSearchCell: UITableViewCell {
    
    var pressedCollectCallback: ((String, UIButton) -> ())?
    private var symbol = ""

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.titleLabel.font = kThemeFontDINBold(16.0)
        self.titleLabel.textColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(withSymbol symbol: String) {
        self.symbol = symbol
        self.titleLabel.text = symbol
        self.collectButton.isSelected = DB.shared().isSymbolCollected(for: symbol)
    }
    
    @IBAction func collectPressed(_ sender: Any) {
        guard self.symbol.isEmpty == false, let callback = self.pressedCollectCallback else { return }
        callback(self.symbol, self.collectButton)
    }
    
}
