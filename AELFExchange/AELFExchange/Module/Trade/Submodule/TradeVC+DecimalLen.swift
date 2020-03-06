//
//  TradeVC+DecimalLen.swift
//  AELFExchange
//
//  Created by tng on 2019/4/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

extension TradeVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let decimalLenMax = (textField.tag == 1 ? self.viewModel.priceDecimalLen:Config.digitalDecimalLenMin)
        if decimalLenMax < 1 && string == "." {
            return false
        }
        let text = textField.text ?? "" + string
        if text.contains(".") {
            let indexOfPoint = text.index(of: ".") ?? 0
            return text.count-(indexOfPoint+1) < decimalLenMax || string == ""
        }
        return true
    }
    
}
