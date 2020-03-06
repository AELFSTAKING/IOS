//
//  WithdrawVC+UIUpdate.swift
//  AELFExchange
//
//  Created by tng on 2019/1/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension WithdrawVC {
    
    func updateGas() -> Void {
        self.viewModel.gasPrice = NSDecimalNumber(string: self.viewModel.gasInfoData?.fastGasPrice)
            .subtracting(NSDecimalNumber(string: self.viewModel.gasInfoData?.slowGasPrice), withBehavior: kDecimalConfig)
            .multiplying(by: NSDecimalNumber(value: self.gasSlider.value), withBehavior: kDecimalConfig)
            .adding(NSDecimalNumber(string: self.viewModel.gasInfoData?.slowGasPrice), withBehavior: kDecimalConfig)
            .string(withDecimalLen: Config.digitalDecimalLenMax, minLen: 0)
        
        let gasValue = NSDecimalNumber(string: self.viewModel.gasPrice)
            .multiplying(by: NSDecimalNumber(string: self.viewModel.gasInfoData?.gasLimit), withBehavior: kDecimalConfig)
            .dividing(by: NSDecimalNumber(string: "1000000000000000000"), withBehavior: kDecimalConfig)
            .string(withDecimalLen: Config.digitalDecimalLenMax)
        
        MarketManager.shared().usdtPrice(of: AELFCurrencyName.ETH.rawValue) { [weak self] (price) in
            let suggestUsdt = NSDecimalNumber(string: self?.viewModel.gasInfoData?.fee)
                .multiplying(by: NSDecimalNumber(string: price), withBehavior: kDecimalConfig)
                .string(withDecimalLen: Config.digitalDecimalLenMax)
            self?.gasSuggestLabel.text = "建议: \(self?.viewModel.gasInfoData?.fee ?? "--") \(AELFChainName.Ethereum.rawValue) ～ \(suggestUsdt) USDT"
            
            if self?.viewModel.defaultGasInited == false {
                // 默认Gas初始化.
                let tmpRange = NSDecimalNumber(string: self?.viewModel.gasInfoData?.fastGasPrice)
                    .subtracting(NSDecimalNumber(string: self?.viewModel.gasInfoData?.slowGasPrice), withBehavior: kDecimalConfig)
                let defGasPrice = NSDecimalNumber(string: self?.viewModel.gasInfoData?.fee)
                    .multiplying(by: NSDecimalNumber(string: "1000000000000000000"), withBehavior: kDecimalConfig)
                    .dividing(by: NSDecimalNumber(string: self?.viewModel.gasInfoData?.gasLimit), withBehavior: kDecimalConfig)
                    .subtracting(NSDecimalNumber(string: self?.viewModel.gasInfoData?.slowGasPrice), withBehavior: kDecimalConfig)
                    .dividing(by: tmpRange, withBehavior: kDecimalConfig)
                self?.gasSlider.value = defGasPrice.floatValue
                self?.viewModel.defaultGasInited = true
                self?.viewModel.loadGasConfigInfo()
                return
            }
            
            let gasUsdt = NSDecimalNumber(string: gasValue)
                .multiplying(by: NSDecimalNumber(string: price), withBehavior: kDecimalConfig)
                .string(withDecimalLen: Config.digitalDecimalLenMax)
            self?.gasValueLabel.text = "\(gasValue) \(AELFChainName.Ethereum.rawValue) ～ \(gasUsdt) USDT"
        }
    }
    
    func updateTargetAmount() {
        let amount = NSDecimalNumber(string: self.quantityTextfield.text)
            .multiplying(by: NSDecimalNumber(string: self.viewModel.usdtPrice), withBehavior: kDecimalConfig)
            .usdtString()
        self.availableBalnaceLegalLabel.text = "≈ \(amount) USDT"
    }
    
    func clearData() -> Void {
        self.quantityTextfield.text = nil
        self.addrToTextfield.text = nil
        self.viewModel.digitalQuantity = "0.0"
        self.viewModel.addressTo = ""
        self.viewModel.password = ""
    }
    
}

extension WithdrawVC: UITextFieldDelegate {
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if self.viewModel.decimalLenMax < 1 && string == "." {
//            return false
//        }
//        let text = textField.text ?? "" + string
//        if text.contains(".") {
//            if string == "" { return true }
//            let indexOfPoint = text.index(of: ".") ?? 0
//            let decimalContent = String(text[text.index(text.startIndex, offsetBy: indexOfPoint+1) ..< text.endIndex])
//            return decimalContent.count < self.viewModel.decimalLenMax || range.location <= indexOfPoint
//        }
//        return true
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? "" + string
        if text.contains(".") {
            let indexOfPoint = text.index(of: ".") ?? 0
            return text.count-(indexOfPoint+1) < Config.digitalDecimalLenMin || string == ""
        }
        return true
    }
    
}
