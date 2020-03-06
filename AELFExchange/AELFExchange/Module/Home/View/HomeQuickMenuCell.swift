//
//  HomeQuickMenuCell.swift
//  AELFExchange
//
//  Created by tng on 2019/4/9.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class HomeQuickMenuCell: UITableViewCell {
    
    let view = Bundle.main.loadNibNamed("HomeQuickMenuView", owner: nil, options: nil)?.first as! HomeQuickMenuView

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let sep = UIView()
        sep.backgroundColor = kThemeColorSeparatorBlack
        self.addSubview(sep)
        sep.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(10.0)
        }
        
        let sep2 = UIView()
        sep2.backgroundColor = kThemeColorSeparatorBlack
        self.addSubview(sep2)
        sep2.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(70.0)
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
