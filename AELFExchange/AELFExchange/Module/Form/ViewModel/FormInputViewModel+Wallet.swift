//
//  FormInputViewModel+WalletAccount.swift
//  AELFExchange
//
//  Created by tng on 2019/8/1.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import PromiseKit

extension FormInputViewModel {
    
    func createWalletAccount() {
        guard let name = self.assembleFormFields()["accountName"] as? String,
            let password = self.assembleFormFields()["password"] as? String,
            !name.isEmpty,
            !password.isEmpty else {
                InfoToast(withLocalizedTitle: "信息错误")
                return
        }
        
        self.controller?.startLoadingHUD(withMsg: Consts.kMsgInProcess)
        DispatchQueue.global().async {
            firstly {
                AELFIdentity.shared().createIdentity(withName: name, password: password)
                }.done { [weak self] (walletModel) in
                    InfoToast(withLocalizedTitle: "账户创建成功")
                    self?.controller?.push(to: UIStoryboard(name: "Assets", bundle: nil).instantiateViewController(withIdentifier: "exportPrivateKey"), animated: true)
                    self?.shouldPopAutomatically = true
                }.catch { (error) in
                    AELFIdentity.errorToast(withError: error)
                }.finally { [weak self] in
                    self?.controller?.stopLoadingHUD()
            }
        }
    }
    
    func importWalletAccount() {
        guard let name = self.assembleFormFields()["accountName"] as? String,
            let password = self.assembleFormFields()["password"] as? String,
            let privateKey = self.assembleFormFields()["privateKey"] as? String,
            !name.isEmpty,
            !password.isEmpty,
            !privateKey.isEmpty else {
                InfoToast(withLocalizedTitle: "信息错误")
                return
        }
        
        self.controller?.startLoadingHUD()
        DispatchQueue.global().async {
            firstly {
                AELFIdentity.shared().importIdentity(withName: name, password: password, privateKey: privateKey)
                }.done { [weak self] (walletModel) in
                    InfoToast(withLocalizedTitle: "账户导入成功")
                    self?.controller?.push(to: UIStoryboard(name: "Assets", bundle: nil).instantiateViewController(withIdentifier: "exportPrivateKey"), animated: true)
                    self?.shouldPopAutomatically = true
                }.catch { (error) in
                    AELFIdentity.errorToast(withError: error)
                }.finally { [weak self] in
                    self?.controller?.stopLoadingHUD()
            }
        }
    }
    
    func modifyWalletName() {
        guard let lastName = self.assembleFormFields()["oldName"] as? String,
            let newName = self.assembleFormFields()["newName"] as? String,
            !lastName.isEmpty,
            !newName.isEmpty else {
                InfoToast(withLocalizedTitle: "信息错误")
                return
        }
        
        firstly {
            AELFIdentity.shared().modifyName(withLastName: lastName, newName: newName)
            }.done { [weak self] (walletModel) in
                InfoToast(withLocalizedTitle: "修改成功")
                self?.controller?.pop()
            }.catch { (error) in
                AELFIdentity.errorToast(withError: error)
        }
    }
    
    func resetWalletPassword() {
        guard let name = self.assembleFormFields()["accountName"] as? String,
            let lastPassword = self.assembleFormFields()["oldPassword"] as? String,
            let newPassword = self.assembleFormFields()["password"] as? String,
            !name.isEmpty,
            !lastPassword.isEmpty,
            !newPassword.isEmpty else {
                InfoToast(withLocalizedTitle: "信息错误")
                return
        }
        
        firstly {
            AELFIdentity.shared().modifyPassword(withLastPwd: lastPassword, newPwd: newPassword, accountName: name)
            }.done { [weak self] (walletModel) in
                InfoToast(withLocalizedTitle: "修改成功")
                self?.controller?.pop()
            }.catch { (error) in
                AELFIdentity.errorToast(withError: error)
        }
    }
    
    func bindCrossChainTopupAddress() {
        guard let address = self.assembleFormFields()["baseAddress"] as? String,
            let memo = self.assembleFormFields()["name"] as? String,
            !address.isEmpty,
            !memo.isEmpty else {
                InfoToast(withLocalizedTitle: "信息错误")
                return
        }
        
        TopController().startLoadingHUD()
        let params = [
            "platformAddress":(AELFIdentity.wallet_eth?.address ?? ""),
            "bindName":memo,
            "bindChain":self.currency.uppercased().contains(AELFCurrencyName.BTC.rawValue) ? AELFChainName.Bitcoin.rawValue:self.chain,
            "bindCurrency":self.currency.uppercased().removeTokenPrefix(),
            "bindAddress":address
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .bindAddress), params: params, to: BaseAPIBusinessModel.self) { [weak self] (succeed, response) in
            TopController().stopLoadingHUD()
            guard succeed == true, response.succeed == true else {
                InfoToast(withLocalizedTitle: response.msg)
                return
            }
            InfoToast(withLocalizedTitle: "绑定成功")
            self?.completedObserver.send(value: true)
            self?.controller?.navigationController?.popViewController(animated: false)
        }
    }
    
}
